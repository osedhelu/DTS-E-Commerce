# DTS E-Commerce / Delivery Platform

Monorepo de la plataforma de delivery: backend Django, apps Flutter (cliente y conductor) y portales web.

**Repositorio:** `git@github.com:osedhelu/DTS-E-Commerce.git`

## Estructura del monorepo

```
├── backend/              # Django + DRF + Celery + Channels + Portales
├── flutter-customer/     # App móvil cliente
├── flutter-driver/       # App móvil conductor
├── docs/                 # Roadmap, tareas, arquitectura
├── scripts/              # Scripts de setup y desarrollo
├── docker-compose.yml    # PostGIS + Redis
└── Makefile              # Comandos unificados
```

## Setup rápido

```bash
# Clonar
git clone git@github.com:osedhelu/DTS-E-Commerce.git
cd DTS-E-Commerce

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
| `make backend-test` | Tests pytest |
| `make flutter-test` | Tests ambas apps |
| `make test` | Todos los tests |

## Proyectos

| Proyecto | Carpeta | Stack |
|----------|---------|-------|
| Backend + Portales | `backend/` | Django, DRF, Celery, Channels, PostGIS |
| App Cliente | `flutter-customer/` | Flutter, Riverpod, Clean Architecture |
| App Conductor | `flutter-driver/` | Flutter, Riverpod, Clean Architecture |

## Arquitectura

Vertical Slice + Clean Architecture por módulo. Ver [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Desarrollo por fases

| Documento | Contenido |
|-----------|-----------|
| [ROADMAP.md](docs/ROADMAP.md) | 5 fases del proyecto |
| [TASKS.md](docs/TASKS.md) | 77 tareas con tests |
| [PROGRESS.md](docs/PROGRESS.md) | Progreso actual |
| [MONOREPO.md](docs/MONOREPO.md) | Guía completa del monorepo |

### Cursor AI

```
/fase-1          # Backend fundamentos
/tarea T1.2.3    # Tarea específica
/progreso        # Ver avance
```

## URLs locales

| Servicio | URL |
|----------|-----|
| API Django | http://localhost:8000 |
| API Docs (Swagger) | http://localhost:8000/api/v1/docs/ |
| PostGIS | localhost:5432 |
| Redis | localhost:6379 |
