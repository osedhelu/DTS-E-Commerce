# Progreso del Desarrollo

Actualiza marcando `[x]` al completar cada tarea. Usa `/tarea T1.x.x` para implementar.

## Fase 1 — Backend Fundamentos

### Bloque 1.1 Setup
- [x] T1.1.1 Proyecto Django + uv
- [x] T1.1.2 PostGIS + Redis config
- [x] T1.1.3 Estructura features/
- [x] T1.1.4 pytest + coverage

### Bloque 1.2 Accounts
- [x] T1.2.1 UserRole enum
- [x] T1.2.2 Email, Phone value objects
- [x] T1.2.3 CustomUser model
- [x] T1.2.4 Perfiles por rol
- [x] T1.2.5 Register use case
- [x] T1.2.6 Auth API JWT
- [x] T1.2.7 Permisos por rol
- [x] T1.2.8 DeviceToken FCM (antes de Fase 2 push)

### Bloque 1.3 Stores
- [x] T1.3.1 Store entity
- [x] T1.3.2 GeoLocation
- [x] T1.3.3 Store model PostGIS
- [x] T1.3.4 Use cases store
- [x] T1.3.5 API stores

### Bloque 1.4 Products
- [x] T1.4.1 Product entity (+ categorías/subcategorías, ProductType PHYSICAL/SERVICE)
- [x] T1.4.2 StockValidator (solo PHYSICAL)
- [x] T1.4.3 Product models (+ Category parent, product_type)
- [x] T1.4.4 Use cases product/servicio/categorías
- [x] T1.4.5 API catálogo (+ árbol categorías, filtros)

> Diseño dual productos/servicios: [PRODUCTS_AND_SERVICES.md](PRODUCTS_AND_SERVICES.md)

### Bloque 1.5 Orders
- [x] T1.5.1 OrderStatus enum
- [x] T1.5.2 OrderStateMachine (delivery)
- [x] T1.5.3 Order entities
- [x] T1.5.4 Order models
- [x] T1.5.5 Create order use case
- [x] T1.5.6 Transition status use case
- [x] T1.5.7 Orders API
- [x] T1.5.8 OrderType + ServiceOrderDetails
- [x] T1.5.9 ServiceOrderStateMachine
- [x] T1.5.10 API checkout servicio

### Bloque 1.6 Delivery
- [x] T1.6.1 Tracking entities
- [x] T1.6.2 Tracking models
- [x] T1.6.3 Record location use case
- [x] T1.6.4 Tracking API

### Bloque 1.7 API Global
- [x] T1.7.1 Router v1
- [ ] T1.7.2 OpenAPI
- [ ] T1.7.3 Paginación y throttle

## Fase 2 — Celery + Signals
- [ ] T2.1.1 Celery app
- [ ] T2.1.2 Celery Beat
- [ ] T2.1.3 Eager tests
- [ ] T2.2.1 Order signals
- [ ] T2.2.2 Signal assign driver
- [ ] T2.2.3 Signal notify customer
- [ ] T2.2.4 Signal push order accepted
- [ ] T2.2.5 Signal push new order to drivers
- [ ] T2.3.1 DriverMatcher
- [ ] T2.3.2 assign_driver_task
- [ ] T2.3.3 Status after assign
- [ ] T2.4.1 Notification types + templates
- [ ] T2.4.2 FCM client
- [ ] T2.4.3 SendPushUseCase + Celery task
- [ ] T2.4.4 OrderStatusNotificationMapper
- [ ] T2.4.5 Signal dispatch push on status change
- [ ] T2.4.6 Push ON_THE_WAY al cliente
- [ ] T2.4.7 Email notifications
- [ ] T2.5.1 DailyReport entity
- [ ] T2.5.2 Report models
- [ ] T2.5.3 Nightly stats task

## Fase 3 — Portales Web
- [ ] T3.1.1 Merchant layout
- [ ] T3.1.2 CRUD productos y servicios vista
- [ ] T3.1.3 Inventario vista (solo PHYSICAL)
- [ ] T3.1.4 CRUD categorías/subcategorías
- [ ] T3.1.5 Dashboard pedidos servicio
- [ ] T3.2.1 Dashboard pedidos
- [ ] T3.2.2 HTMX aceptar/preparar
- [ ] T3.2.3 Polling pedidos
- [ ] T3.3.1 Admin dashboard
- [ ] T3.3.2 KPIs métricas
- [ ] T3.4.1 Comisiones vista
- [ ] T3.4.2 Export CSV
- [ ] T3.5.1 Coupon/Banner domain
- [ ] T3.5.2 CRUD cupones
- [ ] T3.5.3 API banners

## Fase 4 — Flutter
- [ ] T4.1.1 Customer setup
- [ ] T4.1.2 ApiClient
- [ ] T4.1.3 LoginUseCase
- [ ] T4.1.4 LoginScreen
- [ ] T4.1.5 Firebase setup cliente
- [ ] T4.2.1 GetStoresUseCase
- [ ] T4.2.2 StoresRepository
- [ ] T4.2.3 StoreListScreen
- [ ] T4.3.1 GetProductsUseCase
- [ ] T4.3.2 Catalog + cart
- [ ] T4.3.3 Filtros categoría/tipo catálogo
- [ ] T4.3.4 ServiceDetailScreen
- [ ] T4.4.1 Cart domain
- [ ] T4.4.2 CreateOrderUseCase
- [ ] T4.4.3 CheckoutScreen
- [ ] T4.4.4 Checkout servicio (dirección + notas)
- [ ] T4.4.5 Seguimiento pedido servicio
- [ ] T4.5.1 GetTrackingUseCase
- [ ] T4.5.2 TrackingMapScreen
- [ ] T4.5.3 Registrar token FCM
- [ ] T4.5.4 Push handler
- [ ] T4.5.5 Deep link push → tracking
- [ ] T4.6.1 Driver setup
- [ ] T4.6.2 Driver login
- [ ] T4.7.1 ToggleOnlineUseCase
- [ ] T4.7.2 Availability switch
- [ ] T4.8.1 Order use cases
- [ ] T4.8.2 FCM handler
- [ ] T4.8.3 Driver order flow
- [ ] T4.9.1 SendLocationUseCase
- [ ] T4.9.2 Background location
- [ ] T4.9.3 Location permissions

## Fase 5 — Tiempo Real
- [ ] T5.1.1 Channels setup
- [ ] T5.1.2 TrackingConsumer
- [ ] T5.2.1 WS broadcast
- [ ] T5.3.1 Customer WS datasource
- [ ] T5.4.1 Driver WS emit
- [ ] T5.5.1 Firebase doc alternativa
