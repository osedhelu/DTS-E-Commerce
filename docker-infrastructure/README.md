# Docker — DTS Delivery Platform

Stack para levantar el backend completo en un servidor local.

## Servicios

| Servicio | Contenedor | Puerto | Descripción |
|----------|------------|--------|-------------|
| `db` | dts-postgis | 5432 | PostgreSQL + PostGIS |
| `redis` | dts-redis | 6379 | Broker Celery + cache |
| `mailpit` | dts-mailpit | 8025 / 1025 | Correo capturado (UI / SMTP) |
| `api` | dts-api | 8000 | Django + Gunicorn |
| `celery-worker` | dts-celery-worker | — | Tareas asíncronas |
| `celery-beat` | dts-celery-beat | — | Cron (stats 02:00, etc.) |

## Inicio rápido

```bash
# Desde la raíz del monorepo
cp docker-infrastructure/.env.example docker-infrastructure/.env
make docker-up-full
```

- API: http://localhost:8000
- OpenAPI: http://localhost:8000/api/schema/swagger-ui/
- Mailpit: http://localhost:8025

## Solo infraestructura (desarrollo sin contenedor de app)

Si prefieres correr Django con `uv` en el host:

```bash
make docker-up          # PostGIS + Redis + Mailpit
make backend-migrate
make backend-run
```

## Comandos útiles

```bash
make docker-up-full     # build + levantar stack completo
make docker-down-full   # detener stack completo
make docker-logs-full   # logs de todos los servicios

# Migraciones manuales
docker compose -f docker-infrastructure/docker-compose.yml exec api \
  uv run python manage.py migrate

# Shell Django
docker compose -f docker-infrastructure/docker-compose.yml exec api \
  uv run python manage.py shell

# Crear superusuario
docker compose -f docker-infrastructure/docker-compose.yml exec api \
  uv run python manage.py createsuperuser
```

## FCM (push notifications)

```bash
mkdir -p docker-infrastructure/volumes/fcm
cp /ruta/a/firebase-service-account.json docker-infrastructure/volumes/fcm/service-account.json
```

En `docker-infrastructure/.env`:

```
FCM_CREDENTIALS_PATH=/secrets/fcm/service-account.json
FCM_CREDENTIALS_HOST_PATH=./volumes/fcm
```

## Notas

- Las migraciones se ejecutan automáticamente al iniciar `api` (no en workers).
- `celery-beat` persiste su schedule en el volumen `celery_beat_data`.
- Ajusta `ALLOWED_HOSTS` con la IP o dominio de tu servidor.
