# Tareas Detalladas — DTS Delivery Platform

Cada tarea incluye: **ID**, **proyecto**, **descripción**, **archivos clave** y **tests unitarios obligatorios**.

**Convención de IDs:** `T<fase>.<bloque>.<tarea>`  
**Ejecutar:** `/tarea T1.2.1` en Cursor

---

## FASE 1 — Backend: Arquitectura y Modelado

### Bloque 1.1 — Setup del proyecto

| ID | Tarea | Tests |
|----|-------|-------|
| T1.1.1 | Inicializar `backend/` con `uv init`, Django 5.x, DRF, django-environ | `tests/test_settings.py`: settings cargan sin error |
| T1.1.2 | Configurar PostGIS (django.contrib.gis), Redis URL en settings | `tests/test_db.py`: conexión DB mock |
| T1.1.3 | Estructura `features/` + `core/` + registro dinámico de apps | `tests/test_apps.py`: todas las apps registradas |
| T1.1.4 | pytest + pytest-django + factory_boy + coverage | `pytest.ini` configurado; `make test` pasa vacío |

### Bloque 1.2 — Módulo `accounts`

| ID | Tarea | Tests |
|----|-------|-------|
| T1.2.1 | `domain/entities.py`: UserRole enum (SUPER_ADMIN, MERCHANT, DRIVER, CUSTOMER) | `test_user_role_values` |
| T1.2.2 | `domain/value_objects.py`: Email, Phone validados | `test_email_invalid_raises`, `test_phone_format` |
| T1.2.3 | `infrastructure/models.py`: CustomUser (AbstractUser) + OneToOne profiles | `test_create_user_per_role` |
| T1.2.4 | `infrastructure/models.py`: MerchantProfile, DriverProfile, CustomerProfile | `test_profile_creation` |
| T1.2.5 | `application/use_cases/register_user.py` | `test_register_merchant`, `test_register_duplicate_email` |
| T1.2.6 | `infrastructure/serializers.py` + `views.py`: registro y login JWT | `test_login_returns_token`, `test_register_201` |
| T1.2.7 | Permisos DRF por rol (`IsMerchant`, `IsDriver`, etc.) | `test_merchant_cannot_access_admin` |
| T1.2.8 | `DeviceToken` model + API registrar token FCM (`POST /accounts/device-token/`) | `test_register_device_token`, `test_unregister_device_token` |

> **T1.2.8** es prerequisito de push (Fase 2). Ejecutar antes de `T2.4.x`. Ver [PUSH_NOTIFICATIONS.md](PUSH_NOTIFICATIONS.md).

### Bloque 1.3 — Módulo `stores`

| ID | Tarea | Tests |
|----|-------|-------|
| T1.3.1 | `domain/entities.py`: Store entity con estado Open/Closed | `test_store_toggle_status` |
| T1.3.2 | `domain/value_objects.py`: GeoLocation (lat, lng) | `test_geolocation_validation` |
| T1.3.3 | `infrastructure/models.py`: Store con PointField (PostGIS) | `test_store_save_with_location` |
| T1.3.4 | `application/use_cases/create_store.py`, `update_store_status.py` | `test_create_store_use_case`, `test_close_store` |
| T1.3.5 | API: CRUD stores (solo merchant dueño) | `test_list_stores_public`, `test_merchant_update_own_store` |

### Bloque 1.4 — Módulo `products`

> **Catálogo dual:** productos físicos (comida, artículos) **y servicios a domicilio** (limpieza, reparaciones).  
> Ver [PRODUCTS_AND_SERVICES.md](PRODUCTS_AND_SERVICES.md) para diseño completo, flujos y matriz de avance.

| ID | Tarea | Tests |
|----|-------|-------|
| T1.4.1 | `domain/entities.py`: `Product`, `Category` (jerarquía 2 niveles), `ProductType` (PHYSICAL/SERVICE), campos servicio (`duration_minutes`, `requires_on_site_visit`) | `test_product_price_positive`, `test_category_hierarchy`, `test_service_product_on_site_visit` |
| T1.4.2 | `domain/services.py`: StockValidator — solo aplica a `ProductType.PHYSICAL` | `test_insufficient_stock_raises`, `test_service_skips_stock_validation` |
| T1.4.3 | `infrastructure/models.py`: Category (FK self `parent`), Product (`product_type`, `duration_minutes`) FK Store | `test_product_belongs_to_store`, `test_category_subcategory_hierarchy` |
| T1.4.4 | `application/use_cases/manage_product.py`: CRUD producto/servicio; `manage_category.py`: CRUD categoría/subcategoría | `test_create_product`, `test_create_service`, `test_deactivate_product`, `test_create_subcategory` |
| T1.4.5 | API: árbol categorías + listar/filtrar por store, tipo y categoría; CRUD merchant | `test_list_products_by_store`, `test_list_categories_tree`, `test_unauthorized_crud` |

### Bloque 1.5 — Módulo `orders` (corazón del sistema)

| ID | Tarea | Tests |
|----|-------|-------|
| T1.5.1 | `domain/value_objects.py`: OrderStatus enum completo | `test_all_status_values_defined` |
| T1.5.2 | `domain/services.py`: OrderStateMachine — transiciones válidas | `test_valid_transition_created_to_accepted`, `test_invalid_transition_raises` |
| T1.5.3 | `domain/entities.py`: Order, OrderItem | `test_order_total_calculation` |
| T1.5.4 | `infrastructure/models.py`: Order, OrderItem, FK Customer/Store/Driver | `test_order_persistence` |
| T1.5.5 | `application/use_cases/create_order.py` | `test_create_order_with_items`, `test_empty_cart_fails` |
| T1.5.6 | `application/use_cases/transition_order_status.py` | `test_merchant_accepts_order`, `test_customer_cannot_accept` |
| T1.5.7 | API: crear pedido, listar por rol, cambiar estado | `test_order_api_flow` |
| T1.5.8 | `domain/value_objects.py`: `OrderType` (DELIVERY/SERVICE), `ServiceOrderDetails` (address, scheduled_at, notes) | `test_service_order_details_validation` |
| T1.5.9 | `domain/services.py`: ServiceOrderStateMachine (sin conductor; estados SCHEDULED → COMPLETED) | `test_service_order_valid_transitions`, `test_service_order_skips_driver_states` |
| T1.5.10 | API: checkout servicio con dirección cliente y notas; crear pedido tipo SERVICE | `test_create_service_order_api`, `test_service_order_requires_address` |

**Estados OrderStatus (productos físicos — delivery):**
```
CREATED → ACCEPTED_BY_MERCHANT → IN_PREPARATION → READY_FOR_PICKUP
→ SEARCHING_DRIVER → DRIVER_ASSIGNED → PICKED_UP → ON_THE_WAY → DELIVERED
(CANCELLED en cualquier punto previo a PICKED_UP)
```

**Estados pedido servicio (sin conductor de plataforma):**
```
CREATED → ACCEPTED_BY_MERCHANT → SCHEDULED → PROVIDER_EN_ROUTE
→ IN_PROGRESS → COMPLETED
(CANCELLED en cualquier punto previo a IN_PROGRESS)
```

> Detalle de campos y reglas: [PRODUCTS_AND_SERVICES.md](PRODUCTS_AND_SERVICES.md)

### Bloque 1.6 — Módulo `delivery`

| ID | Tarea | Tests |
|----|-------|-------|
| T1.6.1 | `domain/entities.py`: DeliveryTracking, TrackingPoint | `test_tracking_point_sequence` |
| T1.6.2 | `infrastructure/models.py`: DeliveryTracking + TrackingPoint | `test_save_tracking_points` |
| T1.6.3 | `application/use_cases/record_location.py` | `test_record_driver_location` |
| T1.6.4 | API: POST ubicación (driver), GET historial (customer) | `test_driver_posts_location`, `test_customer_reads_tracking` |

### Bloque 1.7 — API global

| ID | Tarea | Tests |
|----|-------|-------|
| T1.7.1 | Router central `core/urls.py` versionado `/api/v1/` | `test_api_version_prefix` |
| T1.7.2 | drf-spectacular OpenAPI schema | `test_schema_generates` |
| T1.7.3 | Paginación, filtros, throttling básico | `test_pagination`, `test_throttle` |

---

## FASE 2 — Celery + Signals

### Bloque 2.1 — Infraestructura async

| ID | Tarea | Tests |
|----|-------|-------|
| T2.1.1 | Celery app en `core/celery.py`, broker Redis | `test_celery_app_loads` |
| T2.1.2 | Celery Beat schedule base | `test_beat_schedule_defined` |
| T2.1.3 | `CELERY_TASK_ALWAYS_EAGER` en tests | tasks ejecutan sincrónicamente en CI |

### Bloque 2.2 — Signals en orders

| ID | Tarea | Tests |
|----|-------|-------|
| T2.2.1 | `infrastructure/signals.py`: detectar cambio de status en post_save | `test_signal_fires_on_status_change` |
| T2.2.2 | Signal READY_FOR_PICKUP → encola `assign_driver_task` | `test_signal_enqueues_assign_driver` |
| T2.2.3 | Signal ON_THE_WAY → encola `notify_customer_task` | `test_signal_enqueues_notification` |
| T2.2.4 | Signal ACCEPTED_BY_MERCHANT → push al cliente | `test_signal_push_order_accepted` |
| T2.2.5 | Signal READY_FOR_PICKUP → push a conductores online | `test_signal_push_new_order_to_drivers` |

### Bloque 2.3 — Asignación de conductores

| ID | Tarea | Tests |
|----|-------|-------|
| T2.3.1 | `domain/services.py`: DriverMatcher (conductores online + distancia) | `test_find_nearest_driver`, `test_no_driver_available` |
| T2.3.2 | `infrastructure/tasks.py`: `assign_driver_task` | `test_task_assigns_nearest`, `test_task_retries` |
| T2.3.3 | Actualizar OrderStatus a SEARCHING_DRIVER → DRIVER_ASSIGNED | `test_status_after_assignment` |

### Bloque 2.4 — Notificaciones Push + Email

> Flujo completo: [PUSH_NOTIFICATIONS.md](PUSH_NOTIFICATIONS.md)

| ID | Tarea | Tests |
|----|-------|-------|
| T2.4.1 | `features/notifications/domain`: NotificationType enum + PushTemplate | `test_notification_types`, `test_push_template_for_status` |
| T2.4.2 | `infrastructure/fcm_client.py`: cliente FCM (firebase-admin, mock en tests) | `test_fcm_client_send_mock` |
| T2.4.3 | `application/use_cases/send_push.py` + Celery `send_push_task` | `test_send_push_task_calls_fcm` |
| T2.4.4 | `domain/services.py`: OrderStatusNotificationMapper (status → destinatario) | `test_mapper_on_the_way_notifies_customer` |
| T2.4.5 | Signal genérico post_save Order → `dispatch_order_push_task` | `test_any_status_change_dispatches_push` |
| T2.4.6 | Caso `ON_THE_WAY`: push "¡Tu pedido ya salió!" al cliente | `test_push_sent_on_the_way` |
| T2.4.7 | `infrastructure/tasks.py`: send_email_notification (Mailpit dev) | `test_email_template_rendered` |

### Bloque 2.5 — Analytics (Celery Beat)

| ID | Tarea | Tests |
|----|-------|-------|
| T2.5.1 | `features/analytics/domain`: DailyReport entity | `test_report_aggregation_logic` |
| T2.5.2 | `infrastructure/models.py`: DailySalesReport, DriverCommission | `test_report_persistence` |
| T2.5.3 | `infrastructure/tasks.py`: `calculate_daily_stats` (cron 02:00) | `test_nightly_stats_task` |

---

## FASE 3 — Frontend Web (Next.js + Tailwind)

### Bloque 3.1 — Web Merchant: productos

| ID | Tarea | Tests |
|----|-------|-------|
| T3.1.1 | `web-admin/`: layout base Next.js App Router + Tailwind + auth guard por rol | `merchant_layout_renders_test` |
| T3.1.2 | UI CRUD productos **y servicios** (formulario condicional por `product_type`) consumiendo API backend | `merchant_create_product_flow_test`, `merchant_create_service_flow_test` |
| T3.1.3 | UI gestión inventario / stock (solo PHYSICAL) | `merchant_update_stock_flow_test`, `merchant_cannot_set_stock_on_service_test` |
| T3.1.4 | UI CRUD categorías y subcategorías por tienda | `merchant_create_category_flow_test`, `merchant_create_subcategory_flow_test` |
| T3.1.5 | Dashboard pedidos de servicio (aceptar, agendar, en curso, completado) | `merchant_service_order_dashboard_test` |

### Bloque 3.2 — Web Merchant: pedidos

| ID | Tarea | Tests |
|----|-------|-------|
| T3.2.1 | Dashboard pedidos entrantes (tabla + filtros por estado) | `merchant_orders_list_test` |
| T3.2.2 | Acciones Aceptar / Preparado con mutate API y feedback UI | `merchant_accept_order_action_test` |
| T3.2.3 | Actualización periódica cada 10s (polling) o suscripción realtime | `merchant_orders_auto_refresh_test` |

### Bloque 3.3 — Web Super Admin: métricas

| ID | Tarea | Tests |
|----|-------|-------|
| T3.3.1 | Dashboard KPIs super admin (solo rol SUPER_ADMIN) | `admin_dashboard_role_guard_test` |
| T3.3.2 | Gráficos ventas, comercios activos, tiempo entrega | `admin_metrics_widgets_test` |

### Bloque 3.4 — Web Super Admin: pagos

| ID | Tarea | Tests |
|----|-------|-------|
| T3.4.1 | Vista comisiones por comercio y conductor | `commission_list_page_test` |
| T3.4.2 | Export CSV reportes | `export_commissions_csv_test` |

### Bloque 3.5 — Marketing

| ID | Tarea | Tests |
|----|-------|-------|
| T3.5.1 | `features/marketing/domain`: Coupon, Banner entities | `test_coupon_discount_calculation` |
| T3.5.2 | CRUD cupones en web admin | `admin_create_coupon_flow_test` |
| T3.5.3 | API pública banners activos para app cliente | `test_active_banners_api` |

---

## FASE 4 — Flutter

### Bloque 4.1 — Cliente: core + auth

| ID | Tarea | Tests |
|----|-------|-------|
| T4.1.1 | Setup `flutter-customer/` con estructura features/ | `flutter test` pasa |
| T4.1.2 | `core/network`: ApiClient, interceptors JWT | `api_client_adds_auth_header_test` |
| T4.1.3 | `features/auth/domain`: LoginUseCase | `login_usecase_success_test`, `login_usecase_failure_test` |
| T4.1.4 | `features/auth/presentation`: LoginScreen | `login_screen_widget_test` |
| T4.1.5 | Firebase setup cliente (`firebase_core`, `firebase_messaging`) | `firebase_init_test` |

### Bloque 4.2 — Cliente: stores

| ID | Tarea | Tests |
|----|-------|-------|
| T4.2.1 | `features/stores/domain`: GetStoresUseCase | `get_stores_usecase_test` |
| T4.2.2 | `features/stores/infrastructure`: StoresRepositoryImpl | `stores_repository_maps_dto_test` |
| T4.2.3 | `features/stores/presentation`: StoreListScreen | `store_list_shows_stores_test` |

### Bloque 4.3 — Cliente: catalog

| ID | Tarea | Tests |
|----|-------|-------|
| T4.3.1 | `features/catalog/domain`: GetProductsByStoreUseCase (filtro tipo/categoría) | `get_products_usecase_test` |
| T4.3.2 | ProductDetailScreen + agregar al carrito | `add_to_cart_from_catalog_test` |
| T4.3.3 | Filtros categoría/subcategoría y badge Physical/Service en catálogo | `catalog_filter_by_category_test` |
| T4.3.4 | ServiceDetailScreen: duración, descripción, botón solicitar | `service_detail_screen_test` |

### Bloque 4.4 — Cliente: cart + checkout

| ID | Tarea | Tests |
|----|-------|-------|
| T4.4.1 | `features/cart/domain`: Cart entity, AddItemUseCase | `cart_add_item_test`, `cart_total_test` |
| T4.4.2 | `features/checkout/domain`: CreateOrderUseCase | `create_order_usecase_test` |
| T4.4.3 | CheckoutScreen confirma pedido | `checkout_flow_widget_test` |
| T4.4.4 | Checkout servicio: dirección cliente + notas + horario preferido | `service_checkout_flow_test` |
| T4.4.5 | Seguimiento pedido servicio (estados sin conductor) | `service_order_tracking_test` |

### Bloque 4.5 — Cliente: tracking

| ID | Tarea | Tests |
|----|-------|-------|
| T4.5.1 | `features/tracking/domain`: GetTrackingUseCase | `get_tracking_usecase_test` |
| T4.5.2 | TrackingMapScreen con Google Maps | `tracking_map_widget_test` |
| T4.5.3 | Registrar token FCM en backend tras login | `register_fcm_token_usecase_test` |
| T4.5.4 | Push handler foreground/background/tap | `push_notification_handler_test` |
| T4.5.5 | Deep link: push `ON_THE_WAY` → TrackingMapScreen | `push_opens_tracking_screen_test` |

### Bloque 4.6 — Conductor: core + auth

| ID | Tarea | Tests |
|----|-------|-------|
| T4.6.1 | Setup `flutter-driver/` estructura features/ | `flutter test` pasa |
| T4.6.2 | Login conductor (mismo patrón que cliente) | `driver_login_usecase_test` |

### Bloque 4.7 — Conductor: availability

| ID | Tarea | Tests |
|----|-------|-------|
| T4.7.1 | `features/availability/domain`: ToggleOnlineUseCase | `toggle_online_usecase_test` |
| T4.7.2 | UI switch en línea / fuera de línea | `availability_switch_widget_test` |

### Bloque 4.8 — Conductor: orders

| ID | Tarea | Tests |
|----|-------|-------|
| T4.8.1 | `features/orders/domain`: AcceptOrder, ConfirmPickup, ConfirmDelivery | `accept_order_usecase_test` |
| T4.8.2 | Alerta nuevo pedido (FCM handler) | `new_order_notification_handler_test` |
| T4.8.3 | Flujo completo pantallas pedido | `driver_order_flow_widget_test` |

### Bloque 4.9 — Conductor: location

| ID | Tarea | Tests |
|----|-------|-------|
| T4.9.1 | `features/location/domain`: SendLocationUseCase | `send_location_usecase_test` |
| T4.9.2 | Background location service (cada 10s) | `location_service_interval_test` |
| T4.9.3 | Permisos ubicación (mock geolocator) | `location_permission_test` |

---

## FASE 5 — Tracking Tiempo Real

| ID | Tarea | Tests |
|----|-------|-------|
| T5.1.1 | Django Channels + channels-redis en `core/asgi.py` | `test_asgi_application_loads` |
| T5.1.2 | `features/delivery/infrastructure/consumers.py`: TrackingConsumer | `test_consumer_connect_auth` |
| T5.2.1 | Driver envía lat/lng por WS; server broadcast a room del pedido | `test_location_broadcast_to_customer` |
| T5.3.1 | Cliente: WebSocket datasource en tracking | `tracking_ws_datasource_test` |
| T5.4.1 | Conductor: emitir ubicación por WS | `driver_ws_emit_location_test` |
| T5.5.1 | Doc alternativa Firebase en `docs/FIREBASE_TRACKING.md` | — |

---

## Cómo marcar progreso

Crea `docs/PROGRESS.md` o dile al agente:

```
/tarea T1.2.1
```

Al completar una tarea, el agente debe:
1. Implementar código
2. Escribir tests listados
3. Ejecutar tests y confirmar verde
4. Marcar `[x]` en PROGRESS.md
