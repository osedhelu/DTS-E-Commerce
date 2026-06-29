---
description: "Fase 4 bloque 4.0: Backend API disponibilidad conductor"
---

# Bloque 4.0 — Backend driver availability (T4.0.1)

Implementa **T4.0.1** en `backend/`.

## Alcance

- `PATCH /api/v1/accounts/driver/availability/`
- Body: `{ "is_online": bool, "latitude"?: float, "longitude"?: float }`
- Permiso: rol `driver`

## Tests

`test_driver_toggle_online`, `test_driver_updates_location`

```bash
make fase4-test BLOCK=4.0
```

Siguiente: `/bloque-4-7` (conductor) o continuar cliente `/bloque-4-2`.
