# web-admin — Frontend administrativo

Consola web para **merchant** y **super admin**. Vive en `web-admin/`, separada del backend Django.

## Stack

| Tecnología | Uso |
|------------|-----|
| Next.js 16 | App Router, layouts, middleware |
| React 19 | UI |
| TypeScript | Tipado |
| Tailwind CSS v4 | Estilos |
| Playwright (Fase 3) | Tests E2E de flujos |

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

### Merchant (`/merchant/*`)

- CRUD productos y servicios (formulario condicional por `product_type`)
- Inventario (solo `PHYSICAL`)
- Categorías y subcategorías
- Dashboard pedidos (aceptar, preparar, polling)

### Super Admin (`/admin/*`)

- KPIs y métricas
- Comisiones y export CSV
- Marketing (cupones, banners)

## Autenticación

1. Login contra API (`/api/v1/accounts/…`)
2. JWT en header `Authorization: Bearer <token>`
3. Middleware/layout valida rol antes de renderizar rutas protegidas

## Arquitectura de carpetas

```
web-admin/
├── app/                 # Rutas App Router
├── components/ui/       # Primitivos UI
├── features/            # Slices por dominio
├── lib/api/             # Cliente HTTP
└── e2e/                 # Playwright (tareas T3.x)
```

Ver reglas Cursor: `.cursor/rules/nextjs-web-admin.mdc`  
Skill agente: `.cursor/skills/implement-nextjs-feature/SKILL.md`

## Desarrollo

```bash
make docker-up          # PostGIS + Redis (backend)
make backend-run        # API :8000
make web-admin-dev      # Next :3000
```

## Relación con backend

- Django **no** sirve HTML administrativo
- Toda mutación pasa por use cases existentes en `backend/features/`
- Nuevos endpoints solo cuando `docs/TASKS.md` lo indique (ej. banners públicos T3.5.3)
