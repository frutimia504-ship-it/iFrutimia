-- FRUTIMIA · Mejoras v2
-- Ejecutar UNA SOLA VEZ en Supabase > SQL Editor > New query.
-- No contiene claves secretas. El administrador permitido se valida por email y/o app_metadata.role.

create extension if not exists pgcrypto;

-- 1) Acceso administrativo consistente entre la web y RLS.
create or replace function public.is_frutimia_admin()
returns boolean language sql stable security definer set search_path = public, auth
as $$
  select coalesce((auth.jwt()->'app_metadata'->>'role')='admin',false)
      or lower(coalesce(auth.jwt()->>'email','')) = 'codeckhn@gmail.com';
$$;

-- 2) Campos administrativos requeridos por versiones anteriores del proyecto.
alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists blocked_until timestamptz;
alter table public.profiles add column if not exists is_deleted boolean not null default false;

-- 3) Estados, historial, puntos idempotentes y rangos.
alter table public.orders drop constraint if exists orders_status_check;
alter table public.orders add constraint orders_status_check
  check (status in ('nuevo','aceptado','preparando','listo','recogido','entregado','rechazado'));

alter table public.profiles add column if not exists customer_rank text not null default 'Cliente'
  check (customer_rank in ('Cliente','Favorito','VIP','Leyenda'));
alter table public.profiles add column if not exists completed_orders integer not null default 0;
alter table public.profiles add column if not exists rank_manual boolean not null default false;

alter table public.point_ledger add column if not exists redemption_id uuid;
-- Tabla de idempotencia separada: también funciona aunque existan movimientos históricos repetidos en point_ledger.
create table if not exists public.order_points_awards (
  order_id uuid primary key references public.orders(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  points integer not null default 100 check(points > 0),
  awarded_at timestamptz not null default now()
);
alter table public.order_points_awards enable row level security;
-- Evita duplicar la devolución de puntos de un mismo canje.
create unique index if not exists point_ledger_one_redemption_refund_idx
  on public.point_ledger(redemption_id) where redemption_id is not null and delta > 0;

create or replace function public.award_order_points()
returns trigger language plpgsql security definer set search_path = public
as $$
declare inserted_count integer := 0;
begin
  if new.status in ('entregado','recogido')
     and old.status not in ('entregado','recogido')
     and coalesce(new.points_awarded,false) = false then
    insert into public.order_points_awards(order_id,user_id,points)
      values(new.id,new.user_id,100) on conflict(order_id) do nothing;
    get diagnostics inserted_count = row_count;
    if inserted_count = 1 then
      update public.profiles set points = points + 100 where id = new.user_id;
      insert into public.point_ledger(user_id,order_id,delta,reason)
        values(new.user_id,new.id,100,'Puntos por pedido entregado');
    end if;
    new.points_awarded := true;
  end if;
  return new;
end;
$$;
drop trigger if exists award_points_on_order_pickup on public.orders;
drop trigger if exists award_points_on_order_delivery on public.orders;
create trigger award_points_on_order_delivery
  before update of status on public.orders
  for each row execute function public.award_order_points();

create or replace function public.refresh_customer_rank()
returns trigger language plpgsql security definer set search_path = public
as $$
declare completed integer;
begin
  if new.status in ('entregado','recogido') and old.status not in ('entregado','recogido') then
    select count(*)::integer into completed from public.orders
      where user_id = new.user_id and status in ('entregado','recogido');
    update public.profiles
      set completed_orders = completed,
          customer_rank = case
            when rank_manual then customer_rank
            when completed >= 30 then 'Leyenda'
            when completed >= 15 then 'VIP'
            when completed >= 5 then 'Favorito'
            else 'Cliente' end
      where id = new.user_id;
  end if;
  return new;
end;
$$;
drop trigger if exists refresh_rank_after_order on public.orders;
create trigger refresh_rank_after_order after update of status on public.orders
  for each row execute function public.refresh_customer_rank();

-- Recalcular el contador y los rangos automáticos actuales (no modifica rangos manuales).
update public.profiles p set completed_orders = coalesce(x.total,0),
  customer_rank = case when p.rank_manual then p.customer_rank
    when coalesce(x.total,0) >= 30 then 'Leyenda'
    when coalesce(x.total,0) >= 15 then 'VIP'
    when coalesce(x.total,0) >= 5 then 'Favorito' else 'Cliente' end
from (select p2.id, count(o.id)::integer as total from public.profiles p2
      left join public.orders o on o.user_id=p2.id and o.status in ('entregado','recogido')
      group by p2.id) x where p.id=x.id;

-- Eliminar firmas antiguas: PostgreSQL no permite renombrar parámetros con CREATE OR REPLACE.
drop function if exists public.admin_set_customer_rank(uuid,text);
drop function if exists public.admin_set_customer_rank(text,uuid);

create function public.admin_set_customer_rank(target_user uuid,new_rank text)
returns void language plpgsql security definer set search_path = public
as $$
begin
  if not public.is_frutimia_admin() then raise exception 'No autorizado'; end if;
  if new_rank not in ('Cliente','Favorito','VIP','Leyenda') then raise exception 'Rango no válido'; end if;
  update public.profiles set customer_rank=new_rank,rank_manual=true where id=target_user;
  if not found then raise exception 'Cliente no encontrado'; end if;
end;
$$;

-- Lista administrativa ampliada con el rango y los pedidos completados.
drop function if exists public.admin_list_customers();
create function public.admin_list_customers()
returns table(id uuid,email text,display_name text,username text,points integer,
  blocked_until timestamptz,created_at timestamptz,customer_rank text,completed_orders integer)
language plpgsql security definer set search_path = public, auth
as $$
begin
  if not public.is_frutimia_admin() then raise exception 'No autorizado'; end if;
  return query
  select p.id,u.email::text,p.display_name,p.username,p.points,p.blocked_until,p.created_at,
         p.customer_rank,p.completed_orders
  from public.profiles p join auth.users u on u.id=p.id
  where coalesce(p.is_deleted,false)=false order by p.created_at desc;
end;
$$;

-- 3) Devolución de canje transaccional e idempotente.
alter table public.redemptions add column if not exists admin_message text;
alter table public.redemptions add column if not exists reviewed_at timestamptz;
create or replace function public.process_reward_redemption()
returns trigger language plpgsql security definer set search_path = public
as $$
declare current_points integer;
begin
  select points into current_points from public.profiles where id=new.user_id for update;
  if current_points is null or current_points < new.points_cost then
    raise exception 'No tienes suficientes puntos para este canje';
  end if;
  update public.profiles set points=points-new.points_cost where id=new.user_id;
  insert into public.point_ledger(user_id,redemption_id,delta,reason)
    values(new.user_id,new.id,-new.points_cost,'Canje solicitado: '||new.reward_name);
  return new;
end;
$$;
drop trigger if exists deduct_points_for_redemption on public.redemptions;
create trigger deduct_points_for_redemption after insert on public.redemptions
  for each row execute function public.process_reward_redemption();

create or replace function public.admin_review_redemption(
  target_redemption uuid, decision text, response_message text default ''
)
returns void language plpgsql security definer set search_path = public
as $$
declare request_row public.redemptions%rowtype; inserted_count integer := 0;
begin
  if not public.is_frutimia_admin() then raise exception 'No autorizado'; end if;
  if decision not in ('aprobada','rechazada') then raise exception 'Decisión no válida'; end if;
  select * into request_row from public.redemptions where id=target_redemption for update;
  if not found then raise exception 'Solicitud de canje no encontrada'; end if;
  if request_row.status <> 'pendiente' then raise exception 'Esta solicitud ya fue revisada'; end if;
  if decision='rechazada' then
    insert into public.point_ledger(user_id,redemption_id,delta,reason)
      values(request_row.user_id,request_row.id,request_row.points_cost,
        'Devolución por canje rechazado: '||request_row.reward_name)
      on conflict do nothing;
    get diagnostics inserted_count = row_count;
    if inserted_count=1 then
      update public.profiles set points=points+request_row.points_cost where id=request_row.user_id;
    end if;
  end if;
  update public.redemptions set status=decision,
    admin_message=nullif(btrim(response_message),''),reviewed_at=now()
    where id=target_redemption;
end;
$$;

-- 4) Inventario y promociones.
create table if not exists public.inventory (
  id uuid primary key default gen_random_uuid(),
  product_name text not null unique,
  stock integer not null default 0 check(stock >= 0),
  active boolean not null default true,
  updated_at timestamptz not null default now()
);
create table if not exists public.promotions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  starts_on date,
  ends_on date,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  check(ends_on is null or starts_on is null or ends_on >= starts_on)
);
create or replace function public.touch_inventory_updated_at()
returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end; $$;
drop trigger if exists inventory_updated_at on public.inventory;
create trigger inventory_updated_at before update on public.inventory
  for each row execute function public.touch_inventory_updated_at();

alter table public.inventory enable row level security;
alter table public.promotions enable row level security;
drop policy if exists "admin manage inventory" on public.inventory;
create policy "admin manage inventory" on public.inventory for all to authenticated
  using(public.is_frutimia_admin()) with check(public.is_frutimia_admin());
drop policy if exists "admin manage promotions" on public.promotions;
create policy "admin manage promotions" on public.promotions for all to authenticated
  using(public.is_frutimia_admin()) with check(public.is_frutimia_admin());
grant select,insert,update,delete on public.inventory,public.promotions to authenticated;

-- 5) Permisos de funciones administrativas.
revoke all on function public.admin_set_customer_rank(uuid,text) from public,anon;
grant execute on function public.admin_set_customer_rank(uuid,text) to authenticated;
revoke all on function public.admin_list_customers() from public,anon;
grant execute on function public.admin_list_customers() to authenticated;
revoke all on function public.admin_review_redemption(uuid,text,text) from public,anon;
grant execute on function public.admin_review_redemption(uuid,text,text) to authenticated;

-- 6) Activar Realtime para pedidos y mensajes si la publicación estándar existe.
do $$ begin
  if exists(select 1 from pg_publication where pubname='supabase_realtime') then
    begin alter publication supabase_realtime add table public.orders; exception when duplicate_object then null; when undefined_object then null; end;
    begin alter publication supabase_realtime add table public.messages; exception when duplicate_object then null; when undefined_object then null; end;
    begin alter publication supabase_realtime add table public.redemptions; exception when duplicate_object then null; when undefined_object then null; end;
  end if;
end $$;

-- Nota de rangos automáticos: Favorito desde 5 pedidos; VIP desde 15; Leyenda desde 30.
-- Los cambios manuales se conservan hasta que el administrador los vuelva a cambiar.

-- Actualizar el caché de funciones de PostgREST/Supabase.
notify pgrst, 'reload schema';
