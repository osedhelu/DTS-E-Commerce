---
description: Ejecutar Fase 1 — Arquitectura y Modelado de Datos (Backend)
---

# Fase 1 — Backend Fundamentos

Implementa la **Fase 1** del proyecto DTS Delivery Platform.

## Antes de empezar

1. Lee `docs/TASKS.md` sección FASE 1
2. Lee `docs/PROGRESS.md` y encuentra la **primera tarea sin marcar**
3. Lee `docs/ARCHITECTURE.md` para convenciones de capas

## Alcance

Proyecto: `backend/`

Bloques en orden:
1.1 Setup → 1.2 Accounts → 1.3 Stores → 1.4 Products → 1.5 Orders → 1.6 Delivery → 1.7 API

## Por cada tarea

1. Implementa **solo** esa tarea (ID tipo T1.x.x)
2. Respeta Clean Architecture: `domain/` sin Django
3. Escribe los tests listados en TASKS.md
4. Ejecuta: `cd backend && make test`
5. Marca `[x]` en `docs/PROGRESS.md`
6. Informa: ID completado, archivos creados, resultado tests

## Si el usuario no especifica tarea

Empieza por la primera pendiente en PROGRESS.md.

## No hacer

- No saltar a Fase 2+
- No implementar Celery ni Channels aún
- No tocar Flutter
