# Plan Técnico: Integración de Servicio de Movilidad (Rideshare/Uber)

**Versión:** 1.0  
**Fecha:** 2026-01-16  
**Autor:** Lead Architect  
**Estado:** PENDIENTE DE APROBACIÓN

---

## Resumen Ejecutivo

Este documento detalla la estrategia para integrar un servicio de transporte de pasajeros (tipo Uber) en la plataforma DTS existente, manteniendo intacta la lógica de comercio/delivery actual. Ambos ecosistemas coexistirán limpiamente mediante:

1. **Extensión del modelo Order** con `OrderType.RIDE` y `store` nullable
2. **Sistema de acceso modular** (`ModuleAccess`) para perfiles duales (merchant + fleet operator)
3. **Nuevos módulos backend:** `features/rides/` (tarifas, cotización, ciclo de vida) y `features/fleet/` (flotas, vehículos)
4. **Apps Flutter reestructuradas:** cliente con pestañas (Transporte por defecto), conductor con feed unificado
5. **Web-admin integrado:** módulos de transporte visibles según permisos del usuario

---

## 1. Diagnóstico de Arquitectura Actual

### 1.1 Backend (Django + DRF)

#### Estructura de Features Existentes

```
backend/features/
├── accounts/          # CustomUser, perfiles (Merchant, Driver, Customer), auth
├── orders/            # Order, OrderItem, máquinas de estado
├── stores/            # Store, DeliveryZone, horarios, reseñas
├── products/          # Product, Category, imágenes
├── delivery/          # Tracking, ofertas de conductores, asignación, rutas
├── chat/              # Chat cliente-conductor por pedido
├── notifications/     # FCM push notifications
├── payments/          # Métodos de pago por tienda
├── cart/              # Carrito de compras
├── marketing/         # Promociones, banners, cupones
└── analytics/         # Métricas y reportes
```

#### Modelos Clave Actuales

**`CustomUser` (accounts)**

- Roles excluyentes: `SUPER_ADMIN`, `MERCHANT`, `DRIVER`, `CUSTOMER`
- Perfiles OneToOne: `MerchantProfile`, `DriverProfile`, `CustomerProfile`
- `DriverProfile` ya incluye: ubicación GPS, estado `is_online`, zona de trabajo (`work_center_lat/lng`, `work_radius_km`), verificación, datos bancarios

**`Order` (orders)**

- Campos actuales: `customer`, `store` (ForeignKey obligatorio), `driver`, `status`, `order_type` (DELIVERY/SERVICE)
- Dirección de servicio: `service_address`, `service_latitude`, `service_longitude`
- Estado de pago: `payment_method`, `payment_status`, `total`
- Items: `OrderItem` con `product`, `product_name`, `unit_price`, `quantity`

**`Store` (stores)**

- Campos: `owner`, `name`, `status`, `vertical` (FOOD/SERVICES/RETAIL), `location` (PointField), `delivery_zones`
- Horarios: `StoreOpeningHours`

**`DeliveryTracking` (delivery)**

- Tracking GPS punto a punto: `TrackingPoint` con `location`, `sequence`, `recorded_at`
- Ofertas de conductores: `DriverOfferRejection` (evita re-ofrecer)
- Prueba de entrega: `ProofOfDelivery` con foto y firma

#### Máquinas de Estado

**`OrderStateMachine` (DELIVERY)**

```
CREATED → ACCEPTED_BY_MERCHANT → IN_PREPARATION → READY_FOR_PICKUP
→ SEARCHING_DRIVER → DRIVER_ASSIGNED → PICKED_UP → ON_THE_WAY → DELIVERED
```

**`ServiceOrderStateMachine` (SERVICE)**

```
CREATED → ACCEPTED_BY_MERCHANT → SCHEDULED → PROVIDER_EN_ROUTE → IN_PROGRESS → COMPLETED
```

#### Sistema de Ofertas de Conductores

- **`AcceptOfferUseCase`**: First-wins con `select_for_update()` para evitar race conditions
- **`AssignDriverUseCase`**: Asignación automática cuando el pedido entra en `SEARCHING_DRIVER`
- **`AutoAssignNearestUseCase`**: Celery Beat que asigna pedidos stale (>3 min) al conductor más cercano
- **`DriverMatcher`**: Calcula distancia Haversine y verifica cobertura de zona de trabajo

#### WebSockets y Tracking

- **`TrackingConsumer`**: Room `tracking_{order_id}` para cliente y conductor
  - Conductor envía ubicación GPS → broadcast al room
  - Enriquecimiento con ruta: ETA, distancia, polyline (OpenRouteService)
- **`OrderChatConsumer`**: Chat en tiempo real cliente-conductor
- **`broadcast_order_status()`**: Notifica cambios de estado a todos los suscritos

#### Permisos

```python
class IsSuperAdmin(_RolePermission):
    allowed_roles = (UserRole.SUPER_ADMIN,)

class IsMerchant(_RolePermission):
    allowed_roles = (UserRole.MERCHANT,)

class IsDriver(_RolePermission):
    allowed_roles = (UserRole.DRIVER,)

class IsCustomer(_RolePermission):
    allowed_roles = (UserRole.CUSTOMER,)
```

**Problema:** Los roles son excluyentes. Un usuario no puede ser merchant y driver simultáneamente.

---

### 1.2 Flutter Customer App

#### Estructura de Features

```
flutter-customer/lib/features/
├── auth/              # Login, registro, Google/Apple Sign-In
├── catalog/           # Categorías, productos, detalle
├── cart/              # Carrito de compras
├── checkout/          # Creación de pedidos (delivery y service)
├── orders/            # Listado y detalle de pedidos
├── tracking/          # Mapa de tracking en tiempo real
├── notifications/     # FCM push, registro de device tokens
├── chat/              # Chat con conductor
├── profile/           # Perfil del cliente, direcciones
├── settings/          # Configuración, zona de búsqueda
├── stores/            # Listado y detalle de tiendas
└── shell/             # Navegación principal (NavigationBar)
```

#### Shell Actual (4 tabs)

```dart
NavigationBar(
  destinations: [
    NavigationDestination(icon: Icons.home, label: 'Inicio'),        // StoreListScreen
    NavigationDestination(icon: Icons.receipt_long, label: 'Pedidos'), // CustomerOrdersScreen
    NavigationDestination(icon: Icons.shopping_bag, label: 'Carrito'), // CartScreen
    NavigationDestination(icon: Icons.person, label: 'Perfil'),       // ProfileScreen
  ],
)
```

**Flujo actual:**

1. Tab "Inicio" → `StoreListScreen` → `StoreDetailScreen` → `CatalogScreen`
2. Seleccionar producto → `ProductDetailScreen` → `CartScreen`
3. Checkout → `CheckoutScreen` (delivery) o `ServiceCheckoutScreen` (service)
4. Tracking → `TrackingMapScreen` con WebSocket

---

### 1.3 Flutter Driver App

#### Estructura de Features

```
flutter-driver/lib/features/
├── auth/              # Login, registro, Google/Apple Sign-In
├── offers/            # Feed de ofertas, aceptar/rechazar
├── orders/            # Pedidos activos, detalle, chat
├── location/          # Envío de ubicación GPS, background tracking
├── availability/      # Toggle online/offline
├── earnings/          # Ganancias, solicitudes de retiro
├── profile/           # Perfil del conductor, onboarding
├── settings/          # Configuración, zona de trabajo
├── navigation/        # Navegación hacia destino (ruta)
├── stores/            # Info de tiendas (origen de pedidos)
└── shell/             # Navegación principal (NavigationBar)
```

#### Shell Actual (4 tabs)

```dart
NavigationBar(
  destinations: [
    NavigationDestination(icon: Icons.map, label: 'Inicio'),         // DriverHomeMapScreen (ofertas)
    NavigationDestination(icon: Icons.list_alt, label: 'Pedidos'),   // DriverOrdersScreen
    NavigationDestination(icon: Icons.payments, label: 'Ganancias'), // EarningsScreen
    NavigationDestination(icon: Icons.person, label: 'Perfil'),      // ProfileScreen
  ],
)
```

**Flujo actual:**

1. Tab "Inicio" → `DriverHomeMapScreen` con mapa de ofertas cercanas
2. Oferta entrante → `IncomingOfferScreen` (push notification)
3. Aceptar oferta → `DriverOrderDetailScreen` → `ActiveDeliveryScreen` (navegación)
4. Confirmar pickup → `ConfirmPickupUseCase` → estado `PICKED_UP`
5. Confirmar entrega → `ConfirmDeliveryUseCase` → estado `DELIVERED` → `ProofOfDelivery`

#### Entidad `DriverOffer` (Flutter)

```dart
class DriverOffer extends Equatable {
  final int orderId;
  final int storeId;
  final String storeName;
  final double storeLatitude;
  final double storeLongitude;
  final String total;
  final double distanceKm;
  final String status;
}
```

---

### 1.4 Web-Admin (Next.js)

#### Estructura de Rutas

```
web-admin/app/
├── (auth)/            # Login, recuperación de contraseña
├── [lang]/            # Páginas públicas (términos, privacidad)
├── merchant/          # Panel del comerciante
│   ├── orders/        # Pedidos de la tienda
│   ├── products/      # Gestión de productos
│   ├── categories/    # Categorías
│   ├── promotions/    # Promociones
│   ├── inventory/     # Inventario
│   ├── map/           # Mapa de operaciones
│   └── settings/      # Configuración de tienda
├── admin/             # Panel del super administrador
│   ├── orders/        # Todos los pedidos
│   ├── merchants/     # Gestión de comerciantes
│   ├── map/           # Mapa global
│   ├── banners/       # Banners promocionales
│   ├── coupons/       # Cupones globales
│   └── commissions/   # Comisiones
├── registro-comercio/ # Onboarding de merchants
└── vender/            # Landing page para merchants
```

#### Roles y Permisos

```typescript
export const USER_ROLES = [
  "super_admin",
  "merchant",
  "driver",
  "customer",
] as const;

export function getRoleHomePath(role: UserRole): string {
  switch (role) {
    case "super_admin":
      return "/admin";
    case "merchant":
      return "/merchant";
    default:
      return "/login";
  }
}
```

**Problema:** No hay módulos de transporte/flotas. El rol `driver` redirige a `/login`.

---

## 2. Estrategia de Integración

### 2.1 Principios de Diseño

1. **Reutilización máxima:** Extender entidades existentes (`Order`, `CustomUser`) en lugar de crear duplicados
2. **Coexistencia limpia:** Los módulos de comercio y transporte operan independientemente pero comparten infraestructura (auth, tracking, chat, notificaciones)
3. **Perfiles duales:** Un usuario puede ser merchant y fleet operator simultáneamente mediante `ModuleAccess`
4. **Feed unificado:** La app del conductor recibe y procesa pedidos de tiendas y viajes de pasajeros en el mismo flujo
5. **Tabs contextuales:** La app del cliente muestra Transporte como pestaña predeterminada, con Comercio accesible

---

### 2.2 Cambios en el Modelo de Datos

#### 2.2.1 Extensión de `CustomUser` y Perfiles

**Problema actual:** Los roles son excluyentes (`UserRole` enum). Un usuario no puede operar una tienda y una flota simultáneamente.

**Solución:** Introducir `ModuleAccess` (tabla de control granular) y mantener `UserRole` como rol primario (legacy/compat).

**Nuevo modelo `ModuleAccess`:**

```python
# features/accounts/infrastructure/models.py

class ModuleAccess(models.Model):
    """Control granular de acceso a módulos de la plataforma."""

    class Module(models.TextChoices):
        COMMERCE = "commerce", "Comercio"
        TRANSPORT = "transport", "Transporte"

    user = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name="module_accesses",
    )
    module = models.CharField(max_length=20, choices=Module.choices)
    is_active = models.BooleanField(default=True)
    granted_at = models.DateTimeField(auto_now_add=True)
    granted_by = models.ForeignKey(
        CustomUser,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="granted_accesses",
    )

    class Meta:
        db_table = "accounts_module_access"
        constraints = [
            models.UniqueConstraint(
                fields=["user", "module"],
                name="uniq_module_access_per_user",
            ),
        ]

    def __str__(self) -> str:
        return f"{self.user.username} → {self.module}"
```

**Métodos helper en `CustomUser`:**

```python
class CustomUser(AbstractUser):
    # ... campos existentes ...

    def has_module_access(self, module: str) -> bool:
        return self.module_accesses.filter(
            module=module,
            is_active=True,
        ).exists()

    @property
    def can_access_commerce(self) -> bool:
        return self.has_module_access(ModuleAccess.Module.COMMERCE)

    @property
    def can_access_transport(self) -> bool:
        return self.has_module_access(ModuleAccess.Module.TRANSPORT)
```

**Migración de datos:**

- Todos los `MERCHANT` existentes reciben `ModuleAccess(module="commerce")`
- Todos los `DRIVER` existentes reciben `ModuleAccess(module="transport")`
- Los `SUPER_ADMIN` reciben ambos módulos

**Nuevo perfil `FleetOperatorProfile`:**

```python
# features/fleet/infrastructure/models.py

class FleetOperatorProfile(models.Model):
    """Perfil para operadores de flota (transporte de pasajeros)."""

    user = models.OneToOneField(
        CustomUser,
        on_delete=models.CASCADE,
        related_name="fleet_operator_profile",
    )
    company_name = models.CharField(max_length=255, blank=True)
    tax_id = models.CharField(max_length=50, blank=True)
    phone = models.CharField(max_length=20)
    address = models.TextField(blank=True)
    verification_status = models.CharField(
        max_length=20,
        choices=[
            ("pending", "pending"),
            ("approved", "approved"),
            ("rejected", "rejected"),
        ],
        default="pending",
    )
    verified_at = models.DateTimeField(null=True, blank=True)
    bank_name = models.CharField(max_length=100, blank=True, default="")
    bank_account_number = models.CharField(max_length=50, blank=True, default="")
    bank_account_type = models.CharField(max_length=30, blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "fleet_operator_profile"
```

**Nota:** `DriverProfile` se mantiene para conductores de delivery. Para rideshare, reutilizamos `DriverProfile` pero agregamos campos opcionales de verificación de vehículo (licencia de conducir profesional, seguro, etc.).

---

#### 2.2.2 Extensión de `Order` para Rideshare

**Problema actual:** `store` es ForeignKey obligatorio. Los viajes de pasajeros no tienen tienda origen.

**Solución:** Hacer `store` nullable y agregar `OrderType.RIDE`.

**Cambios en `Order`:**

```python
# features/orders/infrastructure/models.py

class Order(models.Model):
    customer = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name="orders",
    )
    store = models.ForeignKey(
        Store,
        on_delete=models.CASCADE,
        related_name="orders",
        null=True,  # ← NUEVO: nullable para RIDE
        blank=True,  # ← NUEVO: blank para forms
    )
    driver = models.ForeignKey(
        CustomUser,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="assigned_orders",
    )
    status = models.CharField(
        max_length=32,
        choices=[(status.value, status.value) for status in OrderStatus],
        default=OrderStatus.CREATED,
    )
    order_type = models.CharField(
        max_length=10,
        choices=[(order_type.value, order_type.value) for order_type in OrderType],
        default=OrderType.DELIVERY,
    )

    # Campos existentes para delivery/service
    service_address = models.TextField(blank=True)
    customer_notes = models.TextField(blank=True)
    scheduled_at = models.DateTimeField(null=True, blank=True)
    service_latitude = models.FloatField(null=True, blank=True)
    service_longitude = models.FloatField(null=True, blank=True)
    duration_minutes = models.PositiveIntegerField(null=True, blank=True)

    # NUEVOS campos para RIDE
    pickup_address = models.TextField(blank=True, default="")
    pickup_latitude = models.FloatField(null=True, blank=True)
    pickup_longitude = models.FloatField(null=True, blank=True)
    dropoff_address = models.TextField(blank=True, default="")
    dropoff_latitude = models.FloatField(null=True, blank=True)
    dropoff_longitude = models.FloatField(null=True, blank=True)
    fare_breakdown = models.JSONField(default=dict, blank=True)  # {base, distance, time, surge, total}
    estimated_duration_minutes = models.PositiveIntegerField(null=True, blank=True)
    estimated_distance_km = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)

    # Campos existentes de pago
    total = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    payment_method = models.ForeignKey(
        "payments.StorePaymentMethod",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="orders",
    )
    payment_status = models.CharField(
        max_length=20,
        choices=[
            ("pending", "pending"),
            ("paid", "paid"),
            ("failed", "failed"),
            ("cash_on_delivery", "cash_on_delivery"),
        ],
        default="pending",
    )
    payment_reference = models.CharField(max_length=100, blank=True, default="")
    coupon_code = models.CharField(max_length=50, blank=True, default="")
    discount_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    paid_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "orders_order"
        constraints = [
            # Validación a nivel de BD: si order_type = RIDE, store debe ser NULL
            models.CheckConstraint(
                check=(
                    models.Q(order_type="ride", store__isnull=True) |
                    models.Q(order_type__in=["delivery", "service"], store__isnull=False)
                ),
                name="check_store_null_for_ride",
            ),
        ]

    def __str__(self) -> str:
        if self.store:
            return f"Pedido #{self.pk} — {self.store.name}"
        return f"Viaje #{self.pk} — {self.pickup_address[:30]}"

    def compute_total(self) -> Decimal:
        if self.order_type == OrderType.RIDE:
            return Decimal(str(self.fare_breakdown.get("total", 0)))
        return sum((item.subtotal for item in self.items.all()), Decimal("0"))
```

**Extensión de `OrderType`:**

```python
# features/orders/domain/value_objects.py

class OrderType(StrEnum):
    DELIVERY = "delivery"
    SERVICE = "service"
    RIDE = "ride"  # ← NUEVO
```

**Extensión de `OrderStatus` para RIDE:**

```python
class OrderStatus(StrEnum):
    # Compartidos
    CREATED = "created"
    ACCEPTED_BY_MERCHANT = "accepted_by_merchant"  # Para RIDE: "accepted_by_driver"
    CANCELLED = "cancelled"

    # Delivery
    IN_PREPARATION = "in_preparation"
    READY_FOR_PICKUP = "ready_for_pickup"
    SEARCHING_DRIVER = "searching_driver"
    DRIVER_ASSIGNED = "driver_assigned"
    PICKED_UP = "picked_up"
    ON_THE_WAY = "on_the_way"
    DELIVERED = "delivered"

    # Service
    SCHEDULED = "scheduled"
    PROVIDER_EN_ROUTE = "provider_en_route"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"

    # RIDE (nuevos)
    DRIVER_ACCEPTED = "driver_accepted"  # Conductor aceptó el viaje
    DRIVER_EN_ROUTE_TO_PICKUP = "driver_en_route_to_pickup"  # Conductor va hacia pickup
    DRIVER_AT_PICKUP = "driver_at_pickup"  # Conductor llegó al pickup
    RIDE_IN_PROGRESS = "ride_in_progress"  # Viaje en curso
    RIDE_COMPLETED = "ride_completed"  # Viaje completado

RIDE_STATUSES: frozenset[OrderStatus] = frozenset({
    OrderStatus.CREATED,
    OrderStatus.SEARCHING_DRIVER,
    OrderStatus.DRIVER_ACCEPTED,
    OrderStatus.DRIVER_EN_ROUTE_TO_PICKUP,
    OrderStatus.DRIVER_AT_PICKUP,
    OrderStatus.RIDE_IN_PROGRESS,
    OrderStatus.RIDE_COMPLETED,
    OrderStatus.CANCELLED,
})
```

**Nueva máquina de estado `RideOrderStateMachine`:**

```python
# features/orders/domain/services.py

RIDE_TRANSITIONS: dict[OrderStatus, frozenset[OrderStatus]] = {
    OrderStatus.CREATED: frozenset({OrderStatus.SEARCHING_DRIVER, OrderStatus.CANCELLED}),
    OrderStatus.SEARCHING_DRIVER: frozenset({OrderStatus.DRIVER_ACCEPTED, OrderStatus.CANCELLED}),
    OrderStatus.DRIVER_ACCEPTED: frozenset({OrderStatus.DRIVER_EN_ROUTE_TO_PICKUP, OrderStatus.CANCELLED}),
    OrderStatus.DRIVER_EN_ROUTE_TO_PICKUP: frozenset({OrderStatus.DRIVER_AT_PICKUP, OrderStatus.CANCELLED}),
    OrderStatus.DRIVER_AT_PICKUP: frozenset({OrderStatus.RIDE_IN_PROGRESS, OrderStatus.CANCELLED}),
    OrderStatus.RIDE_IN_PROGRESS: frozenset({OrderStatus.RIDE_COMPLETED}),
    OrderStatus.RIDE_COMPLETED: frozenset(),
    OrderStatus.CANCELLED: frozenset(),
}

RIDE_CANCELLABLE_BEFORE_PICKUP: frozenset[OrderStatus] = frozenset({
    OrderStatus.CREATED,
    OrderStatus.SEARCHING_DRIVER,
    OrderStatus.DRIVER_ACCEPTED,
    OrderStatus.DRIVER_EN_ROUTE_TO_PICKUP,
})

class RideOrderStateMachine:
    """Máquina de estados para viajes de pasajeros (rideshare)."""

    @staticmethod
    def can_transition(current: OrderStatus, target: OrderStatus) -> bool:
        if current not in RIDE_STATUSES or target not in RIDE_STATUSES:
            return False
        return target in RIDE_TRANSITIONS.get(current, frozenset())

    @staticmethod
    def transition(current: OrderStatus, target: OrderStatus) -> OrderStatus:
        if not RideOrderStateMachine.can_transition(current, target):
            raise InvalidOrderTransitionError(
                f"Transición inválida de '{current}' a '{target}'"
            )
        return target

    @staticmethod
    def allowed_transitions(current: OrderStatus) -> frozenset[OrderStatus]:
        if current not in RIDE_STATUSES:
            return frozenset()
        return RIDE_TRANSITIONS.get(current, frozenset())

    @staticmethod
    def can_cancel(current: OrderStatus) -> bool:
        return current in RIDE_CANCELLABLE_BEFORE_PICKUP
```

---

### 2.3 Nuevos Módulos Backend

#### 2.3.1 `features/rides/` — Motor de Rideshare

**Estructura:**

```
backend/features/rides/
├── domain/
│   ├── entities.py          # FareRule, FareQuote
│   ├── exceptions.py        # InvalidFareRuleError, QuoteExpiredError
│   ├── repositories.py      # AbstractFareRuleRepository, AbstractRideRepository
│   ├── services.py          # FareCalculator, RideMatcher
│   └── value_objects.py     # FareBreakdown, RideStatus
├── application/
│   ├── dto.py               # QuoteRideDTO, CreateRideDTO, UpdateRideStatusDTO
│   └── use_cases/
│       ├── quote_ride.py              # Cotizar viaje antes de solicitar
│       ├── create_ride.py             # Crear viaje (Order con type=RIDE)
│       ├── accept_ride_offer.py       # Conductor acepta viaje (first-wins)
│       ├── update_ride_status.py      # Actualizar estado del viaje
│       ├── cancel_ride.py             # Cancelar viaje
│       └── calculate_surge_pricing.py # Calcular surge pricing (demanda alta)
├── infrastructure/
│   ├── models.py            # FareRule, SurgeMultiplier
│   ├── serializers.py       # FareQuoteSerializer, RideSerializer
│   ├── views.py             # FareQuoteViewSet, RideViewSet
│   ├── urls.py              # Rutas REST API
│   ├── repositories.py      # DjangoFareRuleRepository, DjangoRideRepository
│   ├── consumers.py         # (Reutiliza TrackingConsumer existente)
│   ├── broadcast.py         # (Reutiliza broadcast_order_status existente)
│   └── tasks.py             # Celery tasks para asignación automática
└── tests/
    ├── domain/
    ├── application/
    └── infrastructure/
```

**Modelos:**

```python
# features/rides/infrastructure/models.py

class FareRule(models.Model):
    """Reglas de tarifas por zona/ciudad."""

    name = models.CharField(max_length=100)  # "Tarifa CDMX", "Tarifa GDL"
    base_fare = models.DecimalField(max_digits=8, decimal_places=2)  # Tarifa base
    price_per_km = models.DecimalField(max_digits=8, decimal_places=2)  # Precio por km
    price_per_minute = models.DecimalField(max_digits=8, decimal_places=2)  # Precio por minuto
    minimum_fare = models.DecimalField(max_digits=8, decimal_places=2)  # Tarifa mínima
    cancellation_fee = models.DecimalField(max_digits=8, decimal_places=2, default=0)  # Penalización

    # Zona geográfica (polígono o ciudad)
    zone_name = models.CharField(max_length=100)
    zone_polygon = gis_models.PolygonField(srid=4326, null=True, blank=True)
    zone_center_latitude = models.FloatField(null=True, blank=True)
    zone_center_longitude = models.FloatField(null=True, blank=True)
    zone_radius_km = models.DecimalField(max_digits=8, decimal_places=2, default=50)

    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "rides_fare_rule"

    def calculate_fare(
        self,
        distance_km: Decimal,
        duration_minutes: int,
        surge_multiplier: Decimal = Decimal("1.0"),
    ) -> dict:
        """Calcula el desglose de tarifa."""
        distance_cost = distance_km * self.price_per_km
        time_cost = Decimal(duration_minutes) * self.price_per_minute
        subtotal = self.base_fare + distance_cost + time_cost
        surge_amount = subtotal * (surge_multiplier - Decimal("1.0"))
        total = max(subtotal * surge_multiplier, self.minimum_fare)

        return {
            "base": float(self.base_fare),
            "distance": float(distance_cost),
            "time": float(time_cost),
            "surge": float(surge_amount),
            "total": float(total),
            "surge_multiplier": float(surge_multiplier),
        }


class SurgeMultiplier(models.Model):
    """Multiplicador de surge pricing por zona y horario."""

    fare_rule = models.ForeignKey(
        FareRule,
        on_delete=models.CASCADE,
        related_name="surge_multipliers",
    )
    day_of_week = models.PositiveSmallIntegerField()  # 0=lunes, 6=domingo
    start_hour = models.PositiveSmallIntegerField()  # 0-23
    end_hour = models.PositiveSmallIntegerField()  # 0-23
    multiplier = models.DecimalField(max_digits=4, decimal_places=2, default=1.0)  # 1.0 = sin surge

    class Meta:
        db_table = "rides_surge_multiplier"
        constraints = [
            models.UniqueConstraint(
                fields=["fare_rule", "day_of_week", "start_hour"],
                name="uniq_surge_per_fare_day_hour",
            ),
        ]
```

**Use Case: Cotizar Viaje**

```python
# features/rides/application/use_cases/quote_ride.py

from dataclasses import dataclass
from decimal import Decimal

from features.orders.domain.exceptions import InvalidOrderTransitionError
from features.rides.domain.services import FareCalculator, RideRouteEstimator


@dataclass
class QuoteRideDTO:
    pickup_latitude: float
    pickup_longitude: float
    dropoff_latitude: float
    dropoff_longitude: float
    zone_name: str | None = None  # Opcional: forzar zona específica


@dataclass
class RideQuote:
    estimated_distance_km: Decimal
    estimated_duration_minutes: int
    fare_breakdown: dict
    quote_id: str  # UUID para rastrear cotización
    expires_at: datetime  # Cotización válida por 5 minutos


class QuoteRideUseCase:
    """Cotiza un viaje antes de solicitarlo."""

    def __init__(
        self,
        fare_calculator: FareCalculator,
        route_estimator: RideRouteEstimator,
    ):
        self.fare_calculator = fare_calculator
        self.route_estimator = route_estimator

    def execute(self, dto: QuoteRideDTO) -> RideQuote:
        # 1. Estimar distancia y duración (OpenRouteService/OSRM)
        route = self.route_estimator.estimate(
            pickup_lat=dto.pickup_latitude,
            pickup_lng=dto.pickup_longitude,
            dropoff_lat=dto.dropoff_latitude,
            dropoff_lng=dto.dropoff_longitude,
        )

        # 2. Calcular tarifa (con surge pricing si aplica)
        fare = self.fare_calculator.calculate(
            distance_km=route.distance_km,
            duration_minutes=route.duration_minutes,
            pickup_lat=dto.pickup_latitude,
            pickup_lng=dto.pickup_longitude,
            zone_name=dto.zone_name,
        )

        # 3. Generar quote con expiración
        return RideQuote(
            estimated_distance_km=route.distance_km,
            estimated_duration_minutes=route.duration_minutes,
            fare_breakdown=fare.breakdown,
            quote_id=str(uuid.uuid4()),
            expires_at=timezone.now() + timedelta(minutes=5),
        )
```

**Use Case: Crear Viaje**

```python
# features/rides/application/use_cases/create_ride.py

from django.db import transaction

from features.orders.domain.value_objects import OrderStatus, OrderType
from features.orders.infrastructure.models import Order
from features.rides.application.dto import CreateRideDTO


class CreateRideUseCase:
    """Crea un viaje de rideshare (Order con type=RIDE, store=NULL)."""

    def execute(self, dto: CreateRideDTO) -> int:
        with transaction.atomic():
            order = Order.objects.create(
                customer_id=dto.customer_id,
                store=None,  # ← RIDE no tiene tienda
                order_type=OrderType.RIDE,
                status=OrderStatus.CREATED,
                pickup_address=dto.pickup_address,
                pickup_latitude=dto.pickup_latitude,
                pickup_longitude=dto.pickup_longitude,
                dropoff_address=dto.dropoff_address,
                dropoff_latitude=dto.dropoff_latitude,
                dropoff_longitude=dto.dropoff_longitude,
                fare_breakdown=dto.fare_breakdown,
                estimated_duration_minutes=dto.estimated_duration_minutes,
                estimated_distance_km=dto.estimated_distance_km,
                total=Decimal(str(dto.fare_breakdown["total"])),
                payment_method_id=dto.payment_method_id,
                payment_status="pending",
            )

            # Trigger asignación de conductor (Celery task)
            from features.delivery.infrastructure.tasks import assign_driver_task
            assign_driver_task.delay(order.id)

            return order.id
```

**Use Case: Aceptar Oferta de Viaje**

```python
# features/rides/application/use_cases/accept_ride_offer.py

from django.db import transaction
from django.utils import timezone

from features.delivery.domain.exceptions import OfferAlreadyTakenError, OfferNotAcceptableError
from features.orders.domain.exceptions import OrderNotFoundError
from features.orders.domain.services import RideOrderStateMachine
from features.orders.domain.value_objects import OrderStatus
from features.orders.infrastructure.models import Order


class AcceptRideOfferUseCase:
    """First-wins: asigna el viaje al conductor con select_for_update."""

    def execute(self, order_id: int, driver_id: int) -> int:
        with transaction.atomic():
            try:
                order = (
                    Order.objects.select_for_update()
                    .get(pk=order_id, order_type=OrderType.RIDE)
                )
            except Order.DoesNotExist as exc:
                raise OrderNotFoundError(f"Viaje {order_id} no encontrado") from exc

            if order.driver_id is not None:
                raise OfferAlreadyTakenError("Otro conductor ya aceptó este viaje")

            if order.status != OrderStatus.SEARCHING_DRIVER:
                raise OfferNotAcceptableError(
                    f"El viaje en estado '{order.status}' no admite aceptación"
                )

            RideOrderStateMachine.transition(
                OrderStatus.SEARCHING_DRIVER,
                OrderStatus.DRIVER_ACCEPTED,
            )

            order.driver_id = driver_id
            order.status = OrderStatus.DRIVER_ACCEPTED
            order.updated_at = timezone.now()
            order.save(update_fields=["driver_id", "status", "updated_at"])

        return driver_id
```

---

#### 2.3.2 `features/fleet/` — Gestión de Flotas

**Estructura:**

```
backend/features/fleet/
├── domain/
│   ├── entities.py          # Vehicle, VehicleAssignment
│   ├── exceptions.py        # InvalidVehicleError, VehicleNotAvailableError
│   ├── repositories.py      # AbstractVehicleRepository, AbstractFleetRepository
│   └── services.py          # FleetAvailabilityService
├── application/
│   ├── dto.py               # CreateVehicleDTO, AssignVehicleDTO
│   └── use_cases/
│       ├── create_vehicle.py          # Registrar vehículo
│       ├── update_vehicle.py          # Actualizar vehículo
│       ├── assign_vehicle_to_driver.py # Asignar vehículo a conductor
│       ├── unassign_vehicle.py        # Desasignar vehículo
│       └── list_fleet_vehicles.py     # Listar flota del operador
├── infrastructure/
│   ├── models.py            # Vehicle, VehicleAssignment
│   ├── serializers.py       # VehicleSerializer, FleetOperatorSerializer
│   ├── views.py             # VehicleViewSet, FleetOperatorViewSet
│   ├── urls.py              # Rutas REST API
│   ├── repositories.py      # DjangoVehicleRepository
│   └── admin.py             # Django admin integration
└── tests/
```

**Modelos:**

```python
# features/fleet/infrastructure/models.py

class VehicleType(models.TextChoices):
    SEDAN = "sedan", "Sedán"
    SUV = "suv", "SUV"
    VAN = "van", "Van"
    MOTORCYCLE = "motorcycle", "Motocicleta"
    BICYCLE = "bicycle", "Bicicleta"


class VehicleStatus(models.TextChoices):
    ACTIVE = "active", "Activo"
    INACTIVE = "inactive", "Inactivo"
    MAINTENANCE = "maintenance", "En mantenimiento"


class Vehicle(models.Model):
    """Vehículo registrado en la plataforma."""

    owner = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name="owned_vehicles",
    )
    vehicle_type = models.CharField(max_length=20, choices=VehicleType.choices)
    brand = models.CharField(max_length=100)
    model = models.CharField(max_length=100)
    year = models.PositiveSmallIntegerField()
    color = models.CharField(max_length=50)
    plate_number = models.CharField(max_length=20, unique=True)
    vin_number = models.CharField(max_length=17, blank=True, default="")

    # Capacidad
    passenger_capacity = models.PositiveSmallIntegerField(default=4)
    luggage_capacity = models.PositiveSmallIntegerField(default=2)

    # Documentación
    insurance_policy_number = models.CharField(max_length=100, blank=True, default="")
    insurance_expiry_date = models.DateField(null=True, blank=True)
    technical_verification_expiry = models.DateField(null=True, blank=True)

    # Fotos
    photo_front = models.ImageField(upload_to="fleet/vehicles/front/", blank=True, null=True)
    photo_back = models.ImageField(upload_to="fleet/vehicles/back/", blank=True, null=True)
    photo_interior = models.ImageField(upload_to="fleet/vehicles/interior/", blank=True, null=True)

    status = models.CharField(
        max_length=20,
        choices=VehicleStatus.choices,
        default=VehicleStatus.ACTIVE,
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "fleet_vehicle"
        verbose_name = "vehículo"
        verbose_name_plural = "vehículos"

    def __str__(self) -> str:
        return f"{self.brand} {self.model} {self.year} — {self.plate_number}"


class VehicleAssignment(models.Model):
    """Asignación de vehículo a conductor (puede ser temporal o permanente)."""

    vehicle = models.ForeignKey(
        Vehicle,
        on_delete=models.CASCADE,
        related_name="assignments",
    )
    driver = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name="vehicle_assignments",
    )
    assigned_at = models.DateTimeField(auto_now_add=True)
    unassigned_at = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "fleet_vehicle_assignment"
        constraints = [
            models.UniqueConstraint(
                fields=["vehicle"],
                condition=models.Q(is_active=True),
                name="uniq_active_vehicle_assignment",
            ),
        ]

    def __str__(self) -> str:
        return f"{self.vehicle.plate_number} → {self.driver.username}"
```

---

### 2.4 Cambios en Apps Flutter

#### 2.4.1 Flutter Customer App

**Objetivo:** Agregar pestaña de Transporte como predeterminada, manteniendo Comercio accesible.

**Nuevo Shell (5 tabs):**

```dart
// flutter-customer/lib/features/shell/presentation/screens/customer_shell_screen.dart

class CustomerShellScreen extends ConsumerWidget {
  const CustomerShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          // NUEVO: Transporte (predeterminado)
          const NavigationDestination(
            icon: Icon(Icons.local_taxi_outlined),
            selectedIcon: Icon(Icons.local_taxi),
            label: 'Viajes',
          ),
          // Comercio (movido a segundo lugar)
          const NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Tiendas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: scheme.primary,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: scheme.primary,
              child: const Icon(Icons.shopping_bag),
            ),
            label: 'Carrito',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Nuevas pantallas
class ShellRidesScreen extends StatelessWidget {
  const ShellRidesScreen({super.key});

  @override
  Widget build(BuildContext context) => const RidesHomeScreen();
}

class ShellStoresScreen extends StatelessWidget {
  const ShellStoresScreen({super.key});

  @override
  Widget build(BuildContext context) => const StoreListScreen();
}
```

**Nuevas Features de Rideshare:**

```
flutter-customer/lib/features/rides/
├── presentation/
│   ├── screens/
│   │   ├── rides_home_screen.dart           # Pantalla principal de viajes
│   │   ├── ride_quote_screen.dart           # Cotización antes de solicitar
│   │   ├── ride_tracking_screen.dart        # Tracking del viaje en tiempo real
│   │   └── ride_history_screen.dart         # Historial de viajes
│   └── widgets/
│       ├── pickup_dropoff_picker.dart       # Selector de origen/destino
│       ├── fare_breakdown_card.dart         # Desglose de tarifa
│       └── ride_status_card.dart            # Estado del viaje
├── domain/
│   ├── entities/
│   │   ├── ride.dart                        # Entidad Ride
│   │   ├── fare_quote.dart                  # Cotización
│   │   └── ride_status.dart                 # Estados del viaje
│   ├── usecases/
│   │   ├── quote_ride_usecase.dart          # Cotizar viaje
│   │   ├── create_ride_usecase.dart         # Crear viaje
│   │   ├── cancel_ride_usecase.dart         # Cancelar viaje
│   │   └── get_ride_status_usecase.dart     # Obtener estado del viaje
│   └── repositories/
│       └── rides_repository.dart            # Abstract repository
└── infrastructure/
    ├── datasources/
│       ├── rides_remote_datasource.dart     # API REST
│       └── rides_ws_datasource.dart         # WebSocket para tracking
    ├── repositories/
│       └── rides_repository_impl.dart       # Implementación
    └── models/
        ├── ride_dto.dart                    # DTO para serialización
        └── fare_quote_dto.dart              # DTO de cotización
```

**Router Actualizado:**

```dart
// flutter-customer/lib/core/router/app_router.dart

final router = GoRouter(
  initialLocation: '/rides',  // ← Transporte como predeterminado
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return CustomerShellScreen(navigationShell: navigationShell);
      },
      branches: [
        // Rama 1: Viajes (Transporte)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rides',
              builder: (context, state) => const RidesHomeScreen(),
              routes: [
                GoRoute(
                  path: 'quote',
                  builder: (context, state) => const RideQuoteScreen(),
                ),
                GoRoute(
                  path: ':rideId/tracking',
                  builder: (context, state) => const RideTrackingScreen(),
                ),
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const RideHistoryScreen(),
                ),
              ],
            ),
          ],
        ),
        // Rama 2: Tiendas (Comercio)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stores',
              builder: (context, state) => const StoreListScreen(),
              routes: [
                GoRoute(
                  path: ':storeId',
                  builder: (context, state) => const StoreDetailScreen(),
                  routes: [
                    GoRoute(
                      path: 'catalog',
                      builder: (context, state) => const CatalogScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Rama 3: Pedidos (unificado: delivery + service + ride)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const CustomerOrdersScreen(),
              routes: [
                GoRoute(
                  path: ':orderId',
                  builder: (context, state) => const CustomerOrderDetailScreen(),
                ),
              ],
            ),
          ],
        ),
        // Rama 4: Carrito
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartScreen(embeddedInShell: true),
              routes: [
                GoRoute(
                  path: 'checkout',
                  builder: (context, state) => const CheckoutScreen(),
                ),
                GoRoute(
                  path: 'service-checkout',
                  builder: (context, state) => const ServiceCheckoutScreen(),
                ),
              ],
            ),
          ],
        ),
        // Rama 5: Perfil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'addresses',
                  builder: (context, state) => const AddressesScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
```

---

#### 2.4.2 Flutter Driver App

**Objetivo:** Feed unificado que muestre pedidos de tiendas y viajes de pasajeros en el mismo flujo.

**Extensión de `DriverOffer`:**

```dart
// flutter-driver/lib/features/offers/domain/entities/driver_offer.dart

enum OfferType {
  delivery,  // Pedido de tienda
  ride,      // Viaje de pasajero
}

class DriverOffer extends Equatable {
  const DriverOffer({
    required this.orderId,
    required this.offerType,  // ← NUEVO
    required this.storeId,
    required this.storeName,
    required this.storeLatitude,
    required this.storeLongitude,
    required this.total,
    required this.distanceKm,
    required this.status,
    // NUEVOS campos para RIDE
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffAddress,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.estimatedDurationMinutes,
  });

  final int orderId;
  final OfferType offerType;  // ← NUEVO
  final int? storeId;  // ← Ahora nullable (null para RIDE)
  final String? storeName;  // ← Ahora nullable
  final double? storeLatitude;  // ← Ahora nullable
  final double? storeLongitude;  // ← Ahora nullable
  final String total;
  final double distanceKm;
  final String status;

  // Campos de RIDE
  final String? pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String? dropoffAddress;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final int? estimatedDurationMinutes;

  @override
  List<Object?> get props => [
    orderId,
    offerType,
    storeId,
    storeName,
    storeLatitude,
    storeLongitude,
    total,
    distanceKm,
    status,
    pickupAddress,
    pickupLatitude,
    pickupLongitude,
    dropoffAddress,
    dropoffLatitude,
    dropoffLongitude,
    estimatedDurationMinutes,
  ];

  bool get isRide => offerType == OfferType.ride;
  bool get isDelivery => offerType == OfferType.delivery;
}
```

**Feed Unificado:**

```dart
// flutter-driver/lib/features/offers/presentation/screens/driver_home_map_screen.dart

class DriverHomeMapScreen extends ConsumerWidget {
  const DriverHomeMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(driverOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas Cercanas'),
        actions: [
          // Filtro por tipo de oferta
          PopupMenuButton<OfferType?>(
            onSelected: (type) => ref.read(offerFilterProvider.notifier).state = type,
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Todas')),
              const PopupMenuItem(value: OfferType.delivery, child: Text('Solo Delivery')),
              const PopupMenuItem(value: OfferType.ride, child: Text('Solo Viajes')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa con marcadores de ofertas
          GoogleMap(
            markers: _buildOfferMarkers(offers),
          ),
          // Lista de ofertas en bottom sheet
          DraggableScrollableSheet(
            builder: (context, scrollController) {
              return ListView.builder(
                controller: scrollController,
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return OfferCard(
                    offer: offer,
                    onTap: () => _showOfferDetails(context, offer),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildOfferMarkers(List<DriverOffer> offers) {
    return offers.map((offer) {
      final isRide = offer.isRide;
      return Marker(
        markerId: MarkerId('offer_${offer.orderId}'),
        position: LatLng(
          isRide ? offer.pickupLatitude! : offer.storeLatitude!,
          isRide ? offer.pickupLongitude! : offer.storeLongitude!,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isRide ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueOrange,
        ),
        infoWindow: InfoWindow(
          title: isRide ? 'Viaje' : offer.storeName,
          snippet: '\$${offer.total}',
        ),
      );
    }).toSet();
  }
}

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, required this.onTap});

  final DriverOffer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRide = offer.isRide;

    return Card(
      child: ListTile(
        leading: Icon(
          isRide ? Icons.local_taxi : Icons.store,
          color: isRide ? Colors.blue : Colors.orange,
        ),
        title: Text(isRide ? 'Viaje de Pasajero' : offer.storeName!),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRide) ...[
              Text('📍 ${offer.pickupAddress}'),
              Text('🏁 ${offer.dropoffAddress}'),
              Text('⏱️ ${offer.estimatedDurationMinutes} min'),
            ] else ...[
              Text('📍 ${offer.storeName}'),
              Text('📦 ${offer.distanceKm.toStringAsFixed(1)} km'),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${offer.total}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('${offer.distanceKm.toStringAsFixed(1)} km'),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
```

**Pantalla de Detalle de Oferta Unificada:**

```dart
// flutter-driver/lib/features/offers/presentation/screens/incoming_offer_screen.dart

class IncomingOfferScreen extends ConsumerWidget {
  const IncomingOfferScreen({super.key, required this.offer});

  final DriverOffer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRide = offer.isRide;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRide ? 'Solicitud de Viaje' : 'Nuevo Pedido'),
      ),
      body: Column(
        children: [
          // Mapa con ruta
          Expanded(
            child: GoogleMap(
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: _decodePolyline(offer.polyline),
                  color: isRide ? Colors.blue : Colors.orange,
                  width: 5,
                ),
              },
            ),
          ),
          // Detalles de la oferta
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isRide ? Icons.local_taxi : Icons.store,
                      color: isRide ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isRide ? 'Viaje de Pasajero' : offer.storeName!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isRide) ...[
                  _buildLocationRow('Origen', offer.pickupAddress!),
                  const SizedBox(height: 8),
                  _buildLocationRow('Destino', offer.dropoffAddress!),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 4),
                      Text('${offer.estimatedDurationMinutes} min estimados'),
                    ],
                  ),
                ] else ...[
                  _buildLocationRow('Tienda', offer.storeName!),
                  const SizedBox(height: 8),
                  Text('📦 ${offer.distanceKm.toStringAsFixed(1)} km hasta la tienda'),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${offer.total}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _rejectOffer(context, ref),
                          child: const Text('Rechazar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _acceptOffer(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRide ? Colors.blue : Colors.orange,
                          ),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String label, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(address)),
      ],
    );
  }
}
```

---

### 2.5 Cambios en Web-Admin

**Objetivo:** Integrar módulos de transporte en el shell unificado según permisos del usuario.

**Nuevo Sistema de Navegación:**

```typescript
// web-admin/lib/auth/session.ts

export interface UserSession {
  id: number;
  username: string;
  email: string;
  role: UserRole;
  moduleAccesses: string[]; // ← NUEVO: ["commerce", "transport"]
}

export function canAccessModule(session: UserSession, module: string): boolean {
  return session.moduleAccesses.includes(module);
}

export function getAvailableModules(session: UserSession): string[] {
  return session.moduleAccesses;
}
```

**Layout Unificado con Módulos Contextuales:**

```tsx
// web-admin/app/(dashboard)/layout.tsx

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = useSession();
  const availableModules = getAvailableModules(session);

  return (
    <div className="flex h-screen">
      {/* Sidebar con módulos disponibles */}
      <aside className="w-64 bg-gray-900 text-white">
        <div className="p-4">
          <h1 className="text-xl font-bold">DTS Platform</h1>
          <p className="text-sm text-gray-400">{session.username}</p>
        </div>

        <nav className="mt-6">
          {/* Módulo: Comercio */}
          {canAccessModule(session, "commerce") && (
            <>
              <h2 className="px-4 text-xs font-semibold text-gray-500 uppercase">
                Comercio
              </h2>
              <NavItem href="/merchant/orders" icon={Icons.ShoppingCart}>
                Pedidos
              </NavItem>
              <NavItem href="/merchant/products" icon={Icons.Package}>
                Productos
              </NavItem>
              <NavItem href="/merchant/promotions" icon={Icons.Tag}>
                Promociones
              </NavItem>
            </>
          )}

          {/* Módulo: Transporte */}
          {canAccessModule(session, "transport") && (
            <>
              <h2 className="px-4 mt-6 text-xs font-semibold text-gray-500 uppercase">
                Transporte
              </h2>
              <NavItem href="/transport/rides" icon={Icons.Car}>
                Viajes
              </NavItem>
              <NavItem href="/transport/fleet" icon={Icons.Truck}>
                Flota
              </NavItem>
              <NavItem href="/transport/fares" icon={Icons.DollarSign}>
                Tarifas
              </NavItem>
              <NavItem href="/transport/drivers" icon={Icons.Users}>
                Conductores
              </NavItem>
            </>
          )}

          {/* Módulo: Administración (solo super_admin) */}
          {session.role === "super_admin" && (
            <>
              <h2 className="px-4 mt-6 text-xs font-semibold text-gray-500 uppercase">
                Administración
              </h2>
              <NavItem href="/admin/merchants" icon={Icons.Store}>
                Comerciantes
              </NavItem>
              <NavItem href="/admin/commissions" icon={Icons.Percent}>
                Comisiones
              </NavItem>
            </>
          )}
        </nav>
      </aside>

      {/* Contenido principal */}
      <main className="flex-1 overflow-auto bg-gray-100">{children}</main>
    </div>
  );
}
```

**Nuevas Rutas de Transporte:**

```
web-admin/app/transport/
├── rides/
│   ├── page.tsx                    # Listado de viajes
│   └── [rideId]/
│       └── page.tsx                # Detalle del viaje
├── fleet/
│   ├── page.tsx                    # Listado de vehículos
│   ├── new/
│   │   └── page.tsx                # Registrar vehículo
│   └── [vehicleId]/
│       └── page.tsx                # Detalle del vehículo
├── fares/
│   └── page.tsx                    # Gestión de tarifas
└── drivers/
    ├── page.tsx                    # Listado de conductores
    └── [driverId]/
        └── page.tsx                # Detalle del conductor
```

**Página de Gestión de Tarifas:**

```tsx
// web-admin/app/transport/fares/page.tsx

export default function FaresPage() {
  const { data: fareRules, isLoading } = useFareRules();

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Gestión de Tarifas</h1>
        <Button onClick={() => openCreateFareModal()}>Nueva Tarifa</Button>
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Nombre</TableHead>
              <TableHead>Zona</TableHead>
              <TableHead>Tarifa Base</TableHead>
              <TableHead>Precio/km</TableHead>
              <TableHead>Precio/min</TableHead>
              <TableHead>Tarifa Mínima</TableHead>
              <TableHead>Estado</TableHead>
              <TableHead>Acciones</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {fareRules?.map((rule) => (
              <TableRow key={rule.id}>
                <TableCell>{rule.name}</TableCell>
                <TableCell>{rule.zoneName}</TableCell>
                <TableCell>${rule.baseFare}</TableCell>
                <TableCell>${rule.pricePerKm}</TableCell>
                <TableCell>${rule.pricePerMinute}</TableCell>
                <TableCell>${rule.minimumFare}</TableCell>
                <TableCell>
                  <Badge variant={rule.isActive ? "success" : "secondary"}>
                    {rule.isActive ? "Activa" : "Inactiva"}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Button variant="ghost" size="sm">
                    Editar
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>
    </div>
  );
}
```

---

## 3. Plan de Implementación por Fases

### Fase 1: Backend Core (Semanas 1-3)

**Objetivo:** Implementar la infraestructura backend para rideshare.

**Tareas:**

1. **T1.1:** Crear migración para `ModuleAccess` y migrar datos existentes
2. **T1.2:** Extender `Order` con campos de RIDE y hacer `store` nullable
3. **T1.3:** Agregar `OrderType.RIDE` y `RideOrderStateMachine`
4. **T1.4:** Crear módulo `features/rides/` con modelos `FareRule` y `SurgeMultiplier`
5. **T1.5:** Implementar `QuoteRideUseCase` y `CreateRideUseCase`
6. **T1.6:** Implementar `AcceptRideOfferUseCase` (first-wins con `select_for_update`)
7. **T1.7:** Crear endpoints REST API para cotización y creación de viajes
8. **T1.8:** Integrar rideshare con el sistema de ofertas de conductores existente
9. **T1.9:** Crear módulo `features/fleet/` con modelos `Vehicle` y `VehicleAssignment`
10. **T1.10:** Implementar endpoints REST API para gestión de flotas

**Entregables:**

- Migraciones de base de datos
- API REST funcional para rideshare
- Tests unitarios e integration tests
- Documentación de API (OpenAPI/Swagger)

---

### Fase 2: Flutter Customer App (Semanas 4-5)

**Objetivo:** Implementar la UI de rideshare en la app del cliente.

**Tareas:**

1. **T2.1:** Crear feature `rides/` con entidades, use cases y repositories
2. **T2.2:** Implementar `RidesHomeScreen` con mapa y selector de origen/destino
3. **T2.3:** Implementar `RideQuoteScreen` para mostrar cotización antes de solicitar
4. **T2.4:** Implementar `RideTrackingScreen` con WebSocket en tiempo real
5. **T2.5:** Actualizar `CustomerShellScreen` con 5 tabs (Viajes, Tiendas, Pedidos, Carrito, Perfil)
6. **T2.6:** Actualizar router con `/rides` como ruta predeterminada
7. **T2.7:** Implementar `RideHistoryScreen` para historial de viajes
8. **T2.8:** Integrar pagos con métodos existentes

**Entregables:**

- UI de rideshare funcional
- Tracking en tiempo real con WebSocket
- Tests de widgets y unitarios

---

### Fase 3: Flutter Driver App (Semanas 6-7)

**Objetivo:** Implementar el feed unificado en la app del conductor.

**Tareas:**

1. **T3.1:** Extender `DriverOffer` con `offerType` y campos de RIDE
2. **T3.2:** Actualizar `DriverHomeMapScreen` con marcadores diferenciados (delivery vs ride)
3. **T3.3:** Implementar filtro por tipo de oferta en el feed
4. **T3.4:** Actualizar `IncomingOfferScreen` para mostrar detalles de RIDE
5. **T3.5:** Implementar `AcceptRideOfferUseCase` en Flutter
6. **T3.6:** Actualizar `ActiveDeliveryScreen` para manejar estados de RIDE
7. **T3.7:** Implementar confirmación de pickup y dropoff para viajes
8. **T3.8:** Actualizar `EarningsScreen` para incluir ganancias de rideshare

**Entregables:**

- Feed unificado funcional
- UI adaptativa para delivery y rideshare
- Tests de widgets y unitarios

---

### Fase 4: Web-Admin (Semanas 8-9)

**Objetivo:** Implementar los módulos de transporte en el dashboard web.

**Tareas:**

1. **T4.1:** Actualizar sistema de autenticación para incluir `moduleAccesses`
2. **T4.2:** Crear layout unificado con sidebar contextual
3. **T4.3:** Implementar página de gestión de tarifas (`/transport/fares`)
4. **T4.4:** Implementar página de gestión de flotas (`/transport/fleet`)
5. **T4.5:** Implementar página de listado de viajes (`/transport/rides`)
6. **T4.6:** Implementar página de detalle de viaje (`/transport/rides/[rideId]`)
7. **T4.7:** Implementar página de gestión de conductores (`/transport/drivers`)
8. **T4.8:** Integrar mapas para visualización de flotas y viajes

**Entregables:**

- Dashboard web con módulos de transporte
- Gestión completa de tarifas y flotas
- Tests E2E con Playwright

---

### Fase 5: Testing y QA (Semanas 10-11)

**Objetivo:** Validación exhaustiva de la integración.

**Tareas:**

1. **T5.1:** Tests de integración backend (pytest)
2. **T5.2:** Tests E2E web-admin (Playwright)
3. **T5.3:** Tests de integración Flutter (integration_test)
4. **T5.4:** Smoke testing en staging (api-staging.dtsdrop.com)
5. **T5.5:** Load testing para validar escalabilidad
6. **T5.6:** Security audit (permisos, inyección SQL, XSS)
7. **T5.7:** Performance optimization (índices, queries, caching)

**Entregables:**

- Reporte de cobertura de tests
- Reporte de performance
- Reporte de seguridad
- Documentación de deployment

---

### Fase 6: Deployment y Lanzamiento (Semana 12)

**Objetivo:** Despliegue a producción y monitoreo.

**Tareas:**

1. **T6.1:** Migraciones de base de datos en producción
2. **T6.2:** Deployment de backend (Railway/Docker)
3. **T6.3:** Deployment de Flutter apps (App Store + Play Store)
4. **T6.4:** Deployment de web-admin (Vercel)
5. **T6.5:** Configuración de monitoreo (Sentry, Datadog)
6. **T6.6:** Configuración de alertas (PagerDuty)
7. **T6.7:** Soft launch con usuarios beta
8. **T6.8:** Monitoreo de métricas clave (latencia, errores, conversión)

**Entregables:**

- Plataforma en producción
- Dashboard de monitoreo
- Documentación de operaciones

---

## 4. Riesgos y Mitigaciones

### 4.1 Riesgos Técnicos

| Riesgo                                                   | Impacto | Probabilidad | Mitigación                                                                                    |
| -------------------------------------------------------- | ------- | ------------ | --------------------------------------------------------------------------------------------- |
| Migración de `store` a nullable rompe queries existentes | Alto    | Media        | Revisar todas las queries con `store` y agregar `WHERE store IS NOT NULL` donde sea necesario |
| Race conditions en asignación de viajes                  | Alto    | Baja         | Usar `select_for_update()` en todas las transacciones de asignación                           |
| WebSocket scaling con miles de conexiones simultáneas    | Medio   | Media        | Implementar Redis Channels con pub/sub y considerar sharding por región                       |
| Surge pricing mal configurado causa tarifas abusivas     | Alto    | Media        | Implementar límites máximos de surge (2.0x) y alertas automáticas                             |
| Geolocalización imprecisa causa pickups fallidos         | Medio   | Alta         | Implementar snap-to-road y permitir ajuste manual de ubicación                                |

### 4.2 Riesgos de Negocio

| Riesgo                                             | Impacto | Probabilidad | Mitigación                                                                      |
| -------------------------------------------------- | ------- | ------------ | ------------------------------------------------------------------------------- |
| Baja adopción de rideshare por usuarios existentes | Alto    | Media        | Campañas de marketing, descuentos iniciales, programa de referidos              |
| Conductores prefieren delivery sobre rideshare     | Medio   | Media        | Incentivos económicos (bonos por viajes completados)                            |
| Competencia agresiva de Uber/Didi                  | Alto    | Alta         | Diferenciación por servicio local, precios competitivos, calidad de conductores |
| Regulación gubernamental restrictiva               | Alto    | Baja         | Asesoría legal, cumplimiento normativo, licencias de transporte                 |

---

## 5. Métricas de Éxito

### 5.1 Métricas Técnicas

- **Latencia de API:** < 200ms para cotización, < 500ms para creación de viaje
- **Disponibilidad:** 99.9% uptime
- **WebSocket connections:** Soportar 10,000+ conexiones simultáneas
- **Asignación de conductor:** < 30 segundos en promedio

### 5.2 Métricas de Negocio

- **Conversión de cotización a viaje:** > 60%
- **Tiempo promedio de pickup:** < 5 minutos
- **Rating de conductores:** > 4.5/5.0
- **Viajes completados por día:** 1,000+ en primer mes
- **Ingresos por viaje:** $150 MXN promedio

---

## 6. Conclusiones

Este plan propone una integración limpia y escalable de rideshare en la plataforma DTS existente, reutilizando la infraestructura de tracking, chat, notificaciones y pagos. Los cambios son incrementales y no rompen la funcionalidad existente de comercio/delivery.

**Próximos Pasos:**

1. **Aprobación del plan** por parte del equipo de producto y arquitectura
2. **Refinamiento de requisitos** con stakeholders (conductores, merchants, clientes)
3. **Estimación detallada** de esfuerzo por tarea (story points)
4. **Asignación de equipo** (backend, mobile, frontend, QA)
5. **Kickoff de Fase 1** con sprint planning

---

**Documento preparado por:** Lead Architect  
**Fecha:** 2026-01-16  
**Versión:** 1.0  
**Estado:** PENDIENTE DE APROBACIÓN
