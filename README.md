# DTS E-Commerce / Delivery Platform

Monorepo de la plataforma de delivery: backend Django (solo API), frontend web admin y apps Flutter (cliente y conductor).

**Repositorio raíz:** `git@github.com:osedhelu/DTS-E-Commerce.git`

Los cuatro proyectos de aplicación viven en **submodules** (repos independientes):

| Carpeta | Repositorio |
|---------|-------------|
| `backend/` | [osedhelu/DTS-backend](https://github.com/osedhelu/DTS-backend) |
| `web-admin/` | [osedhelu/DTS-web-admin](https://github.com/osedhelu/DTS-web-admin) |
| `flutter-customer/` | [osedhelu/DTS-flutter-customer](https://github.com/osedhelu/DTS-flutter-customer) |
| `flutter-driver/` | [osedhelu/DTS-flutter-driver](https://github.com/osedhelu/DTS-flutter-driver) |

## Estructura del monorepo

```
├── backend/              # Django + DRF + Celery + Channels (solo API)
├── web-admin/            # Frontend web (Next.js + Tailwind) para merchant/admin
├── flutter-customer/     # App móvil cliente
├── flutter-driver/       # App móvil conductor
├── docs/                 # Roadmap, tareas, arquitectura
├── scripts/              # Scripts de setup y desarrollo
├── docker-compose.yml    # PostGIS + Redis
└── Makefile              # Comandos unificados
```

## Setup rápido

```bash
# Clonar con submodules
git clone --recurse-submodules git@github.com:osedhelu/DTS-E-Commerce.git
cd DTS-E-Commerce

# Si ya clonaste sin submodules:
# git submodule update --init --recursive

# Instalar todo (Docker + uv + Flutter)
chmod +x scripts/*.sh
./scripts/setup.sh
```

## Comandos principales

| Comando | Descripción |
|---------|-------------|
| `make setup` | Instalar dependencias + Docker |
| `make docker-up` | PostGIS (5432) + Redis (6379) |
| `make backend-run` | API en http://localhost:8000 |
| `make web-admin-dev` | Frontend admin en http://localhost:3000 |
| `make backend-test` | Tests pytest |
| `make flutter-test` | Tests ambas apps |
| `make test` | Todos los tests |

## Proyectos

| Proyecto | Carpeta | Stack |
|----------|---------|-------|
| Backend API | `backend/` | Django, DRF, Celery, Channels, PostGIS |
| Web Admin (Merchant + Super Admin) | `web-admin/` | Next.js, Tailwind |
| App Cliente | `flutter-customer/` | Flutter, Riverpod, Clean Architecture |
| App Conductor | `flutter-driver/` | Flutter, Riverpod, Clean Architecture |

## Arquitectura

Vertical Slice + Clean Architecture por módulo. Ver [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Desarrollo por fases

| Documento | Contenido |
|-----------|-----------|
| [ROADMAP.md](docs/ROADMAP.md) | 5 fases del proyecto |
| [TASKS.md](docs/TASKS.md) | Tareas con tests (incluye push FCM) |
| [PROGRESS.md](docs/PROGRESS.md) | Progreso actual |
| [PUSH_NOTIFICATIONS.md](docs/PUSH_NOTIFICATIONS.md) | Plan push por estado de pedido |
| [MONOREPO.md](docs/MONOREPO.md) | Guía completa del monorepo |
| [WEB_ADMIN.md](docs/WEB_ADMIN.md) | Frontend Next.js merchant/admin |

### Cursor AI

```
/fase-1          # Backend fundamentos
/fase-3          # Frontend web-admin (Next.js)
/tarea T1.2.3    # Tarea específica
/progreso        # Ver avance
```

## URLs locales

| Servicio | URL |
|----------|-----|
| API Django | http://localhost:8000 |
| Web Admin (dev) | http://localhost:3000 |
| API Docs (Swagger) | http://localhost:8000/api/v1/docs/ |
| PostGIS | localhost:5432 |
| Redis | localhost:6379 |
| Mailpit (correos dev) | http://localhost:8025 |
| Mailpit SMTP | localhost:1025 |
