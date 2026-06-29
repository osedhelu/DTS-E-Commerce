---
description: Ejecutar Fase 4 — Apps Flutter Cliente y Conductor
---

# Fase 4 — Desarrollo Móvil Flutter

**Guía bloques:** [docs/FASE4_BLOCKS.md](../../docs/FASE4_BLOCKS.md)  
**API móvil:** [docs/FLUTTER_API.md](../../docs/FLUTTER_API.md)  
**Progreso:** [docs/PROGRESS.md](../../docs/PROGRESS.md)

## Prerequisito

Fases 1–2 backend ✅ · API Railway staging configurada en `lib/core/config/env.dart`.

## Proyectos

- `flutter-customer/` — bloques **4.1–4.5**
- `flutter-driver/` — bloques **4.6–4.9**
- `backend/` — bloque **4.0** (API driver availability)

## Comandos por bloque

| Bloque | Cursor | Tests |
|--------|--------|-------|
| 4.0 backend | `/bloque-4-0` | `make fase4-test BLOCK=4.0` |
| 4.1 auth cliente | `/bloque-4-1` | `make fase4-test BLOCK=4.1` |
| 4.2 stores | `/bloque-4-2` | `make fase4-test BLOCK=4.2` |
| 4.3 catalog | `/bloque-4-3` | `make fase4-test BLOCK=4.3` |
| 4.4 checkout | `/bloque-4-4` | `make fase4-test BLOCK=4.4` |
| 4.5 tracking+push | `/bloque-4-5` | `make fase4-test BLOCK=4.5` |
| 4.6 auth conductor | `/bloque-4-6` | `make fase4-test BLOCK=4.6` |
| 4.7 availability | `/bloque-4-7` | `make fase4-test BLOCK=4.7` |
| 4.8 orders | `/bloque-4-8` | `make fase4-test BLOCK=4.8` |
| 4.9 location | `/bloque-4-9` | `make fase4-test BLOCK=4.9` |

## Por tarea

```
/tarea T4.2.1
make fase4-test-task TASK=T4.2.1
```

## Arquitectura

Riverpod + Clean Architecture por feature. Ver `.cursor/skills/implement-flutter-feature/SKILL.md`.

## Orden recomendado

1. `/bloque-4-1` → `/bloque-4-2` → `/bloque-4-3` → `/bloque-4-4` → `/bloque-4-5`
2. En paralelo: `/bloque-4-0` + `/bloque-4-6` → `/bloque-4-7` → `/bloque-4-8` → `/bloque-4-9`
