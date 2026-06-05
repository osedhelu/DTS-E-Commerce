---
description: Ejecutar Fase 3 — Frontend Web (Next.js) Merchant y Super Admin
---

# Fase 3 — Frontend Web (web-admin)

## Prerequisito

Fases 1 y 2 completas (API estable en `/api/v1/`).

## Alcance

- `web-admin/` — Next.js + Tailwind (merchant + super admin)
- `backend/features/marketing/` — dominio/API cupones y banners (T3.5.x)

## Reglas

- **No** portales Django — el backend es solo API
- Consumir endpoints REST existentes; no duplicar lógica de negocio
- Skill: `implement-nextjs-feature`
- Reglas: `.cursor/rules/nextjs-web-admin.mdc`
- Tests E2E Playwright en `web-admin/e2e/` (nombres en `docs/TASKS.md`)

## Bloques

3.1 CRUD productos merchant → 3.2 Dashboard pedidos → 3.3 KPIs admin → 3.4 Comisiones → 3.5 Marketing

Consulta `docs/TASKS.md` para IDs T3.x.x y tests.
