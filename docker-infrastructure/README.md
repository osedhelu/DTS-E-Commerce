# Docker — 100% sin instalar GDAL ni Python en el host

Solo necesitas **Docker** y **Docker Compose** en tu máquina/servidor.

## Levantar todo (un comando)

```bash
cd DTS-E-Commerce   # raíz del monorepo
make up
```

Eso construye y arranca:

| Servicio | Puerto | URL |
|----------|--------|-----|
| API Django | 8000 | http://localhost:8000 |
| Swagger | 8000 | http://localhost:8000/api/v1/docs/ |
| Mailpit | 8025 | http://localhost:8025 |
| PostGIS | 5432 | (interno) |
| Redis | 6379 | (interno) |

Las **migraciones** se aplican solas al iniciar `api`.

## Primera vez — crear usuario admin

```bash
make backend-createsuperuser
```

## Comandos del día a día

```bash
make up                      # Levantar / reconstruir stack
make down                    # Detener todo
make logs                    # Ver logs en vivo
make ps                      # Estado de contenedores
make backend-shell           # Shell Django
make backend-migrate-docker  # Re-ejecutar migraciones (opcional)
```

## Configuración (opcional)

Se crea automáticamente `docker-infrastructure/.env` desde `.env.example`.

Edita solo si necesitas cambiar algo:

```bash
nano docker-infrastructure/.env
```

Lo más importante en servidor:

```env
SECRET_KEY=una-clave-larga-y-aleatoria
ALLOWED_HOSTS=localhost,127.0.0.1,192.168.1.50,tu-dominio.com
API_PORT=8000
```

## Si ya tenías solo infra levantada (`make docker-up`)

No pasa nada. `make up` reutiliza los mismos contenedores de PostGIS/Redis y añade API + workers:

```bash
make down    # opcional: parar lo anterior
make up      # stack completo
```

## FCM — push notifications (opcional)

```bash
mkdir -p docker-infrastructure/volumes/fcm
cp /ruta/firebase.json docker-infrastructure/volumes/fcm/service-account.json
```

En `docker-infrastructure/.env`:

```env
FCM_CREDENTIALS_PATH=/secrets/fcm/service-account.json
FCM_CREDENTIALS_HOST_PATH=./volumes/fcm
```

Luego: `make up`

## Qué NO necesitas instalar en el host

- ❌ GDAL / GEOS
- ❌ Python / uv
- ❌ PostgreSQL
- ❌ Redis

Todo eso va **dentro de los contenedores**.
