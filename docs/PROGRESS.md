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
- [x] T1.7.2 OpenAPI
- [x] T1.7.3 Paginación y throttle

## Fase 2 — Celery + Signals
- [x] T2.1.1 Celery app
- [x] T2.1.2 Celery Beat
- [x] T2.1.3 Eager tests
- [x] T2.2.1 Order signals
- [x] T2.2.2 Signal assign driver
- [x] T2.2.3 Signal notify customer
- [x] T2.2.4 Signal push order accepted
- [x] T2.2.5 Signal push new order to drivers
- [x] T2.3.1 DriverMatcher
- [x] T2.3.2 assign_driver_task
- [x] T2.3.3 Status after assign
- [x] T2.4.1 Notification types + templates
- [x] T2.4.2 FCM client
- [x] T2.4.3 SendPushUseCase + Celery task
- [x] T2.4.4 OrderStatusNotificationMapper
- [x] T2.4.5 Signal dispatch push on status change
- [x] T2.4.6 Push ON_THE_WAY al cliente
- [x] T2.4.7 Email notifications
- [x] T2.5.1 DailyReport entity
- [x] T2.5.2 Report models
- [x] T2.5.3 Nightly stats task

## Fase 3 — Frontend Web (Next.js + Tailwind)
- [x] T3.1.1 Merchant layout
- [x] T3.1.2 CRUD productos y servicios vista
- [x] T3.1.3 Inventario vista (solo PHYSICAL)
- [x] T3.1.4 CRUD categorías/subcategorías
- [x] T3.1.5 Dashboard pedidos servicio
- [x] T3.2.1 Dashboard pedidos
- [x] T3.2.2 Acciones aceptar/preparar (mutate API)
- [x] T3.2.3 Polling pedidos
- [x] T3.3.1 Admin dashboard
- [x] T3.3.2 KPIs métricas
- [x] T3.4.1 Comisiones vista
- [x] T3.4.2 Export CSV
- [x] T3.5.1 Coupon/Banner domain
- [x] T3.5.2 CRUD cupones
- [x] T3.5.3 API banners

## Fase 3 — Zustand (migración estado)
- [x] T3.6.1 Setup Zustand + lib/stores
- [x] T3.6.2 merchant-session-store + layout
- [x] T3.6.3 Migrar products
- [x] T3.6.4 Migrar inventory + categories
- [x] T3.6.5 Migrar orders + polling
- [x] T3.6.6 Migrar service-orders
- [x] T3.6.7 Migrar admin dashboard
- [x] T3.6.8 ui-store global + limpieza

## Fase 6 — Portal Comercio (Onboarding Seller)

> Guía: [MERCHANT_ONBOARDING.md](MERCHANT_ONBOARDING.md) · **Prioridad antes de Flutter**

### Bloque 6.1 — Backend registro + email
- [x] T6.1.1 EmailVerificationToken entity
- [x] T6.1.2 Token model + migración
- [x] T6.1.3 StoreVertical enum
- [x] T6.1.4 RegisterMerchantWithStoreUseCase
- [x] T6.1.5 VerifyEmailUseCase
- [x] T6.1.6 API merchant/register
- [x] T6.1.7 API verify-email
- [x] T6.1.8 Celery email verificación
- [x] T6.1.9 API resend verification

### Bloque 6.2 — Frontend landing + wizard
- [x] T6.2.1 Landing /vender
- [x] T6.2.2 onboarding-store Zustand
- [x] T6.2.3 Wizard paso cuenta
- [x] T6.2.4 Wizard paso negocio
- [x] T6.2.5 Wizard paso resumen
- [x] T6.2.6 BFF public register
- [x] T6.2.7 Páginas registro + éxito
- [x] T6.2.8 Página confirmar-email
- [x] T6.2.9 Middleware rutas públicas
- [x] T6.2.10 E2E registro público
- [x] T6.2.11 E2E confirmación email

### Bloque 6.3 — Backend catálogo enriquecido
- [x] T6.3.1 ProductVariant entity
- [x] T6.3.2 ProductIngredient entity
- [x] T6.3.3 Models variantes/ingredientes/imagen
- [x] T6.3.4 UpdateProductUseCase
- [x] T6.3.5 API nested + upload imagen
- [x] T6.3.6 Validación vertical/tipo
- [x] T6.3.7 Plantillas categorías por vertical

### Bloque 6.4 — Frontend catálogo enriquecido
- [x] T6.4.1 products-store update/upload
- [x] T6.4.2 Página editar producto
- [x] T6.4.3 Formulario comida variantes/ingredientes
- [x] T6.4.4 Formulario servicio
- [x] T6.4.5 Upload fotos + galería
- [x] T6.4.6 Selector categoría en form
- [x] T6.4.7 ProductList thumbnails + editar
- [x] T6.4.8 E2E variantes comida
- [x] T6.4.9 E2E upload foto

### Bloque 6.5 — Dashboard merchant
- [x] T6.5.1 GetMerchantDashboardUseCase
- [x] T6.5.2 API merchant-dashboard
- [x] T6.5.3 dashboard-store + widgets
- [x] T6.5.4 Reemplazar /merchant placeholder
- [x] T6.5.5 E2E métricas merchant

### Bloque 6.6 — Promociones merchant
- [x] T6.6.1 StorePromotion entity
- [x] T6.6.2 API promotions CRUD
- [x] T6.6.3 UI /merchant/promotions
- [x] T6.6.4 promotions-store
- [x] T6.6.5 E2E crear promoción

### Bloque 6.7 — Configuración tienda
- [x] T6.7.1 Campos perfil Store
- [x] T6.7.2 UpdateStoreProfileUseCase + API
- [x] T6.7.3 UI /merchant/settings
- [x] T6.7.4 E2E actualizar perfil

### Bloque 6.8 — Storage imágenes
- [x] T6.8.1 StorageBackend abstraction
- [x] T6.8.2 S3/Cloudinary prod
- [x] T6.8.3 Doc MEDIA_STORAGE

### Bloque 6.9 — UX gaps Fase 3
- [x] T6.9.1 Editar/eliminar categorías
- [x] T6.9.2 Búsqueda productos
- [x] T6.9.3 Toasts globales
- [x] T6.9.4 Admin CRUD banners UI
- [x] T6.9.5 Admin editar cupones

### Bloque 6.10 — Admin moderación
- [x] T6.10.1 API list merchants
- [x] T6.10.2 API suspender tienda
- [x] T6.10.3 UI /admin/merchants
- [x] T6.10.4 E2E moderación

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
