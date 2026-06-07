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
│   └── <modulo>/
│       ├── components/
│       ├── stores/      # Zustand stores (estado cliente)
│       └── types.ts
├── lib/
│   ├── api/             # Cliente HTTP
│   └── stores/          # Utilidades Zustand compartidas
└── e2e/                 # Playwright (tareas T3.x)
```

## Estado con Zustand

Migración progresiva (bloque **T3.6** en [TASKS.md](TASKS.md)):

| Store | Ubicación | Responsabilidad |
|-------|-----------|-----------------|
| `merchant-session-store` | `features/stores/stores/` | Tienda activa del merchant (persist `sessionStorage`) |
| `products-store` | T3.6.3 | Catálogo, loading, mutaciones CRUD |
| `orders-store` | T3.6.5 | Pedidos delivery, filtros, polling |
| `ui-store` | T3.6.8 | Toasts y feedback global |

**Reglas:**

- Selectores finos: `useStore((s) => s.campo)` para evitar re-renders.
- Datos remotos: acciones async en el store (`loadX`, `updateY`), no `useEffect` + `setState` en componentes.
- Persistir solo IDs de sesión; listas se recargan al montar o tras mutación.
- Nuevas pantallas T3.4+ deben usar Zustand desde el inicio.

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
