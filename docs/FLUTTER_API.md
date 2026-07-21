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
| GET | `/stores/{id}/products/` | `type` (`physical`\|`service`), `category`, `subcategory`, `search` |
| GET | `/stores/{id}/products/{product_id}/public/` | Detalle público: imágenes, variantes, `duration_minutes`, `dynamic_values`, `field_config` |
| GET | `/stores/{id}/categories/` | árbol categorías |

## Pedidos (cliente)

| Método | Ruta | Body |
|--------|------|------|
| POST | `/orders/` | `{ "store_id", "items": [{ "product_id", "quantity" }], "delivery_address"?, "customer_notes"?, "latitude"?, "longitude"?, "payment_method_id"?, "coupon_code"? }` |
| POST | `/orders/service/` | items + `service_address`, `customer_notes`, `scheduled_at`, `latitude`?, `longitude`?, `payment_method_id`?, `coupon_code`? |
| GET | `/orders/` | pedidos del usuario |
| GET | `/orders/{id}/` | detalle enriquecido (cliente, conductor asignado, comercio, super_admin) |
| PATCH | `/orders/{id}/` | `{ "status" }` |
| POST | `/orders/{id}/sandbox-pay/` | `{ "card_last4"?, "sandbox_reference"? }` — solo si `PAYMENT_SANDBOX_ENABLED=true`; marca `payment_status=paid` y devuelve recibo contable |
| GET | `/sandbox-config/` | `{ "enabled": true\|false }` — indica si el sandbox DTS está activo |

## Perfil cliente (pro)

| Método | Ruta | Body / respuesta |
|--------|------|------------------|
| GET/PATCH | `/accounts/customer/profile/` | `full_name`, `phone`, `photo_url`, `default_address` — solo rol `customer` |
| GET | `/accounts/customer/addresses/` | Lista direcciones guardadas |
| POST | `/accounts/customer/addresses/` | `{ "label", "address", "latitude", "longitude", "is_default"? }` |
| PATCH | `/accounts/customer/addresses/{id}/` | Actualizar campos parciales |
| DELETE | `/accounts/customer/addresses/{id}/` | Eliminar dirección |

`full_name` en perfil usa el valor guardado; si está vacío, cae a `first_name`/`last_name` del usuario o `username`.

Solo una dirección puede tener `is_default=true` por usuario; al marcar otra, la anterior se desmarca.

## Post-MVP — tiendas, pagos, marketplace

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/stores/{id}/public/` | Detalle tienda + horarios + zonas + `accepts_orders` |
| GET | `/stores/{id}/coverage/?latitude=&longitude=` | Verifica cobertura |
| GET/PUT | `/stores/{id}/opening-hours/` | Horarios semanales (merchant) |
| GET/POST | `/stores/{id}/delivery-zones/` | Zonas de entrega (merchant) |
| GET/POST | `/stores/{id}/payment-methods/` | Métodos de pago (público GET; incluye método virtual `sandbox` si `PAYMENT_SANDBOX_ENABLED=true`) |
| POST | `/orders/{id}/confirm-payment/` | Merchant confirma pago |
| POST | `/orders/{id}/sandbox-pay/` | Cliente simula pago tarjeta (sandbox DTS) |
| GET | `/sandbox-config/` | Flag sandbox activo |
| POST | `/marketing/coupons/validate/` | `{ "code", "order_total" }` |
| GET/POST | `/stores/{id}/reviews/` | Reseñas tienda |
| GET/POST | `/accounts/customer/favorites/` | Favoritos cliente |
| GET/POST | `/accounts/driver/payouts/` | Retiros conductor |
| POST | `/orders/{id}/proof-of-delivery/` | Foto entrega (driver) |
| PATCH | `/accounts/admin/drivers/{id}/verification/` | KYC admin |

Tracking incluye `eta_minutes` en `GET /orders/{id}/tracking/`.

### Detalle de pedido (cliente)

`GET /orders/{id}/` para el cliente dueño del pedido incluye además de los campos base:

```json
{
  "delivery_address": "Calle 50 # 10-20",
  "delivery_latitude": 4.65,
  "delivery_longitude": -74.08,
  "customer_notes": "Tocar timbre",
  "driver_name": "Carlos Conductor",
  "driver_phone": "+573009998877"
}
```

`driver_name` / `driver_phone` solo aparecen cuando hay conductor asignado. `delivery_*` usa la dirección del pedido (`service_address` + coords) o la del comercio si no se envió al crear.

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
| GET | `/accounts/driver/earnings/` | Query `period=today\|week\|month` — comisiones 10% sobre pedidos `delivered` |
| GET | `/delivery/offers/` | Pedidos en `searching_driver` cercanos (excluye rechazos) |
| POST | `/delivery/offers/{id}/accept/` | First-wins → `driver_assigned` (409 si ya tomado) |
| POST | `/delivery/offers/{id}/reject/` | No volver a ofrecer ese pedido al conductor |
| GET | `/orders/` | Pedidos asignados (`driver_id`) |
| GET | `/orders/{id}/` | Detalle enriquecido: tienda, teléfono cliente, dirección/coords entrega, `driver_earning` |
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

## Detalle de pedido y ganancias (conductor)

### `GET /orders/{id}/`

Autorizado para: cliente del pedido, conductor asignado, dueño del comercio o `super_admin`.

Campos extra respecto a la lista:

```json
{
  "store_name": "Tienda Demo",
  "store_latitude": 4.711,
  "store_longitude": -74.0721,
  "store_address": "Calle 100",
  "customer_phone": "+573001234567",
  "delivery_address": "Calle 50 # 10-20",
  "delivery_latitude": 4.65,
  "delivery_longitude": -74.08,
  "driver_earning": "10.00"
}
```

`delivery_address` / coords usan `service_address` y coordenadas de servicio si existen; si no, la dirección y ubicación del comercio. `driver_earning` = 10% de `total`.

## App conductor — mapa comercios

Tab **Inicio** (`DriverHomeMapScreen`): además de ofertas activas, la app carga `GET /stores/` y pinta un marcador por comercio activo con ubicación válida.

| Marcador | Color | Significado |
|----------|-------|-------------|
| Azul | Conductor (GPS) |
| Naranja | Comercio abierto |
| Violeta | Comercio cerrado |
| Rojo | Oferta / pedido pendiente (prioridad sobre el pin del comercio) |

Al tocar un comercio → bottom sheet con nombre, dirección, teléfono (tap para llamar) y **Cómo llegar** (Google Maps externo vía `url_launcher`).

Toggle **Mostrar comercios** en la tarjeta superior oculta/muestra el layer de tiendas sin afectar ofertas.

Query opcional soportada por backend: `GET /stores/?status=open` (no usada en v1; filtra en cliente por `is_open`).

Campos usados del listado:

```json
{
  "id": 1,
  "name": "Tienda Demo",
  "latitude": 4.711,
  "longitude": -74.0721,
  "address": "Calle 100",
  "phone": "+573001234567",
  "logo_url": "https://…",
  "is_open": true,
  "status": "open",
  "vertical": "restaurant"
}
```

### `GET /accounts/driver/earnings/?period=today|week|month`

Solo rol `driver`. Cuenta pedidos `delivered` del conductor en el periodo (zona horaria del servidor).

```json
{
  "period": "today",
  "delivery_count": 3,
  "total_earnings": "12.50",
  "currency": "COP",
  "breakdown": [
    {
      "order_id": 1,
      "completed_at": "2026-07-19T15:30:00Z",
      "order_total": "100.00",
      "earning": "10.00"
    }
  ]
}
```

`completed_at` corresponde a `updated_at` del pedido al marcar `delivered`.
