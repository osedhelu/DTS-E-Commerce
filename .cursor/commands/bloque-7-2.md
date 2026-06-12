---
description: Bloque 7.2 — Horarios tienda y zonas de entrega
---

# Bloque 7.2 — Operación real del comercio

Tareas: T7.2.1 – T7.2.7 · Ver `docs/TASKS.md` y `docs/ADMIN_MATURITY.md` §2.

## Entregables

- `StoreOpeningHours` domain + API + UI settings
- Celery auto abierto/cerrado por horario
- `DeliveryZone` (radio/polígono) + validación checkout
- UI zona cobertura en `/merchant/settings`

```bash
cd backend && uv run pytest features/stores/tests/ -v -k "opening_hours or delivery_zone"
```

Marca `[x]` en `docs/PROGRESS.md` bloque 7.2 al terminar.
