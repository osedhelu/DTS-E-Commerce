# Docker — DTS Delivery Platform

> Guía completa de despliegue: [docs/DEPLOY_DOCKER.md](../docs/DEPLOY_DOCKER.md)

## Inicio rápido

```bash
cp docker-infrastructure/.env.example docker-infrastructure/.env
# Editar SECRET_KEY, ALLOWED_HOSTS, CSRF_TRUSTED_ORIGINS
make up
make backend-createsuperuser
```

## Servicios

| Servicio | Contenedor | Puerto |
|----------|------------|--------|
| API Django | dts-api | 8000 |
| Celery worker | dts-celery-worker | — |
| Celery beat | dts-celery-beat | — |
| PostGIS | dts-postgis | 5432 |
| Redis | dts-redis | 6379 |
| Mailpit | dts-mailpit | 8025 |

## Automatizado al arrancar (`make up`)

- Migraciones de todas las apps
- Reparación de tablas huérfanas (`scripts/repair_migration_tables.py`)
- PostGIS extension
- Archivos estáticos (WhiteNoise)
- Workers Celery

## Comandos

```bash
make up                       # Instalar / actualizar stack completo
make down                     # Detener
make logs                     # Logs (incluye tracebacks de errores 500)
make doctor                   # Diagnóstico hosts
make backend-check-db         # Tablas analytics + delivery
make backend-createsuperuser  # Admin Django (primera vez)
```

## Estructura

```
docker-infrastructure/
├── docker-compose.yml       # Stack completo
├── docker-compose.infra.yml # Solo DB/Redis/Mailpit
├── .env.example
├── backend/
│   ├── Dockerfile
│   └── entrypoint.sh        # migrate + repair + collectstatic
└── volumes/fcm/             # Firebase (opcional)
```
