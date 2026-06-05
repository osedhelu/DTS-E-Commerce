---
name: implement-nextjs-feature
description: Implementa pantallas y flujos en web-admin (Next.js App Router + Tailwind) consumiendo la API Django. Usar en tareas T3.x o al crear módulos merchant/admin.
disable-model-invocation: true
---

# Implementar Feature Next.js (web-admin)

## Fuentes

- Tareas y tests: `docs/TASKS.md` (Fase 3)
- Arquitectura frontend: `docs/WEB_ADMIN.md`
- API backend: `/api/v1/` + Swagger en `:8000/api/v1/docs/`

## Estructura por feature

```
web-admin/features/<modulo>/
├── components/       # UI del módulo
├── hooks/            # useOrders, useProducts…
├── api.ts            # funciones fetch tipadas
└── types.ts          # DTOs alineados con serializers DRF

app/merchant/<ruta>/page.tsx   # o app/admin/…
```

## Orden de implementación

1. **Types** — interfaces según respuesta API (sin inventar campos)
2. **api.ts** — funciones con `lib/api/client.ts` (base URL, Authorization)
3. **Hook o Server Component** — lectura de datos
4. **Components** — tabla, formulario, acciones
5. **Page + layout** — registrar ruta bajo `merchant/` o `admin/`
6. **Auth guard** — middleware o layout que verifique rol
7. **Test E2E** — Playwright en `e2e/<nombre>_test.spec.ts`

## Cliente API

```typescript
// lib/api/client.ts — patrón esperado
const base = process.env.NEXT_PUBLIC_API_URL!;

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const token = getAccessToken(); // desde cookie o contexto
  const res = await fetch(`${base}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...init?.headers,
    },
  });
  if (!res.ok) throw new ApiError(res.status, await res.text());
  return res.json();
}
```

## Patrones por tipo de tarea

| Tipo | Enfoque |
|------|---------|
| Layout + guard (T3.1.1) | `app/merchant/layout.tsx` + `middleware.ts` |
| CRUD (T3.1.2–1.4) | Formularios client, lista server o client |
| Acciones pedido (T3.2.2) | Botón → `PATCH` API → optimistic UI o refetch |
| Polling (T3.2.3) | `useEffect` + `setInterval(10_000)` o SWR `refreshInterval` |
| KPIs admin (T3.3.x) | Server Component + gráficos client |

## Server vs Client

- Listados públicos internos: Server Component + `api()` con token de cookie
- Tablas con filtros, polling, mutaciones: `'use client'`
- No mezclar fetch con secretos en componentes client innecesariamente

## Tests obligatorios

Nombres en TASKS.md (snake_case) → archivos Playwright:

```bash
cd web-admin && npx playwright test e2e/merchant_accept_order_action_test.spec.ts
```

Mock API en E2E solo si el test lo exige; preferir backend de test o MSW en CI.

## Reglas

- **No** lógica de negocio duplicada (descuentos, transiciones de estado → backend)
- **No** nuevos endpoints en Django salvo que la tarea lo pida
- **Sí** tipos compartidos documentados en `types.ts` por feature
- Commits: `feat(web-admin): …` o `feat(merchant): …`

## Comandos

```bash
make web-admin-dev
make web-admin-build
make web-admin-lint
```
