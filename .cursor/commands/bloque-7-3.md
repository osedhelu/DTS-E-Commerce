---
description: Bloque 7.3 — Celery desactivar promos expiradas
---

# Bloque 7.3 — Promociones lifecycle

Tareas: T7.3.1 – T7.3.3 · Ver `docs/TASKS.md`.

## Objetivo

Task Celery Beat que pone `is_active=False` cuando `valid_until < now`. UI coherente con estado Expirada.

```bash
cd backend && uv run pytest features/marketing/tests/ -v -k "expired_promotion"
```

Marca `[x]` en `docs/PROGRESS.md` bloque 7.3 al terminar.
