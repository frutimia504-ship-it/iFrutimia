-- FRUTIMIA: corrección de la función para asignar rangos.
-- Ejecutar en Supabase > SQL Editor. No modifica los puntos ni los pedidos.

drop function if exists public.admin_set_customer_rank(uuid,text);
drop function if exists public.admin_set_customer_rank(text,uuid);

create function public.admin_set_customer_rank(target_user uuid, new_rank text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_frutimia_admin() then
    raise exception 'No autorizado';
  end if;

  if new_rank not in ('Cliente','Favorito','VIP','Leyenda') then
    raise exception 'Rango no válido';
  end if;

  update public.profiles
     set customer_rank = new_rank, rank_manual = true
   where id = target_user;

  if not found then
    raise exception 'Cliente no encontrado';
  end if;
end;
$$;

revoke all on function public.admin_set_customer_rank(uuid,text) from public, anon;
grant execute on function public.admin_set_customer_rank(uuid,text) to authenticated;
notify pgrst, 'reload schema';
