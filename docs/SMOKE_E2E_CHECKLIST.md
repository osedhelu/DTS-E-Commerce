# Smoke E2E — Piloto producción

**Backend:** `https://api.dtsdrop.com/api/v1`  
**Portal web:** `https://dtsdrop.com`  
**Duración estimada:** 45–60 min con 2 dispositivos

---

## Pre-requisitos

- [ ] Backend desplegado con migraciones al día
- [ ] Comercio de prueba con productos activos y tienda OPEN
- [ ] Conductor verificado (`verification_status=approved`) y online
- [ ] Cliente con dirección guardada dentro de zona de entrega
- [ ] FCM configurado (push en foreground/background)

---

## Flujo A — Cliente (flutter-customer)

| # | Paso | OK |
|---|------|-----|
| 1 | Login email o Google/Apple | ☐ |
| 2 | Configurar **Ubicación y radio de tiendas** (Ajustes o chip en home) | ☐ |
| 3 | Home carga tiendas dentro del radio + chips Productos/Servicios + búsqueda | ☐ |
| 4 | Detalle tienda muestra horarios/zona | ☐ |
| 5 | Catálogo: buscar servicio (ej. aseo/lavandería), filtrar categoría/subcategoría, ver imagen | ☐ |
| 6 | Detalle servicio: campos dinámicos + solicitar → checkout servicio | ☐ |
| 7 | Checkout servicio: dirección, agenda, cupón, método de pago | ☐ |
| 8 | Sandbox DTS: formulario tarjeta 4242 → recibo con comisión/neto | ☐ |
| 9 | Pedido `payment_status=paid` en API + tab Pedidos | ☐ |
| 10 | Tracking mapa muestra ETA | ☐ |
| 11 | Chat con conductor responde en vivo | ☐ |
| 12 | Push al cambiar estado (asignado, en camino) → abre tracking | ☐ |
| 13 | Push `chat_message` (app en background) → abre `/orders/{id}/chat` | ☐ |

## Flujo A2 — Cliente delivery (opcional)

| # | Paso | OK |
|---|------|-----|
| 1 | Catálogo productos físicos → carrito → checkout delivery | ☐ |
| 2 | Método QR/efectivo o sandbox según entorno | ☐ |

---

## Flujo B — Conductor (flutter-driver)

| # | Paso | OK |
|---|------|-----|
| 1 | Login + toggle online + GPS con ubicación real | ☐ |
| 2 | Configurar **Zona de trabajo** (centro + radio) y ponerse online | ☐ |
| 3 | Pedido `READY_FOR_PICKUP` con tienda **dentro** de la zona → push + ringtone + modal oferta | ☐ |
| 4 | Conductor online con tienda **fuera** de su zona no recibe push/oferta | ☐ |
| 5 | Acepta → mapa activo pickup/dropoff | ☐ |
| 6 | Chat con cliente | ☐ |
| 7 | Push `chat_message` del cliente → abre chat del pedido | ☐ |
| 8 | Marca entregado + foto proof of delivery | ☐ |
| 9 | Ganancias reflejan pedido entregado | ☐ |

---

## Flujo C — Merchant (web-admin / API)

| # | Paso | OK |
|---|------|-----|
| 1 | Dashboard muestra KPI **Cobrado hoy** tras sandbox-pay | ☐ |
| 2 | Tabla pedidos muestra badge `payment_status` (Pagado/Pendiente) | ☐ |
| 3 | Detalle/card pedido servicio muestra referencia de pago | ☐ |
| 4 | Confirma pago manual (QR/efectivo) si aplica | ☐ |
| 5 | Detalle pedido → **Chat del pedido** (cliente/conductor) | ☐ |
| 6 | Tras Preparado, lista se refresca sola (poll 10s) | ☐ |
| 7 | Pedidos de servicio también hacen poll 10s | ☐ |

---

## Flujo D — Sync push (zona de trabajo + chat)

| # | Paso | OK |
|---|------|-----|
| 1 | Merchant marca `READY_FOR_PICKUP` | ☐ |
| 2 | Solo drivers online cuya zona de trabajo cubre la tienda reciben FCM `ready_for_pickup` | ☐ |
| 3 | Driver foreground: tono custom + `IncomingOfferScreen` | ☐ |
| 4 | Mensaje chat REST/WS → push a los **otros** participantes (`type=chat_message`) | ☐ |
| 5 | Cliente lista pedidos se actualiza sin pull (poll ~10s / resume) | ☐ |
| 6 | Mapa cliente actualiza status + destino vía WS/poll | ☐ |
| 7 | Conductor en `on_the_way` ve dropoff GPS del cliente | ☐ |
| 5 | Tap push chat en customer y driver abre la pantalla de chat | ☐ |

---

## Flujo E — Push por estado (aceptado → preparación → listo)

Precondiciones: Celery worker up; `FIREBASE_*` = **dtsdrop** en API+worker; `DeviceToken` activo tras login; conductor online con zona de trabajo que cubre la tienda.

| # | Paso | OK |
|---|------|-----|
| 1 | Cliente crea pedido delivery | ☐ |
| 2 | Merchant **Aceptar** → push cliente “Pedido aceptado” | ☐ |
| 3 | Merchant **En preparación** → push cliente | ☐ |
| 4 | Merchant **Preparado** → push a conductores en zona (fuera de zona no) | ☐ |
| 5 | Logs worker: `push_dispatch` / `push_sent` (no `push_no_device_token` / `skipped`) | ☐ |

Detalle ops: `docs/PUSH_NOTIFICATIONS.md` → checklist Railway.

---

## Criterio de éxito

Los 3 roles completan un pedido real sin intervención manual en base de datos. Push de oferta (zona de trabajo del conductor + ringtone) y chat deep link funcionan en cliente y conductor. El listado de tiendas del cliente respeta su radio de búsqueda configurado.
