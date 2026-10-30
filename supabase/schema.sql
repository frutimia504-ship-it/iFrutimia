-- FRUTIMIA · Ejecuta todo este archivo en Supabase > SQL Editor > New query.
create extension if not exists pgcrypto;

create or replace function public.is_frutimia_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin', false); $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  points integer not null default 0 check (points >= 0),
  facebook_discount_used boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  customer_name text not null,
  phone text not null,
  notes text default '',
  items jsonb not null,
  status text not null default 'nuevo' check (status in ('nuevo','aceptado','preparando','listo','recogido','rechazado')),
  points_awarded boolean not null default false,
  discount_applied boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.point_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  order_id uuid references public.orders(id) on delete set null,
  delta integer not null,
  reason text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.redemptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  reward_name text not null,
  points_cost integer not null check (points_cost > 0),
  status text not null default 'pendiente' check (status in ('pendiente','aprobada','entregada','rechazada')),
  created_at timestamptz not null default now()
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id text not null,
  product_name text not null,
  display_name text,
  stars integer not null check (stars between 1 and 5),
  comment text not null check (char_length(comment) between 2 and 600),
  created_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  sender_role text not null check (sender_role in ('customer','admin')),
  body text not null check (char_length(body) between 1 and 1000),
  created_at timestamptz not null default now()
);

-- Crear perfil automáticamente al registrar un cliente.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$ begin
  insert into public.profiles(id, display_name) values (new.id, coalesce(new.raw_user_meta_data->>'name', split_part(new.email,'@',1))) on conflict (id) do nothing;
  return new;
end; $$;
drop trigger if exists on_auth_user_created_frutimia on auth.users;
create trigger on_auth_user_created_frutimia after insert on auth.users for each row execute procedure public.handle_new_user();

-- Acreditar 1,000 puntos por unidad solamente una vez, al marcar pedido como recogido.
create or replace function public.award_order_points()
returns trigger language plpgsql security definer set search_path = public
as $$
declare qty_total integer;
begin
  if new.status = 'recogido' and old.status is distinct from 'recogido' and new.points_awarded = false then
    select coalesce(sum(greatest(1, least(30, (item->>'qty')::integer))),0) into qty_total
    from jsonb_array_elements(new.items) as item;
    if qty_total > 0 then
      update public.profiles set points = points + (qty_total * 1000) where id = new.user_id;
      insert into public.point_ledger(user_id,order_id,delta,reason) values(new.user_id,new.id,qty_total*1000,'Puntos por pedido recogido');
      new.points_awarded := true;
    end if;
  end if;
  return new;
end; $$;
drop trigger if exists award_points_on_order_pickup on public.orders;
create trigger award_points_on_order_pickup before update of status on public.orders for each row execute procedure public.award_order_points();

-- Ajuste manual seguro desde SQL Editor, solo lo realiza el administrador.
create or replace function public.admin_adjust_points(target_user uuid, amount integer, note text)
returns void language plpgsql security definer set search_path = public
as $$ begin
  if not public.is_frutimia_admin() then raise exception 'No autorizado'; end if;
  if amount = 0 or char_length(coalesce(note,'')) < 2 then raise exception 'Indica cantidad y motivo'; end if;
  update public.profiles set points = greatest(0, points + amount) where id = target_user;
  insert into public.point_ledger(user_id,delta,reason) values(target_user,amount,note);
end; $$;

-- Descuento de primera compra: marca 15% una sola vez para cuentas con identidad Facebook.
create or replace function public.apply_facebook_first_order_discount()
returns trigger language plpgsql security definer set search_path = public, auth
as $$
declare facebook_user boolean;
begin
  select exists(select 1 from auth.identities i where i.user_id = new.user_id and i.provider = 'facebook') into facebook_user;
  if facebook_user then
    update public.profiles set facebook_discount_used = true
      where id = new.user_id and facebook_discount_used = false;
    if found then new.discount_applied := true; end if;
  end if;
  return new;
end; $$;
drop trigger if exists facebook_first_order_discount on public.orders;
create trigger facebook_first_order_discount before insert on public.orders for each row execute procedure public.apply_facebook_first_order_discount();

-- El canje descuenta puntos de forma atómica; no permite saldo negativo.
create or replace function public.process_reward_redemption()
returns trigger language plpgsql security definer set search_path = public
as $$
declare current_points integer;
begin
  select points into current_points from public.profiles where id = new.user_id for update;
  if current_points is null or current_points < new.points_cost then raise exception 'No tienes suficientes puntos para este canje'; end if;
  update public.profiles set points = points - new.points_cost where id = new.user_id;
  insert into public.point_ledger(user_id,delta,reason) values(new.user_id,-new.points_cost,'Canje solicitado: ' || new.reward_name);
  return new;
end; $$;
drop trigger if exists deduct_points_for_redemption on public.redemptions;
create trigger deduct_points_for_redemption before insert on public.redemptions for each row execute procedure public.process_reward_redemption();

-- RLS
alter table public.profiles enable row level security;
alter table public.orders enable row level security;
alter table public.point_ledger enable row level security;
alter table public.redemptions enable row level security;
alter table public.reviews enable row level security;
alter table public.messages enable row level security;

drop policy if exists "profile own or admin read" on public.profiles;
create policy "profile own or admin read" on public.profiles for select to authenticated using (id = auth.uid() or public.is_frutimia_admin());
drop policy if exists "profile admin update" on public.profiles;
create policy "profile admin update" on public.profiles for update to authenticated using (public.is_frutimia_admin()) with check (public.is_frutimia_admin());

drop policy if exists "customer create own order" on public.orders;
create policy "customer create own order" on public.orders for insert to authenticated with check (user_id = auth.uid() and status = 'nuevo' and points_awarded = false);
drop policy if exists "customer or admin read orders" on public.orders;
create policy "customer or admin read orders" on public.orders for select to authenticated using (user_id = auth.uid() or public.is_frutimia_admin());
drop policy if exists "admin update orders" on public.orders;
create policy "admin update orders" on public.orders for update to authenticated using (public.is_frutimia_admin()) with check (public.is_frutimia_admin());

drop policy if exists "own point history read" on public.point_ledger;
create policy "own point history read" on public.point_ledger for select to authenticated using (user_id = auth.uid() or public.is_frutimia_admin());

drop policy if exists "customer request own reward" on public.redemptions;
create policy "customer request own reward" on public.redemptions for insert to authenticated with check (user_id = auth.uid() and status = 'pendiente');
drop policy if exists "customer or admin read rewards" on public.redemptions;
create policy "customer or admin read rewards" on public.redemptions for select to authenticated using (user_id = auth.uid() or public.is_frutimia_admin());
drop policy if exists "admin manage rewards" on public.redemptions;
create policy "admin manage rewards" on public.redemptions for update to authenticated using (public.is_frutimia_admin()) with check (public.is_frutimia_admin());

drop policy if exists "reviews public read" on public.reviews;
create policy "reviews public read" on public.reviews for select to anon, authenticated using (true);
drop policy if exists "customer create own review" on public.reviews;
create policy "customer create own review" on public.reviews for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "admin delete reviews" on public.reviews;
create policy "admin delete reviews" on public.reviews for delete to authenticated using (public.is_frutimia_admin());

drop policy if exists "customer or admin read messages" on public.messages;
create policy "customer or admin read messages" on public.messages for select to authenticated using (user_id = auth.uid() or public.is_frutimia_admin());
drop policy if exists "customer send own message" on public.messages;
create policy "customer send own message" on public.messages for insert to authenticated with check (user_id = auth.uid() and sender_role = 'customer');
drop policy if exists "admin reply messages" on public.messages;
create policy "admin reply messages" on public.messages for insert to authenticated with check (public.is_frutimia_admin() and sender_role = 'admin');

grant usage on schema public to anon, authenticated;
grant select on public.reviews to anon, authenticated;
grant select, insert, update on public.profiles to authenticated;
grant select, insert, update on public.orders to authenticated;
grant select on public.point_ledger to authenticated;
grant select, insert, update on public.redemptions to authenticated;
grant select, insert, delete on public.reviews to authenticated;
grant select, insert on public.messages to authenticated;
