---
description: Ejecutar Fase 3 — Portales Web Merchant y Super Admin
---

# Fase 3 — Portales Web

## Prerequisito

Fases 1 y 2 completas.

## Alcance

- `backend/portals/merchant/` — comercios
- `backend/portals/admin_portal/` — super admin
- `backend/features/marketing/` — cupones y banners

## Reglas

- Las vistas **reusan use cases** de `features/` (no duplicar lógica)
- Templates Django + Bootstrap o Tailwind
- HTMX para dashboard de pedidos (T3.2.x)
- Tests con `django.test.Client` y `pytest-django`

## Bloques

3.1 CRUD productos merchant → 3.2 Dashboard pedidos → 3.3 KPIs admin → 3.4 Comisiones → 3.5 Marketing

Consulta `docs/TASKS.md` para IDs T3.x.x y tests.
