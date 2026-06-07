---
description: Ejecutar Fase 6 — Portal Comercio (onboarding seller + catálogo enriquecido)
---

# Fase 6 — Portal Comercio (Onboarding Seller)

## Prerequisito

Fases 1, 2 y 3 completas (API base + web-admin MVP).

## Ejecutar por bloques (recomendado)

Cada bloque = implementar + tests unificados:

| Bloque | Implementar | Validar tests |
|--------|-------------|---------------|
| 6.1 | `/bloque-6-1` | `make fase6-test BLOCK=6.1` |
| 6.2 | `/bloque-6-2` | `make fase6-test BLOCK=6.2` |
| 6.3 | `/bloque-6-3` | `make fase6-test BLOCK=6.3` |
| 6.4 | `/bloque-6-4` | `make fase6-test BLOCK=6.4` |
| 6.5 | `/bloque-6-5` | `make fase6-test BLOCK=6.5` |
| 6.6 | `/bloque-6-6` | `make fase6-test BLOCK=6.6` |
| 6.7 | `/bloque-6-7` | `make fase6-test BLOCK=6.7` |
| 6.8 | `/bloque-6-8` | `make fase6-test BLOCK=6.8` |
| 6.9 | `/bloque-6-9` | `make fase6-test BLOCK=6.9` |
| 6.10 | `/bloque-6-10` | `make fase6-test BLOCK=6.10` |

Una tarea suelta: `/tarea T6.1.4` → `make fase6-test-task TASK=T6.1.4`

Todos los bloques: `make fase6-test-all`

## Documentación

- [MERCHANT_ONBOARDING.md](../docs/MERCHANT_ONBOARDING.md) — flujo negocio
- [FASE6_BLOCKS.md](../docs/FASE6_BLOCKS.md) — tests por bloque
- [TASKS.md](../docs/TASKS.md) — IDs T6.x.x

## Orden

```
6.1 → 6.2 → 6.3 → 6.4 → 6.5 → 6.6 → 6.7 → 6.8 → 6.9 → 6.10
```

## Reglas

- Skill backend: `implement-django-feature`
- Skill frontend: `implement-nextjs-feature`
- Zustand para estado cliente
- Tests: `scripts/fase6-block-test.sh`
