-- FRUTIMIA: seguimiento de canjes, respuesta del administrador y devolución al rechazar.
-- Ejecutar UNA SOLA VEZ en Supabase > SQL Editor.

alter table public.redemptions
  add column if not exists admin_message text,
  add column if not exists reviewed_at timestamptz;

-- El esquema base descuenta los puntos al crear la solicitud.
-- Por eso aprobar NO vuelve a descontarlos. Rechazar los devuelve.
create or replace function public.admin_review_redemption(
  target_redemption uuid,
  decision text,
  response_message text default ''
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  request_row public.redemptions%rowtype;
begin
  if not public.is_frutimia_admin() then
    raise exception 'No autorizado';
  end if;

  if decision not in ('aprobada','rechazada') then
    raise exception 'Decisión no válida';
  end if;

  select * into request_row
  from public.redemptions
  where id = target_redemption
  for update;

  if not found then
    raise exception 'Solicitud de canje no encontrada';
  end if;
  if request_row.status <> 'pendiente' then
    raise exception 'Esta solicitud ya fue revisada';
  end if;

  if decision = 'rechazada' then
    update public.profiles
      set points = points + request_row.points_cost
      where id = request_row.user_id;
    insert into public.point_ledger(user_id, delta, reason)
      values(request_row.user_id, request_row.points_cost,
        'Devolución por canje rechazado: ' || request_row.reward_name);
  end if;

  update public.redemptions
    set status = decision,
        admin_message = nullif(btrim(response_message), ''),
        reviewed_at = now()
    where id = target_redemption;
end;
$$;

revoke all on function public.admin_review_redemption(uuid,text,text) from public, anon;
grant execute on function public.admin_review_redemption(uuid,text,text) to authenticated;

-- Retirar permisos de la versión antigua para evitar llamadas ambiguas.
revoke all on function public.admin_review_redemption(uuid,text) from public, anon, authenticated;


drop function if exists public.admin_review_redemption(uuid,text);
