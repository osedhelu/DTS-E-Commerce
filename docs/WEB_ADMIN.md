# web-admin — Frontend administrativo

Consola web para **merchant** y **super admin**. Vive en `web-admin/`, separada del backend Django.

## Stack

| Tecnología | Uso |
|------------|-----|
| Next.js 16 | App Router, layouts, middleware |
| React 19 | UI |
| TypeScript | Tipado |
| Tailwind CSS v4 | Estilos |
| Zustand 5 | Estado cliente (stores por feature) |
| Playwright | Tests E2E de flujos |

## URLs locales

| Servicio | URL |
|----------|-----|
| web-admin dev | http://localhost:3000 |
| API backend | http://localhost:8000/api/v1 |
| Swagger | http://localhost:8000/api/v1/docs/ |

## Configuración

```bash
cp web-admin/.env.example web-admin/.env.local
```

```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
```

## Áreas de la aplicación

### Público (Fase 6 — sin login)

| Ruta | Descripción |
|------|-------------|
| `/vender` | Landing “Registra tu comercio” |
| `/registro-comercio` | Wizard registro merchant (3 pasos) |
| `/registro-comercio/exito` | “Revisa tu correo” |
| `/confirmar-email` | Validación token verificación |

Ver [MERCHANT_ONBOARDING.md](MERCHANT_ONBOARDING.md).

### Merchant (`/merchant/*`) — requiere rol `merchant` + email verificado

| Ruta | Fase | Descripción |
|------|------|-------------|
| `/merchant` | 6.5 | Dashboard KPIs tienda (ventas, ganancias) |
| `/merchant/products` | 3 + 6.4 | Catálogo; editar, variantes, **galería fotos** |
| `/merchant/products/[id]` | 6.4 | Editar producto + subir fotos (multipart) |
| `/merchant/inventory` | 3 | Stock productos físicos |
| `/merchant/categories` | 3 + 6.9 | Árbol categorías; Fase 6 añade editar/eliminar |
| `/merchant/orders` | 3 | Pedidos delivery |
| `/merchant/service-orders` | 3 | Pedidos servicio |
| `/merchant/promotions` | 6.6 | Descuentos por tienda |
| `/merchant/settings` | 6.7 | Perfil tienda, logo, horario |

### Super Admin (`/admin/*`)

| Ruta | Descripción |
|------|-------------|
| `/admin` | KPIs globales |
| `/admin/commissions` | Comisiones y export CSV |
| `/admin/coupons` | Cupones plataforma |
| `/admin/merchants` | Moderación comercios (Fase 6.10) |

## Autenticación

1. Login contra API (`/api/v1/accounts/…`)
2. JWT en cookie httpOnly (`dts_access_token`)
3. Middleware/layout valida rol antes de rutas protegidas
4. **Fase 6:** registro público crea cuenta; login bloqueado hasta verificar email

## Arquitectura de carpetas

```
web-admin/
├── app/
│   ├── (public)/vender/          # Fase 6 landing
│   ├── (public)/registro-comercio/
│   ├── (auth)/login/
│   ├── merchant/
│   └── admin/
├── features/
│   ├── onboarding/               # Fase 6 wizard registro
│   ├── merchant-dashboard/       # Fase 6 KPIs seller
│   └── <modulo>/stores/          # Zustand
├── lib/api/ + lib/stores/
└── e2e/
```

## Estado con Zustand

Ver bloque T3.6 y stores Fase 6 (`onboarding-store`, `dashboard-store`, `promotions-store`) en [TASKS.md](TASKS.md).

## Fases del frontend

| Fase | Alcance |
|------|---------|
| **3** | MVP operativo (CRUD básico, pedidos, admin KPIs) — ✅ |
| **6** | Portal seller completo (registro, catálogo rico, métricas) — ✅ |
| **6.11** | Fotos producto y logos **visibles** en UI — casi listo (falta E2E integración) |

## Fotos de producto y logos

1. **Subir:** en `/merchant/products/[id]` → galería → `POST .../images/` (BFF multipart).
2. **Ver:** la API devuelve `url` con `MEDIA_PUBLIC_BASE_URL`; el frontend usa `resolveMediaUrl()` (`lib/media-url.ts`).
3. **Backend debe servir** `/media/` con `SERVE_MEDIA=True` (Docker: volumen `backend_media`).

```env
# docker-infrastructure/.env
SERVE_MEDIA=True
MEDIA_PUBLIC_BASE_URL=http://extreme.local:8000
```

Ver [MEDIA_STORAGE.md](MEDIA_STORAGE.md) · Comando: `/bloque-6-11`

## Desarrollo

```bash
make docker-up
make backend-run
make web-admin-dev
```

## Relación con backend

- Django **no** sirve HTML administrativo
- Registro público: `POST /api/v1/accounts/merchant/register/`
- Catálogo enriquecido: variantes, ingredientes, imágenes en `features/products/`

Ver reglas: `.cursor/rules/nextjs-web-admin.mdc`
