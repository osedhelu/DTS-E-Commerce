# Despliegue en servidor — Docker (guía completa)

Despliegue **100% Docker**: no instales Python, GDAL, PostgreSQL ni Redis en el host.

## Requisitos del servidor

| Requisito | Versión |
|-----------|---------|
| Docker | 24+ |
| Docker Compose | v2+ |
| Git | cualquiera |
| Puertos libres | 8000 (API), opcional 8025 (Mailpit) |

---

## Instalación desde cero (3 pasos)

### 1. Clonar y configurar

```bash
git clone git@github.com:osedhelu/DTS-E-Commerce.git
cd DTS-E-Commerce

cp docker-infrastructure/.env.example docker-infrastructure/.env
nano docker-infrastructure/.env
```

**Edita obligatoriamente:**

```env
SECRET_KEY=genera-una-clave-larga-aleatoria-aqui
ALLOWED_HOSTS=localhost,127.0.0.1,tu-dominio.com,IP-DEL-SERVIDOR
CSRF_TRUSTED_ORIGINS=http://tu-dominio.com:8000,http://IP-DEL-SERVIDOR:8000
DEBUG=False
```

En desarrollo/staging local puedes usar `DEBUG=True` y `extreme.local` en `ALLOWED_HOSTS`.

### 2. Levantar todo

```bash
make up
```

Un solo comando hace automáticamente:

- Build de la imagen del backend (Python + GDAL + dependencias)
- PostGIS + Redis + Mailpit
- API Django (Gunicorn) + Celery worker + Celery beat
- **Migraciones** de todas las apps
- **Reparación** si hay migraciones huérfanas (marcadas aplicadas sin tablas)
- Extensión **PostGIS** en PostgreSQL
- **collectstatic** (admin y Swagger con estilos)
- Registro de modelos en **Django Admin**

Espera 2–5 minutos la primera vez (build de imagen).

### 3. Crear superusuario (solo primera vez)

```bash
make backend-createsuperuser
```

---

## URLs

| Servicio | URL |
|----------|-----|
| API | `http://SERVIDOR:8000` |
| Swagger | `http://SERVIDOR:8000/api/v1/docs/` |
| Django Admin | `http://SERVIDOR:8000/admin/` |
| Mailpit (correo dev) | `http://SERVIDOR:8025` |

**Importante:** siempre incluye el puerto `:8000` en la URL.

---

## Acceso desde otra máquina en la red

### Firewall (Ubuntu/Debian)

```bash
sudo ufw allow 8000/tcp
sudo ufw allow 8025/tcp   # opcional
```

### DNS local (si no tienes dominio)

En el PC cliente, edita hosts:

```
192.168.x.x   extreme.local
```

### Verificar que responde

```bash
make doctor
make backend-check-db
make ps
```

---

## Comandos del día a día

```bash
make up          # Levantar / actualizar tras git pull
make down        # Detener
make logs        # Ver logs (errores 500 aparecen aquí con traceback)
make ps          # Estado
make restart-api # Tras cambiar solo .env
```

---

## Actualizar versión (git pull)

```bash
git pull
make up
```

No necesitas migrar a mano: el entrypoint ejecuta `migrate` y `repair_migration_tables.py` al arrancar `api`.

---

## Qué incluye el arranque automático

```
entrypoint.sh
├── Esperar PostgreSQL
├── migrate --noinput          # Todas las apps
├── repair_migration_tables.py # Repara analytics/delivery si faltan tablas
├── collectstatic              # CSS/JS admin + Swagger (WhiteNoise)
└── Gunicorn / Celery
```

### Apps con tablas verificadas al arrancar

| App | Tablas |
|-----|--------|
| analytics | `analytics_daily_sales_report`, `analytics_driver_commission` |
| delivery | `delivery_deliverytracking`, `delivery_trackingpoint` |

Si Django dice que la migración está aplicada pero la tabla no existe, el script hace `migrate zero --fake` + `migrate` automáticamente.

---

## Django Admin

Todos los modelos del proyecto aparecen en `/admin/`:

- Usuarios, perfiles, tokens FCM
- Comercios, productos, pedidos
- Tracking GPS, reportes analytics

**Nota:** los campos geográficos (GPS) se muestran como coordenadas texto en admin (sin mapa OpenLayers), para evitar errores en Docker.

---

## Problemas frecuentes

### Bad Request (400) al usar dominio/IP

→ Falta el host en `ALLOWED_HOSTS` del `.env`. Edita y ejecuta `make restart-api`.

### Admin sin estilos

→ Ejecuta `make up` (reconstruye y corre `collectstatic`).

### Server Error (500) en sección del admin

→ Revisa logs: `make logs`  
→ Verifica tablas: `make backend-check-db`  
→ Con el script de reparación en entrypoint, `make restart-api` suele bastar.

### Conflicto de nombres de contenedor

→ `make up` limpia contenedores huérfanos automáticamente.

### No usar en producción real

- `DEBUG=True`
- `SECRET_KEY=change-me...`
- Contraseña `postgres` por defecto (cambia `DB_PASSWORD` en `.env`)

---

## Producción (checklist adicional)

- [ ] `SECRET_KEY` único y largo
- [ ] `DEBUG=False`
- [ ] `ALLOWED_HOSTS` con dominio real
- [ ] `DB_PASSWORD` fuerte
- [ ] HTTPS con reverse proxy (Nginx/Caddy) delante del puerto 8000
- [ ] Backup del volumen `dts_postgis_data`
- [ ] FCM: JSON en `docker-infrastructure/volumes/fcm/` (push notifications)

---

## Qué NO instalar en el servidor

- Python / uv
- GDAL / GEOS
- PostgreSQL / Redis

Todo corre dentro de Docker.

---

## Referencia rápida

```bash
# Instalación completa
git clone ... && cd DTS-E-Commerce
cp docker-infrastructure/.env.example docker-infrastructure/.env
# editar .env
make up
make backend-createsuperuser

# Diagnóstico
make doctor
make backend-check-db
make backend-admin-check
```
