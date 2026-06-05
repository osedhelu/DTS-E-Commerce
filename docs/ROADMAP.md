# Roadmap — DTS Delivery Platform

**Objetivo:** llegar al 100% del desarrollo en 5 fases incrementales.

Cada tarea tiene ID único en [TASKS.md](TASKS.md). Formato: `T<fase>.<bloque>.<tarea>`.

---

## Fase 1 — Arquitectura y Modelado de Datos (Fundamentos)

**Proyecto:** `backend/`  
**Criterio de salida:** API REST funcional con auth, CRUD base y tests ≥ 80% en domain/application.

| Bloque | Módulo | Entregable |
|--------|--------|------------|
| 1.1 | Setup | Proyecto Django + DRF + PostGIS + uv |
| 1.2 | accounts | Custom User + perfiles (SuperAdmin, Merchant, Driver, Customer) |
| 1.3 | stores | Store/Merchant, ubicación, estado abierto/cerrado |
| 1.4 | products | Producto, categoría, stock, precio |
| 1.5 | orders | Order + OrderStatus state machine |
| 1.6 | delivery | DeliveryTracking (historial GPS) |
| 1.7 | api | Endpoints DRF + permisos por rol + OpenAPI |

**Comando:** `/fase-1` o `/tarea T1.x.x`

---

## Fase 2 — Lógica Asíncrona y Eventos (Celery + Signals)

**Proyecto:** `backend/`  
**Criterio de salida:** Flujos automáticos al cambiar estado de pedido; workers probados con mocks.

| Bloque | Módulo | Entregable |
|--------|--------|------------|
| 2.1 | infra | Redis + Celery + Celery Beat |
| 2.2 | orders/signals | Signals post_save en cambios de estado |
| 2.3 | delivery/tasks | Asignación de conductores (geo) |
| 2.4 | notifications | Push FCM + email |
| 2.5 | analytics | Reportes nocturnos (ingresos, comisiones) |

**Comando:** `/fase-2`

---

## Fase 3 — Portales Web (Comercios y Super Admin)

**Proyecto:** `backend/portals/`  
**Criterio de salida:** Merchant y SuperAdmin operativos con tests de vistas.

| Bloque | Portal | Entregable |
|--------|--------|------------|
| 3.1 | merchant | CRUD productos e inventario |
| 3.2 | merchant | Dashboard pedidos en tiempo real (HTMX/polling) |
| 3.3 | admin | Métricas globales y KPIs |
| 3.4 | admin | Gestión pagos y comisiones |
| 3.5 | marketing | Cupones y banners promocionales |

**Comando:** `/fase-3`

---

## Fase 4 — Desarrollo Móvil (Flutter)

**Proyectos:** `flutter-customer/`, `flutter-driver/`  
**Criterio de salida:** Flujos E2E contra API de staging; tests unitarios por feature.

### App Cliente

| Bloque | Feature | Entregable |
|--------|---------|------------|
| 4.1 | core + auth | Login, tokens, DI |
| 4.2 | stores | Lista de comercios |
| 4.3 | catalog | Catálogo por comercio |
| 4.4 | cart + checkout | Carrito y pago |
| 4.5 | tracking | Mapa con ubicación del conductor |

### App Conductor

| Bloque | Feature | Entregable |
|--------|---------|------------|
| 4.6 | core + auth | Login conductor |
| 4.7 | availability | Switch en línea / fuera de línea |
| 4.8 | orders | Alerta, aceptar, recoger, entregar |
| 4.9 | location | GPS en segundo plano cada X segundos |

**Comando:** `/fase-4`

---

## Fase 5 — Tracking en Tiempo Real

**Proyectos:** `backend/` + ambas apps Flutter  
**Criterio de salida:** Cliente ve conductor moverse en mapa con latencia < 2s.

| Bloque | Componente | Entregable |
|--------|------------|------------|
| 5.1 | channels | Django Channels + Redis channel layer |
| 5.2 | delivery/ws | WebSocket ubicación conductor → cliente |
| 5.3 | flutter-customer | Cliente escucha WS en tracking |
| 5.4 | flutter-driver | Conductor emite ubicación por WS |
| 5.5 | fallback | Documentar alternativa Firebase Firestore |

**Comando:** `/fase-5`

---

## Progreso sugerido

```
Fase 1 ████████████████████ 100%  ← Empezar aquí
Fase 2 ░░░░░░░░░░░░░░░░░░░░   0%
Fase 3 ░░░░░░░░░░░░░░░░░░░░   0%
Fase 4 ░░░░░░░░░░░░░░░░░░░░   0%
Fase 5 ░░░░░░░░░░░░░░░░░░░░   0%
```

Actualiza este bloque manualmente o pide al agente: `/progreso`
