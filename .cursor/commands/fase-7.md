---
description: Ejecutar Fase 7 — Madurez portal administrativo (E2E, operación, escala)
---

# Fase 7 — Madurez portal administrativo

## Prerequisito

Fase 6 completa (incl. bloque 6.12 extras documentado en PROGRESS.md).

## Contexto

Lee [ADMIN_MATURITY.md](../docs/ADMIN_MATURITY.md) — análisis honesto de gaps antes de implementar.

## Ejecutar por bloques (recomendado)

| Bloque | Tema | Comando |
|--------|------|---------|
| 7.1 | Calidad E2E + CI | `/bloque-7-1` |
| 7.2 | Horarios y zonas entrega | `/bloque-7-2` |
| 7.3 | Promos lifecycle Celery | `/bloque-7-3` |
| 7.4 | Modelo producto unificado | `/bloque-7-4` |
| 7.5 | Admin plataforma (auditoría, alertas, Excel) | `/bloque-7-5` |
| 7.6 | Multi-usuario y multi-tienda | `/bloque-7-6` |
| 7.7 | Pedidos WS web (puente Fase 5) | `/bloque-7-7` |

Una tarea suelta: `/tarea T7.1.1`

## Documentación

- [ADMIN_MATURITY.md](../docs/ADMIN_MATURITY.md) — gaps y prioridades
- [FASE7_BLOCKS.md](../docs/FASE7_BLOCKS.md) — tests por bloque
- [TASKS.md](../docs/TASKS.md) — IDs T7.x.x

## Orden recomendado

```
7.1 → 7.2 → 7.3
         ↓
    7.4 / 7.5 / 7.6 (según prioridad negocio)
         ↓
Fase 4 Flutter (paralelo) → 7.7 + Fase 5
```

**7.1 es obligatorio** antes de dar por cerrada la parte administrativa.

## Reglas

- Skill backend: `implement-django-feature`
- Skill frontend: `implement-nextjs-feature`
- Marcar `[x]` en `docs/PROGRESS.md` al completar cada tarea
