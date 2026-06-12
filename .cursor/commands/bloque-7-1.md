---
description: Bloque 7.1 — Calidad E2E + CI (promos fechas, plantillas, SVG, reactivar)
---

# Bloque 7.1 — Calidad y confianza

Tareas: T7.1.1 – T7.1.6 · Ver `docs/TASKS.md` y `docs/FASE7_BLOCKS.md`.

## Objetivo

Cubrir con E2E lo entregado en bloque 6.12 y dejar CI frontend verde.

## Tests E2E a crear/ejecutar

- `merchant_promotion_schedule_test`
- `merchant_import_category_template_test`
- `merchant_category_svg_icon_test`
- `merchant_reactivate_promotion_test`

```bash
cd web-admin
pnpm exec tsc --noEmit
pnpm run lint
pnpm run test:e2e -- e2e/merchant-promotions*.spec.ts e2e/merchant-categor*.spec.ts
```

Marca `[x]` en `docs/PROGRESS.md` bloque 7.1 al terminar.
