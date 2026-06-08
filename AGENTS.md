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

- [MERCHANT_ONBOARDING.md](docs/MERCHANT_ONBOARDING.md) — **flujo registro comercio + portal seller (Fase 6)**
- [FASE6_BLOCKS.md](docs/FASE6_BLOCKS.md) — **comandos y tests por bloque 6.1–6.11**
- [MEDIA_STORAGE.md](docs/MEDIA_STORAGE.md) — **fotos producto, logos, SERVE_MEDIA**
- [DEPLOY_DOCKER.md](docs/DEPLOY_DOCKER.md) — despliegue servidor con Docker (`make install-server`)
- [PUSH_NOTIFICATIONS.md](docs/PUSH_NOTIFICATIONS.md) — plan push FCM
- [WEB_ADMIN.md](docs/WEB_ADMIN.md) — arquitectura frontend Next.js + Zustand

## Orden de fases recomendado

1. Fase 1–2 — Backend ✅
2. Fase 3 — Web MVP ✅
3. **Fase 6 — Onboarding comercio** — casi completa (falta T6.11.5 E2E foto visible)
4. **Fase 4 — Flutter** ← siguiente
5. Fase 5 — Tiempo real

Comando: `/fase-6` o `/bloque-6-1` … `/bloque-6-11` · Fotos visibles: `/bloque-6-11` · Tests: `make fase6-test BLOCK=6.1`

## Reglas

Ver `.cursor/rules/` para arquitectura, testing y commits.
