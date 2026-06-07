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
| 1.2 | accounts | Custom User + perfiles + **DeviceToken FCM (T1.2.8)** |
| 1.3 | stores | Store/Merchant, ubicación, estado abierto/cerrado |
| 1.4 | products | Catálogo dual: productos físicos + servicios a domicilio, categorías/subcategorías ([PRODUCTS_AND_SERVICES.md](PRODUCTS_AND_SERVICES.md)) |
| 1.5 | orders | Order delivery + **pedidos servicio** (T1.5.8–1.5.10), state machines |
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
| 2.2 | orders/signals | Signals post_save + push por cambio de estado |
| 2.3 | delivery/tasks | Asignación de conductores (geo) |
| 2.4 | notifications | Push FCM por OrderStatus + email (ver [PUSH_NOTIFICATIONS.md](PUSH_NOTIFICATIONS.md)) |
| 2.5 | analytics | Reportes nocturnos (ingresos, comisiones) |

**Comando:** `/fase-2`

---

## Fase 3 — Frontend Web (Merchant + Super Admin)

**Proyecto:** `web-admin/` (Next.js + Tailwind)  
**Criterio de salida:** Merchant y SuperAdmin operativos consumiendo API `/api/v1/` del backend.

| Bloque | Portal | Entregable |
|--------|--------|------------|
| 3.1 | merchant | CRUD productos/servicios, categorías, inventario (solo físicos) |
| 3.2 | merchant | Dashboard pedidos en tiempo real (polling/SSE/WebSocket) |
| 3.3 | admin | Métricas globales y KPIs |
| 3.4 | admin | Gestión pagos y comisiones |
| 3.5 | marketing | Cupones y banners promocionales |
| 3.6 | infra | **Migración Zustand** — estado cliente compartido (tienda activa, catálogo, pedidos, admin) |

**Stack estado cliente:** Zustand 5 (`features/*/stores/`). Ver bloque 3.6 en [TASKS.md](TASKS.md).

**Comando:** `/fase-3`

---

## Fase 4 — Desarrollo Móvil (Flutter)

**Proyectos:** `flutter-customer/`, `flutter-driver/`  
**Criterio de salida:** Flujos E2E contra API de staging; tests unitarios por feature.

### App Cliente

| Bloque | Feature | Entregable |
|--------|---------|------------|
| 4.1 | core + auth | Login, tokens, DI, **Firebase (T4.1.5)** |
| 4.2 | stores | Lista de comercios |
| 4.3 | catalog | Catálogo por comercio (filtros categoría, productos y servicios) |
| 4.4 | cart + checkout | Carrito, pago delivery y **checkout servicio a domicilio** |
| 4.5 | tracking + push | Mapa + **recibir push pedido en camino (T4.5.3–4.5.5)** |

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
Fase 1 ████████████████████ 100%
Fase 2 ████████████████████ 100%
Fase 3 ████████████████████ 100%
Fase 4 ░░░░░░░░░░░░░░░░░░░░   0%
Fase 5 ░░░░░░░░░░░░░░░░░░░░   0%
```

Actualiza este bloque manualmente o pide al agente: `/progreso`
