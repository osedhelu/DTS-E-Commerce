---
description: Bloque 7.5 — Auditoría, alertas admin, export Excel ventas
---

# Bloque 7.5 — Admin plataforma

Tareas: T7.5.1 – T7.5.8 · Ver `docs/TASKS.md` y `docs/ADMIN_MATURITY.md` §4.

## Entregables

- `AuditLog` + UI `/admin/audit`
- Alertas: comercio sin productos, pedidos sin atender
- Export Excel ventas merchant
- Vista detalle `/admin/merchants/[id]`

```bash
cd backend && uv run pytest -v -k "audit or export or alert"
```

Marca `[x]` en `docs/PROGRESS.md` bloque 7.5 al terminar.
