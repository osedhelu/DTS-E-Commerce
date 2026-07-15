# API móvil — Flutter Cliente y Conductor

**Base URL staging (Railway):**

```
https://dts-backend-production-c84e.up.railway.app/api/v1
```

Configurar en `lib/core/config/env.dart` de cada app.

## Autenticación

| Método | Ruta | Body | Respuesta |
|--------|------|------|-----------|
| POST | `/accounts/login/` | `{ "username", "password" }` | `{ "access", "refresh" }` + claims JWT (`role`, `email`, `user_id`) |
| POST | `/accounts/refresh/` | `{ "refresh" }` | `{ "access" }` |
| POST | `/accounts/register/` | `{ username, email, password, role, phone?, … }` (`role`: `customer`\|`driver`) | `201` user |
| POST | `/accounts/auth/google/` | `{ "id_token", "role"? }` — Firebase ID token; `role` default `customer`; conductor usa `driver` (proyecto dtsdrop) | `{ "access", "refresh" }` + claims JWT (`role`, `email`, `user_id`) |
| POST | `/accounts/auth/apple/` | `{ "id_token", "role"?, "email"?, "full_name"? }` — mismo patrón; `email`/`full_name` solo en el primer Sign in with Apple | `{ "access", "refresh" }` + claims JWT (`role`, `email`, `user_id`) |
| POST | `/accounts/device-token/` | `{ "token", "platform" }` | `201` |

Firebase: cliente = `discorp-4a37b`, conductor = `dtsdrop-85330`. El backend verifica el ID token **solo** con la app Admin del proyecto correspondiente al `role` (sin fallback cruzado). Apple sin email: usuario existente por `apple_uid`; alta nueva usa `email` del body o placeholder `{uid}@privaterelay.appleid.local`.

Header autenticado: `Authorization: Bearer <access>`

## Stores (cliente)

| Método | Ruta | Notas |
|--------|------|-------|
| GET | `/stores/` | Lista pública de comercios abiertos |

## Catálogo (cliente)

| Método | Ruta | Query |
|--------|------|-------|
| GET | `/stores/{id}/products/` | `product_type`, `category_id` |
| GET | `/stores/{id}/categories/` | árbol categorías |

## Pedidos (cliente)

| Método | Ruta | Body |
|--------|------|------|
| POST | `/orders/` | `{ "store_id", "items": [{ "product_id", "quantity" }] }` |
| POST | `/orders/service/` | items + `service_address`, `customer_notes`, `scheduled_at` |
| GET | `/orders/` | pedidos del usuario |
| PATCH | `/orders/{id}/` | `{ "status" }` |

## Tracking

| Método | Ruta | Rol |
|--------|------|-----|
| GET | `/orders/{id}/tracking/` | customer (su pedido) |
| POST | `/orders/{id}/tracking/` | driver (lat/lng) |
| WS | `wss://{host}/ws/orders/{id}/tracking/?token={jwt}` | customer / driver |

Mensaje entrante (broadcast conductor):

```json
{ "type": "location", "order_id": 42, "latitude": 4.71, "longitude": -74.07, "sequence": 1 }
```

Cliente: REST inicial + WebSocket; polling cada 8s solo si WS no conecta.

Conductor (emitir ubicación):

```json
{ "type": "location", "latitude": 4.71, "longitude": -74.07 }
```

Enviar por la misma conexión WS del pedido activo; REST POST como respaldo.

Alternativa Firestore (no implementada): [FIREBASE_TRACKING.md](FIREBASE_TRACKING.md).

## Conductor

| Método | Ruta | Body / notas |
|--------|------|----------------|
| GET/PATCH | `/accounts/driver/profile/` | KYC: `full_name`, `phone`, `vehicle_type` (`moto`\|`carro`\|`bici`), `vehicle_plate`, `license_number`, `complete_onboarding` → respuesta incluye `onboarding_completed` |
| PATCH | `/accounts/driver/availability/` | `{ "is_online", "latitude?", "longitude?" }` |
| GET | `/delivery/offers/` | Pedidos en `searching_driver` cercanos (excluye rechazos) |
| POST | `/delivery/offers/{id}/accept/` | First-wins → `driver_assigned` (409 si ya tomado) |
| POST | `/delivery/offers/{id}/reject/` | No volver a ofrecer ese pedido al conductor |
| GET | `/orders/` | Pedidos asignados (`driver_id`) |
| PATCH | `/orders/{id}/` | Transiciones: `picked_up`, `on_the_way`, `delivered` |
| GET/POST | `/orders/{id}/messages/` | Chat conductor ↔ cliente |
| WS | `/ws/orders/{id}/chat/?token=` | `{ "type": "message", "body": "..." }` |

Flujo de asignación: `ready_for_pickup` → task abre `searching_driver` + push a online drivers → accept manual. Beat `auto-assign-stale-orders` hace fallback auto-nearest tras ~3 min sin accept.

`DRIVER_ASSIGNED` push: cliente + conductor asignado.

## Tracking (respuesta enriquecida)

`GET /orders/{id}/tracking/` ahora incluye además de `points`:

```json
{
  "order_status": "on_the_way",
  "status": "on_the_way",
  "is_live": true,
  "driver_latitude": 4.71,
  "driver_longitude": -74.07,
  "destination_latitude": 4.65,
  "destination_longitude": -74.08,
  "points": []
}
```

Ubicación en vivo solo mientras `driver_assigned` / `picked_up` / `on_the_way`.

## Medios

URLs de imagen vienen absolutas desde API (`MEDIA_PUBLIC_BASE_URL`). Usar tal cual en `<Image.network>`.

## Push (FCM)

Data payload enviado por el backend:

```json
{
  "order_id": "42",
  "type": "on_the_way",
  "order_status": "on_the_way",
  "notification_type": "order_on_the_way"
}
```

- `type` / `order_status`: valor de `OrderStatus` (p. ej. `on_the_way`, `ready_for_pickup`).
- `notification_type`: plantilla interna FCM.
- Pedidos `ready_for_pickup` → push a conductores online (`notify_drivers_new_order_task` / FCM proyecto dtsdrop).

Ver [PUSH_NOTIFICATIONS.md](PUSH_NOTIFICATIONS.md).
