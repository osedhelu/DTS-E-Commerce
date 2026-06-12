# Despliegue en Railway — DTS Backend

> **Deploy standalone:** la config vive en el **submódulo `backend/`**  
> (`backend/railway.toml`, `backend/Dockerfile`, `backend/DEPLOY_RAILWAY.md`).  
> Conecta Railway al **repo del backend**, no al monorepo.

Guía completa: [backend/DEPLOY_RAILWAY.md](../backend/DEPLOY_RAILWAY.md)

---

## Resumen rápido (submódulo backend)

| Servicio | Rol |
|----------|-----|
| **postgis** | PostgreSQL + PostGIS |
| **Redis** | Celery broker |
| **Mailpit** | SMTP dev/staging |
| **DTS-backend** | API Django (Gunicorn) |

---

## 2. Configurar DTS-backend (Dashboard)

### Build

| **Repositorio Git** | Repo del submódulo `backend` |
| **Root Directory** | `/` |
| **Dockerfile** | `Dockerfile` (en raíz del repo backend) |
| **railway.toml** | `backend/railway.toml` |

### Networking

- **Generate Domain** en Settings → Networking (ej. `dts-backend-production.up.railway.app`)
- Anota la URL pública para `MEDIA_PUBLIC_BASE_URL` y `ALLOWED_HOSTS`

---

## 3. Variables de entorno (DTS-backend)

Copia en **DTS-backend → Variables**. Usa **referencias** a otros servicios donde aplique.

### Obligatorias

```env
SECRET_KEY=<genera-clave-larga-aleatoria>
DEBUG=False
ALLOWED_HOSTS=.up.railway.app,dts-backend-production.up.railway.app
CSRF_TRUSTED_ORIGINS=https://dts-backend-production.up.railway.app

# Referencia al servicio PostGIS (nombre exacto en tu proyecto: postgis)
DATABASE_URL=${{postgis.DATABASE_URL}}

# Referencia Redis
REDIS_URL=${{Redis.REDIS_URL}}

RUN_MIGRATIONS=true
LOG_LEVEL=INFO
GUNICORN_WORKERS=2
GUNICORN_TIMEOUT=120
```

> **DATABASE_URL interna:** `${{postgis.DATABASE_URL}}` usa `*.railway.internal` — correcto  
> porque el backend corre **dentro** de Railway. No uses la URL TCP pública en el servicio API.

### Email (Mailpit en Railway)

```env
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=${{Mailpit.RAILWAY_PRIVATE_DOMAIN}}
EMAIL_PORT=1025
EMAIL_USE_TLS=False
EMAIL_USE_SSL=False
DEFAULT_FROM_EMAIL=noreply@dts.local
```

Si `RAILWAY_PRIVATE_DOMAIN` no funciona para SMTP, usa el hostname interno del servicio Mailpit  
(ej. `mailpit.railway.internal`) visible en Networking del servicio Mailpit.

### Medios (fotos producto)

**Opción A — volumen Railway (staging):**

```env
SERVE_MEDIA=True
MEDIA_PUBLIC_BASE_URL=https://dts-backend-production.up.railway.app
MEDIA_ROOT=/app/backend/media
```

Monta un **Volume** en Railway en `/app/backend/media`.

**Opción B — S3 (producción recomendada):**

```env
MEDIA_STORAGE_BACKEND=s3
SERVE_MEDIA=False
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_STORAGE_BUCKET_NAME=...
AWS_S3_REGION_NAME=us-east-1
MEDIA_PUBLIC_BASE_URL=https://tu-bucket.s3.amazonaws.com
```

Ver [MEDIA_STORAGE.md](MEDIA_STORAGE.md).

### Web-admin (cuando despliegues Next.js)

```env
WEB_URL=https://tu-web-admin.up.railway.app
```

---

## 4. Pre-deploy (migraciones)

El `entrypoint.sh` ejecuta automáticamente:

1. Espera PostgreSQL (`DATABASE_URL` o `DB_*`)
2. `CREATE EXTENSION IF NOT EXISTS postgis`
3. `migrate --noinput`
4. `repair_migration_tables.py`
5. `collectstatic`

Opcional en Railway → **Settings → Deploy → Pre-deploy command** (redundante si `RUN_MIGRATIONS=true`):

```bash
uv run python manage.py migrate --noinput
```

---

## 5. Crear superusuario (primera vez)

Desde tu Mac con Railway CLI:

```bash
npm i -g @railway/cli
railway login
railway link   # proyecto E commerce Disglobal
railway service DTS-backend
railway run uv run python manage.py createsuperuser
```

---

## 6. Servicios adicionales (opcional)

### Celery worker (mismo Dockerfile, otro servicio)

Duplica el servicio **DTS-backend** o crea **DTS-celery-worker**:

| Campo | Valor |
|-------|--------|
| Dockerfile | mismo |
| Start command | `uv run celery -A core worker --loglevel=info --concurrency=2` |
| Variables | mismas que API (`DATABASE_URL`, `REDIS_URL`, …) |
| Public networking | **off** |

### Celery beat

Start command:

```bash
uv run celery -A core beat --loglevel=info --schedule /tmp/celerybeat-schedule
```

Monta volumen en `/tmp` si quieres persistir el schedule.

---

## 7. Verificar despliegue

```bash
# Health
curl -sS https://TU-DOMINIO.up.railway.app/api/v1/docs/ -o /dev/null -w "%{http_code}\n"

# Swagger en navegador
open https://TU-DOMINIO.up.railway.app/api/v1/docs/
```

Logs:

```bash
railway logs --service DTS-backend
```

---

## 8. Desarrollo local apuntando a Railway

En `docker-infrastructure/.env` **desde tu Mac** (no uses `*.railway.internal`):

```env
USE_LOCAL_DB=false
DATABASE_URL=postgresql://postgres:PASSWORD@HOST_PUBLICO_TCP:PORT/ECOMMERCE_DIS
REDIS_URL=redis://default:PASSWORD@HOST_PUBLICO:PORT
```

Obtén la URL pública TCP en PostGIS → Connect → **Public Network**.

Luego:

```bash
make up   # API local + Redis/Mailpit local, BD remota Railway
```

---

## 9. Troubleshooting

| Error | Causa | Solución |
|-------|--------|----------|
| `Could not find the GDAL library` | Railpack sin GDAL | Forzar Dockerfile + `railway.toml` |
| Crash esperando DB | `DATABASE_URL` mal o PostGIS caído | Verificar `${{postgis.DATABASE_URL}}` |
| `DisallowedHost` | Falta dominio Railway | Añadir `.up.railway.app` a `ALLOWED_HOSTS` |
| 502 en Railway | Gunicorn en puerto 8000 fijo | Usar `$PORT` (ya en Dockerfile/railway.toml) |
| Fotos no se ven | URL relativa / disco efímero | `MEDIA_PUBLIC_BASE_URL` + volumen o S3 |
| PostGIS error en migrate | Extensión no creada | entrypoint ejecuta `CREATE EXTENSION postgis` |

---

## 10. Checklist rápido

- [ ] `railway.toml` en raíz del repo (commit + push)
- [ ] DTS-backend usa **Dockerfile**, no Nixpacks
- [ ] `DATABASE_URL=${{postgis.DATABASE_URL}}`
- [ ] `REDIS_URL=${{Redis.REDIS_URL}}`
- [ ] `SECRET_KEY` fuerte, `DEBUG=False`
- [ ] `ALLOWED_HOSTS` incluye `.up.railway.app`
- [ ] Dominio público generado
- [ ] `MEDIA_PUBLIC_BASE_URL=https://tu-dominio...`
- [ ] Deploy verde → Swagger responde 200
- [ ] `createsuperuser` ejecutado

---

## Referencias

- [DEPLOY_DOCKER.md](DEPLOY_DOCKER.md) — stack Docker local/servidor
- [MEDIA_STORAGE.md](MEDIA_STORAGE.md) — S3 y URLs públicas
- [Railway — Django + Postgres](https://docs.railway.app/guides/saas-backend)
