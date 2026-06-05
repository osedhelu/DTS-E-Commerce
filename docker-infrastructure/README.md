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

## Acceso desde otro equipo (`extreme.local`)

Los puertos **siempre llevan número** en la URL:

| Servicio | URL |
|----------|-----|
| API / Swagger | http://extreme.local:8000/api/v1/docs/ |
| Django admin | http://extreme.local:8000/admin/ |
| Mailpit | http://extreme.local:8025 |

### 1. Configurar `.env`

```bash
nano docker-infrastructure/.env
```

```env
ALLOWED_HOSTS=localhost,127.0.0.1,extreme.local,192.168.1.50
API_PORT=8000
```

### 2. Apuntar el nombre al servidor

En el PC desde el que navegas (si no hay DNS), edita hosts:

**Linux/macOS:** `/etc/hosts`  
**Windows:** `C:\Windows\System32\drivers\etc\hosts`

```
192.168.1.50   extreme.local
```

(Sustituye por la IP real de tu servidor.)

### 3. Abrir puertos en el firewall del servidor (Linux)

```bash
sudo ufw allow 8000/tcp   # API
sudo ufw allow 8025/tcp   # Mailpit (opcional)
sudo ufw status
```

### 4. Reiniciar stack

```bash
make down
make up
```

## Estilos rotos en admin / Swagger

Gunicorn no sirve CSS/JS solo. El proyecto usa **WhiteNoise** + `collectstatic` al arrancar.

Si ves la página sin estilos, reconstruye:

```bash
make down
make up
```

## Configuración (opcional)

Se crea automáticamente `docker-infrastructure/.env` desde `.env.example`.

```env
SECRET_KEY=una-clave-larga-y-aleatoria
ALLOWED_HOSTS=localhost,127.0.0.1,extreme.local
API_PORT=8000
```

## Error: container name already in use

Si antes corriste `make docker-up` y luego `make up` falló con *Conflict. The container name "/dts-postgis" is already in use*:

```bash
make up
```

`make up` detiene stacks anteriores y elimina contenedores huérfanos antes de levantar el stack completo. Los datos de PostgreSQL se conservan en el volumen Docker.

Si persiste el error manualmente:

```bash
docker rm -f dts-postgis dts-redis dts-mailpit
make up
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
