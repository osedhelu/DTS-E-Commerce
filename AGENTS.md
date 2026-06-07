# Guía para Agentes — DTS Delivery Platform

## Inicio rápido

1. Lee `docs/ROADMAP.md` para contexto de fases
2. Lee `docs/PROGRESS.md` para ver qué falta
3. Ejecuta tareas con `/tarea T1.1.1` o bloques con `/fase-1`

## Proyectos

| Carpeta | Descripción |
|---------|-------------|
| `backend/` | Django API + Celery + Channels (sin portales web) |
| `web-admin/` | Frontend web merchant + super admin (Next.js) |
| `flutter-customer/` | App móvil cliente |
| `flutter-driver/` | App móvil conductor |

## Skills del proyecto

- `implement-django-feature` — módulos backend
- `implement-nextjs-feature` — pantallas y flujos `web-admin/`
- `implement-flutter-feature` — módulos Flutter
- `execute-phase-task` — workflow por ID de tarea
- `django-celery-signals` — Fase 2 async
- `push-notifications` — FCM push por estado de pedido

## Documentación clave

- [DEPLOY_DOCKER.md](docs/DEPLOY_DOCKER.md) — despliegue servidor con Docker (`make install-server`)
- [PUSH_NOTIFICATIONS.md](docs/PUSH_NOTIFICATIONS.md) — plan push FCM
- [WEB_ADMIN.md](docs/WEB_ADMIN.md) — arquitectura frontend Next.js + Zustand

## Reglas

Ver `.cursor/rules/` para arquitectura, testing y commits.
