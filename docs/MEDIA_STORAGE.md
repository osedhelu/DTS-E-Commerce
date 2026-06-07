# Almacenamiento de medios (Fase 6 — T6.8)

Imágenes de catálogo (`ProductImage`) y logos de tienda (`Store.logo`) usan el backend configurable definido en `core/storage.py`.

## Backends

| Backend | Variable | Uso |
|---------|----------|-----|
| **local** | `MEDIA_STORAGE_BACKEND=local` (default) | Desarrollo y tests. Archivos en `MEDIA_ROOT`. |
| **s3** | `MEDIA_STORAGE_BACKEND=s3` | Producción con Amazon S3. |

## Desarrollo (local)

```bash
MEDIA_STORAGE_BACKEND=local
MEDIA_ROOT=media          # default: backend/media/
MEDIA_URL=/media/
```

Los `ImageField` de Django guardan vía `core.storage.DjangoMediaStorage`, que delega en `LocalStorageBackend`.

## Producción (S3)

```bash
MEDIA_STORAGE_BACKEND=s3
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_STORAGE_BUCKET_NAME=dts-delivery-media
AWS_S3_REGION_NAME=us-east-1
# Opcional — CDN o dominio personalizado:
AWS_S3_CUSTOM_DOMAIN=https://cdn.tudominio.com
```

Las URLs públicas devueltas por la API serán:

- Sin dominio custom: `https://{bucket}.s3.{region}.amazonaws.com/{key}`
- Con `AWS_S3_CUSTOM_DOMAIN`: `{custom_domain}/{key}`

### Permisos del bucket

- Política de bucket que permita `s3:PutObject`, `s3:GetObject`, `s3:DeleteObject` al usuario IAM de la app.
- Para acceso público de lectura, configurar bucket policy o servir vía CloudFront (`AWS_S3_CUSTOM_DOMAIN`).

## Cloudinary (alternativa)

No implementado en código; se puede añadir un tercer backend en `build_storage_backend()` siguiendo el protocolo `StorageBackend`. Hasta entonces, usar S3 o local.

## Arquitectura

```
ImageField (ProductImage, Store.logo)
        ↓
DjangoMediaStorage (django STORAGES["default"])
        ↓
StorageBackend protocol
   ├── LocalStorageBackend
   └── S3StorageBackend (boto3)
```

## Tests

```bash
cd backend && uv run pytest tests/test_storage.py -v
# o
make fase6-test BLOCK=6.8
```

- `test_local_storage_save` — guardado en disco
- `test_s3_storage_upload_mock` — upload S3 con cliente mockeado

## Migración desde filesystem local

1. Subir contenido de `media/` al bucket S3 manteniendo las rutas (`products/...`, `stores/...`).
2. Configurar variables `AWS_*` y `MEDIA_STORAGE_BACKEND=s3`.
3. Reiniciar la aplicación. No se requieren migraciones de base de datos: los campos siguen almacenando la clave relativa del objeto.
