---
description: "Fase 6 bloque 6.11: Medios operativos — fotos producto y logos visibles"
---

# Bloque 6.11 — Medios operativos (fotos producto + logos)

Integra **T6.11.1 – T6.11.6**: subir imágenes **y verlas** en el panel merchant.

## Prerequisitos

- Bloques 6.3, 6.4, 6.7, 6.8 (upload API + storage abstraction).
- Docker con `SERVE_MEDIA=True` y volumen `backend_media`.

## Tareas

| ID | Qué hace |
|----|----------|
| T6.11.1 | Django sirve `/media/` (`SERVE_MEDIA`) |
| T6.11.2 | URLs absolutas en API (`MEDIA_PUBLIC_BASE_URL`) |
| T6.11.3 | Docker: volumen + env en compose |
| T6.11.4 | Frontend `resolveMediaUrl()` en galería, listado, logo |
| T6.11.5 | E2E `product_photo_visible_test` (integración) |
| T6.11.6 | Docs actualizadas |

## Flujo fotos producto

```
/merchant/products/[id] → upload → BFF multipart → backend MEDIA_ROOT
→ API url absoluta → resolveMediaUrl() → <img> visible
```

## Validar

```bash
make fase6-test BLOCK=6.11
```

Probar manual: `http://extreme.local:8000/media/products/<id>/...png`

Siguiente fase: `/fase-4` (Flutter).
