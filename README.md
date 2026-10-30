# FRUTIMIA 🍓

Tienda web adaptable para FRUTIMIA. Catálogo sin precios públicos, pedidos para recoger, cuentas de clientes, puntos, recompensas, opiniones, chat y panel de administración.

## Backend
Esta versión utiliza **Supabase** (Auth + PostgreSQL + Row Level Security). Ya no requiere Firebase.

## Configuración
1. Confirma que `js/supabase-config.js` tenga el Project URL, la publishable/anon key y el correo administrador.
2. En Supabase > SQL Editor, ejecuta en este orden y completos: `supabase/schema.sql`, `supabase/actualizacion_admin_frutimia.sql`, `supabase/actualizacion_canjes_admin.sql` y, al final, `supabase/frutimia_mejoras_v2.sql`.
3. Abre `index.html` con Live Server o publica la carpeta `FRUTIMIA` en tu hosting.

**Nunca pongas la clave `service_role` en el navegador.**


## Actualización v2 incluida

La migración v2 ya está incluida en el orden de instalación anterior. Si tu proyecto ya tenía las tres migraciones anteriores, ejecuta únicamente `supabase/frutimia_mejoras_v2.sql` completo en Supabase > SQL Editor. Esta migración añade estados `entregado`, acreditación idempotente de 100 puntos por pedido, historial, rangos, administración manual de rangos, inventario, promociones, permisos RLS y publicación Realtime para pedidos y mensajes.

### Rangos automáticos
- Cliente: 0–4 pedidos entregados.
- Favorito: desde 5 pedidos entregados.
- VIP: desde 15 pedidos entregados.
- Leyenda: desde 30 pedidos entregados.

Un rango asignado manualmente queda fijado hasta que el administrador lo cambie de nuevo.

### Notas importantes
- El carrito se conserva en el navegador mediante almacenamiento local.
- Pedidos y chat usan Supabase Realtime; si el proyecto no tiene Realtime habilitado, revisa que `orders`, `messages` y `redemptions` estén en la publicación `supabase_realtime`.
- El panel de estadísticas cuenta pedidos y unidades. No muestra ingresos porque el esquema actual no almacena precios ni total monetario en cada pedido.
- El inventario y las promociones se administran desde el panel; no se descuenta stock automáticamente al crear pedidos porque los artículos actuales del carrito no están vinculados a un catálogo relacional con existencias.
- La migración valida el administrador `codeckhn@gmail.com`, que coincide con `ADMIN_EMAIL` en `js/supabase-config.js`. Si cambias el correo administrador, actualiza ambos lugares. Nunca publiques una clave `service_role`.
- Los 100 puntos se acreditan por pedido al pasar a `entregado` (también admite el estado histórico `recogido`), una sola vez. Los puntos antiguos ya duplicados en cuentas existentes requieren revisión contable manual; la migración impide nuevas duplicaciones.


## Corrección adicional: error al asignar rangos / marcar entregado

Si aparece `Could not find the function public.admin_set_customer_rank(...) in the schema cache`, ejecuta `supabase/solucion_admin_set_customer_rank.sql` en Supabase > SQL Editor. Esta corrección elimina firmas antiguas incompatibles, crea la función con los nombres de parámetros que usa la web y solicita recargar el caché de PostgREST. El `index.html` también fuerza la descarga de `online.js` actualizado con un parámetro de versión para evitar código JavaScript antiguo en caché. Después publica nuevamente todos los archivos del proyecto y realiza una recarga forzada del navegador (Ctrl+F5).

La acción de marcar un pedido como `entregado` en `js/online.js` actualiza `orders.status` directamente; no llama a `admin_set_customer_rank`. Si tras publicar esta versión el botón sigue mostrando ese error, revisa que el hosting esté sirviendo este `js/online.js` y no una copia antigua.
