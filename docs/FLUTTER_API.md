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
| POST | `/accounts/register/` | customer fields | `201` user |
| POST | `/accounts/device-token/` | `{ "token", "platform" }` | `201` |

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

Fase 4: cliente hace **polling** GET cada 5–10s. WebSocket en Fase 5.

## Conductor

| Método | Ruta | Body |
|--------|------|------|
| PATCH | `/accounts/driver/availability/` | `{ "is_online", "latitude?", "longitude?" }` |
| GET | `/orders/` | pedidos asignados (`driver_id`) |
| PATCH | `/orders/{id}/` | transiciones de estado |

## Medios

URLs de imagen vienen absolutas desde API (`MEDIA_PUBLIC_BASE_URL`). Usar tal cual en `<Image.network>`.

## Push (FCM)

Payload sugerido en notificaciones:

```json
{
  "order_id": "42",
  "type": "ON_THE_WAY"
}
```

Ver [PUSH_NOTIFICATIONS.md](PUSH_NOTIFICATIONS.md).
