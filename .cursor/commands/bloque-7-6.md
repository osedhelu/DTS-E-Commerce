---
description: Bloque 7.6 — StoreMember roles, equipo, multi-tienda
---

# Bloque 7.6 — Multi-usuario y escala

Tareas: T7.6.1 – T7.6.5 · Ver `docs/TASKS.md` y `docs/ADMIN_MATURITY.md` §5.

## Entregables

- `StoreMember` (OWNER/MANAGER/STAFF) + permisos DRF
- API invitar miembro + UI `/merchant/settings/team`
- Pulir selector multi-tienda
- (Opcional) notificación web pedido nuevo

```bash
cd backend && uv run pytest features/stores/tests/ -v -k "store_member"
```

Marca `[x]` en `docs/PROGRESS.md` bloque 7.6 al terminar.
