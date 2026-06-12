# Fase 7 — Guía por bloques (madurez portal admin)

Ejecuta **un bloque completo** con Cursor. Ver análisis de gaps en [ADMIN_MATURITY.md](ADMIN_MATURITY.md).

**Tareas:** [TASKS.md](TASKS.md) Fase 7 · **Progreso:** [PROGRESS.md](PROGRESS.md)

---

## Comandos rápidos

| Acción | Cursor |
|--------|--------|
| Visión fase completa | `/fase-7` |
| Bloque 7.1 Calidad E2E | `/bloque-7-1` |
| Bloque 7.2 Horarios y zonas | `/bloque-7-2` |
| Bloque 7.3 Promos Celery | `/bloque-7-3` |
| Bloque 7.4 Modelo producto | `/bloque-7-4` |
| Bloque 7.5 Admin plataforma | `/bloque-7-5` |
| Bloque 7.6 Multi-usuario | `/bloque-7-6` |
| Bloque 7.7 Pedidos WS web | `/bloque-7-7` |
| Una tarea suelta | `/tarea T7.1.1` |

---

## Bloque 7.1 — Calidad y confianza

**Tareas:** T7.1.1 – T7.1.6 · **Proyecto:** `web-admin/` (+ CI)

| Test E2E esperado | Archivo sugerido |
|-------------------|------------------|
| `merchant_promotion_schedule_test` | `e2e/merchant-promotions-schedule.spec.ts` |
| `merchant_import_category_template_test` | `e2e/merchant-categories-template.spec.ts` |
| `merchant_category_svg_icon_test` | `e2e/merchant-category-svg.spec.ts` |
| `merchant_reactivate_promotion_test` | `e2e/merchant-promotions-reactivate.spec.ts` |

```bash
cd web-admin
pnpm exec tsc --noEmit
pnpm run lint
pnpm run test:e2e -- e2e/merchant-promotions*.spec.ts e2e/merchant-categor*.spec.ts
```

**Prerequisito:** Bloque 6.12 completo en PROGRESS.md.

---

## Bloque 7.2 — Operación comercio (horarios y zonas)

**Tareas:** T7.2.1 – T7.2.7 · **Backend + web-admin**

| Área | Entregable |
|------|------------|
| Domain | `StoreOpeningHours`, `DeliveryZone` |
| API | `/stores/{id}/opening-hours/`, `/stores/{id}/delivery-zones/` |
| Celery | Auto toggle store open/closed por horario |
| UI | Sección horarios + mapa/radio en `/merchant/settings` |

```bash
cd backend && uv run pytest features/stores/tests/ -v -k "opening_hours or delivery_zone"
cd web-admin && pnpm run test:e2e -- e2e/merchant-settings*.spec.ts
```

---

## Bloque 7.3 — Promociones lifecycle

**Tareas:** T7.3.1 – T7.3.3 · **Backend Celery + web-admin**

```bash
cd backend && uv run pytest features/marketing/tests/ -v -k "expired_promotion"
```

---

## Bloque 7.4 — Modelo producto unificado

**Tareas:** T7.4.1 – T7.4.4 · **Docs + web-admin**

- Actualizar [PRODUCTS_AND_SERVICES.md](PRODUCTS_AND_SERVICES.md) con ADR
- Ajustar `ProductEditForm` / `FoodProductForm` según decisión

---

## Bloque 7.5 — Admin plataforma

**Tareas:** T7.5.1 – T7.5.8 · **Backend + web-admin**

```bash
cd backend && uv run pytest features/accounts/tests/ features/analytics/tests/ -v -k "audit or export"
cd web-admin && pnpm run test:e2e -- e2e/admin-*.spec.ts
```

---

## Bloque 7.6 — Multi-usuario

**Tareas:** T7.6.1 – T7.6.5 · **Backend + web-admin**

```bash
cd backend && uv run pytest features/stores/tests/ -v -k "store_member"
```

---

## Bloque 7.7 — Pedidos WS web (puente Fase 5)

**Tareas:** T7.7.1 – T7.7.3 · **Requiere T5.1.1 Channels**

Posponer hasta `/fase-5` o implementar consumer mínimo en paralelo.

---

## Workflow recomendado

1. `/bloque-7-1` — E2E de lo entregado en 6.12
2. `/bloque-7-2` — horarios + zonas (mayor valor operativo)
3. `/bloque-7-3` — Celery promos expiradas
4. En paralelo: `/fase-4` (Flutter) cuando 7.1 esté verde
5. `/bloque-7-5` o `/bloque-7-6` según prioridad negocio

## Checklist regresión post-Fase 6

Antes de dar por cerrado 7.1, verificar manualmente:

- [ ] Crear categoría raíz → importar plantilla DTS
- [ ] Subir icono SVG en categoría → visible en árbol
- [ ] Crear promo con fechas → estados Programada/Expirada
- [ ] Desactivar y reactivar promo
- [ ] Badge descuento en parámetro producto (editar producto)
- [ ] Foto producto visible tras upload (6.11)
- [ ] Sidebar merchant fijo al scroll
