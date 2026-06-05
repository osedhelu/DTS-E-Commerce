---
description: Ejecutar Fase 2 — Celery, Signals y eventos asíncronos
---

# Fase 2 — Lógica Asíncrona

## Prerequisito

Fase 1 al 100% en `docs/PROGRESS.md`. Si no, avisa y ofrece completar Fase 1 primero.

## Alcance

Proyecto: `backend/`

Bloques: 2.1 Infra Celery → 2.2 Signals (+ push T2.2.4–2.2.5) → 2.3 Conductores → 2.4 **Push FCM** → 2.5 Analytics

Consulta `docs/PUSH_NOTIFICATIONS.md` para el mapa OrderStatus → push.

## Por cada tarea T2.x.x

1. Lee tests obligatorios en `docs/TASKS.md`
2. Signals solo disparan tareas Celery (lógica pesada en workers)
3. Tests con `CELERY_TASK_ALWAYS_EAGER=True`
4. Mock FCM y email en tests de notificaciones
5. Ejecuta `cd backend && make test`
6. Actualiza `docs/PROGRESS.md`

## Orden sugerido

T2.1.1 → T2.1.2 → T2.1.3 → T2.2.1 → T2.2.2 → T2.2.3 → T2.2.4 → T2.2.5 → T2.3.x → T2.4.1 → … → T2.4.7 → T2.5.x

**Prerequisito push:** T1.2.8 DeviceToken debe estar hecho antes de T2.4.x.
