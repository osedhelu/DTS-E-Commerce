---
description: Ejecutar tests de un módulo (backend o flutter)
---

# Tests por módulo

El usuario indicará un módulo (ej. `orders`, `accounts`, `auth`).

## Detectar proyecto

| Módulo | Comando |
|--------|---------|
| Backend `features/<modulo>/` | `cd backend && uv run pytest features/<modulo>/tests/ -v` |
| Flutter customer | `cd flutter-customer && flutter test test/features/<modulo>/` |
| Flutter driver | `cd flutter-driver && flutter test test/features/<modulo>/` |

## Pasos

1. Ejecutar tests del módulo
2. Si fallan: diagnosticar y ofrecer arreglar
3. Si pasan: reportar cobertura si está disponible (`make test-cov` backend)
4. Listar tests faltantes según `docs/TASKS.md` para ese módulo

## Si el módulo no tiene tests aún

Indica qué tests crear según TASKS.md y ofrece implementarlos.
