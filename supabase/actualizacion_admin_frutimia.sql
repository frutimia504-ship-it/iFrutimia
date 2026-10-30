-- FRUTIMIA · Actualización de administración, perfiles, bloqueos y chat
-- Ejecutar UNA SOLA VEZ en Supabase > SQL Editor.
alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists blocked_until timestamptz;
alter table public.profiles add column if not exists is_deleted boolean not null default false;

create or replace function public.make_frutimia_username(p_name text, p_id uuid)
returns text language sql immutable
as $$
  select 'FRU-' || upper(substr(replace(p_id::text,'-',''),1,6));
$$;

update public.profiles p
set username = public.make_frutimia_username(p.display_name,p.id)
where username is null or btrim(username) = '';

create unique index if not exists profiles_username_unique on public.profiles(username);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles(id, display_name, username)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data->>'name',''), split_part(new.email,'@',1)),
    public.make_frutimia_username(new.raw_user_meta_data->>'name',new.id)
  )
  on conflict (id) do update set
    display_name = coalesce(public.profiles.display_name, excluded.display_name),
    username = coalesce(public.profiles.username, excluded.username);
  return new;
end;
$$;

create or replace function public.admin_list_customers()
returns table(id uuid,email text,display_name text,username text,points integer,blocked_until timestamptz,created_at timestamptz)
language plpgsql security definer set search_path = public, auth
as $$
begin
  if not public.is_frutimia_admin() then raise exception 'No autorizado'; end if;
  return query
  select p.id,u.email::text,p.display_name,p.username,p.points,p.blocked_until,p.created_at
  from public.profiles p join auth.users u on u.id=p.id
  where coalesce(p.is_deleted,false)=false
  order by p.created_at desc;
end;
$$;

create or replace function public.admin_adjust_points(target_user uuid, amount integer, note text)
returns void language plpgsql security definer set search_path = public
as $$
declare current_points integer;
begin
  if not public.is_frutimia_admin() then raise exception 'No autorizado'; end if;
  if amount = 0 or char_length(btrim(coalesce(note,''))) < 2 then raise exception 'Indica cantidad y motivo'; end if;
  select points into current_points from public.profiles where id=target_user for update;
  if current_points is null then raise exception 'Cliente no encontrado'; end if;
  if current_points + amount < 0 then raise exception 'El cliente no tiene suficientes puntos para quitar esa cantidad'; end if;
  update public.profiles set points=points+amount where id=target_user;
  insert into public.point_ledger(user_id,delta,reason) values(target_user,amount,btrim(note));
end;
$$;

create or replace function public.admin_block_user(target_user uuid, days_to_block integer)
returns void language plpgsql security definer set search_path = public, auth
as $$
declare until_time timestamptz;
begin
  if not public.is_frutimia_admin() then raise exception 'No autorizado'; end if;
  if days_to_block < 1 or days_to_block > 30 then raise exception 'El bloqueo debe ser de 1 a 30 días'; end if;
  if target_user = auth.uid() then raise exception 'No puedes bloquear tu propia cuenta'; end if;
  until_time := now() + make_interval(days => days_to_block);
  update auth.users set banned_until=until_time where id=target_user;
  update public.profiles set blocked_until=until_time where id=target_user;
  if not found then raise exception 'Cliente no encontrado'; end if;
end;
$$;

create or replace function public.admin_unblock_user(target_user uuid)
returns void language plpgsql security definer set search_path = public, auth
as $$
begin
  if not public.is_frutimia_admin() then raise exception 'No autorizado'; end if;
  update auth.users set banned_until=null where id=target_user;
  update public.profiles set blocked_until=null where id=target_user;
end;
$$;

create or replace function public.admin_delete_user(target_user uuid)
returns void language plpgsql security definer set search_path = public, auth
as $$
begin
  if not public.is_frutimia_admin() then raise exception 'No autorizado'; end if;
  if target_user = auth.uid() then raise exception 'No puedes eliminar tu propia cuenta administradora'; end if;
  delete from auth.users where id=target_user;
  if not found then raise exception 'Cuenta no encontrada'; end if;
end;
$$;

create or replace function public.admin_list_chat_users()
returns table(user_id uuid,display_name text,username text,email text,last_message text,last_at timestamptz)
language plpgsql security definer set search_path = public, auth
as $$
begin
  if not public.is_frutimia_admin() then raise exception 'No autorizado'; end if;
  return query
  select distinct on (m.user_id) m.user_id,p.display_name,p.username,u.email::text,m.body,m.created_at
  from public.messages m
  left join public.profiles p on p.id=m.user_id
  left join auth.users u on u.id=m.user_id
  order by m.user_id,m.created_at desc;
end;
$$;

revoke all on function public.admin_list_customers() from public, anon;
revoke all on function public.admin_adjust_points(uuid,integer,text) from public, anon;
revoke all on function public.admin_block_user(uuid,integer) from public, anon;
revoke all on function public.admin_unblock_user(uuid) from public, anon;
revoke all on function public.admin_delete_user(uuid) from public, anon;
revoke all on function public.admin_list_chat_users() from public, anon;
grant execute on function public.admin_list_customers() to authenticated;
grant execute on function public.admin_adjust_points(uuid,integer,text) to authenticated;
grant execute on function public.admin_block_user(uuid,integer) to authenticated;
grant execute on function public.admin_unblock_user(uuid) to authenticated;
grant execute on function public.admin_delete_user(uuid) to authenticated;
grant execute on function public.admin_list_chat_users() to authenticated;
