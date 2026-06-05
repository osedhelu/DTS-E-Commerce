# Monorepo — DTS E-Commerce

**Repositorio:** [github.com/osedhelu/DTS-E-Commerce](https://github.com/osedhelu/DTS-E-Commerce)

## Estructura

```
DTS-E-Commerce/
├── backend/              # Django API + Celery (sin portales web)
├── web-admin/            # Next.js + Tailwind (merchant + super admin)
├── flutter-customer/     # App móvil cliente
├── flutter-driver/       # App móvil conductor
├── docs/                 # Roadmap, tareas, arquitectura
├── scripts/              # setup.sh, dev.sh
├── .cursor/              # Reglas, comandos y skills Cursor
├── docker-compose.yml           # Infra dev (PostGIS + Redis + Mailpit)
├── docker-infrastructure/       # Stack completo Docker (API + workers)
├── Makefile              # Comandos unificados
└── .github/workflows/    # CI
```

## Requisitos

| Herramienta | Versión mínima |
|-------------|----------------|
| Docker | 24+ |
| uv | 0.4+ |
| Python | 3.12+ |
| Flutter | 3.24+ |
| Node.js | 20+ (web-admin) |
| GDAL/GEOS | Solo para PostGIS local sin Docker |

## Setup inicial (una vez)

### Opción A — Solo Docker (recomendado en servidor)

Solo necesitas Docker instalado:

```bash
git clone git@github.com:osedhelu/DTS-E-Commerce.git
cd DTS-E-Commerce
make up
make backend-createsuperuser
```

Ver [docker-infrastructure/README.md](../docker-infrastructure/README.md).

### Opción B — Desarrollo local (uv + Flutter + Node)

```bash
chmod +x scripts/*.sh
./scripts/setup.sh
# o: make setup
```

## Servicios Docker

### Solo infraestructura (`make docker-up`)

| Servicio | Puerto | Uso |
|----------|--------|-----|
| PostGIS | 5432 | Base de datos geoespacial |
| Redis | 6379 | Celery broker + cache + Channels |
| Mailpit | 8025 (UI), 1025 (SMTP) | Servidor de correo para desarrollo |

### Stack completo en servidor local (`make up`)

| Servicio | Puerto | Uso |
|----------|--------|-----|
| `api` | 8000 | Django + Gunicorn |
| `celery-worker` | — | Tareas asíncronas |
| `celery-beat` | — | Programación (stats 02:00, etc.) |
| + infra anterior | | |

Ver [docker-infrastructure/README.md](../docker-infrastructure/README.md).

### Mailpit — correo en desarrollo

**Sí**, puedes (y conviene) usar un servidor de correo en Docker para desarrollo. Usamos [Mailpit](https://github.com/axllent/mailpit): captura todos los emails que envía Django/Celery y los muestra en una interfaz web. No llegan a internet.

```bash
make docker-up
# Abre http://localhost:8025 para ver los correos capturados
```

En `backend/.env`:

```
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=localhost
EMAIL_PORT=1025
```

Alternativas equivalentes: **Mailhog** (menos mantenido) o **Maildev**.

```bash
make docker-up      # iniciar
make docker-down    # detener
make docker-logs    # ver logs
```

## Variables de entorno

Copiar y ajustar:

```bash
cp backend/.env.example backend/.env
```

## Comandos diarios

**Docker (servidor):**

```bash
make up                       # API + workers + DB
make logs
make backend-createsuperuser
```

**Desarrollo local:**

```bash
make backend-run      # Django :8000
make web-admin-dev    # Next.js :3000
make backend-test     # pytest
make test             # todo
```

## Desarrollo por fase

Usa comandos Cursor (`/tarea T1.x.x`) o consulta [TASKS.md](TASKS.md).

## GDAL en macOS (opcional)

Si corres Django fuera de Docker con PostGIS:

```bash
brew install gdal geos
```

Añade en `backend/.env`:

```
GDAL_LIBRARY_PATH=/opt/homebrew/lib/libgdal.dylib
GEOS_LIBRARY_PATH=/opt/homebrew/lib/libgeos_c.dylib
```

Los tests usan SQLite y no requieren GDAL.
