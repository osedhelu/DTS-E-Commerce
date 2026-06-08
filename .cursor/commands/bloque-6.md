---
description: Ejecutar un bloque Fase 6 completo (implementar + tests). Uso: /bloque-6 6.1
---

# Bloque Fase 6 — implementar + validar

El usuario indicará el bloque: `6.1`, `6.2`, … `6.11`.

Si no indica bloque, lista bloques pendientes en `docs/PROGRESS.md` y sugiere el primero incompleto.

## Referencia

- Tareas y tests: `docs/TASKS.md` sección **FASE 6 — Bloque X**
- Guía flujo: `docs/MERCHANT_ONBOARDING.md`
- Comandos test: `docs/FASE6_BLOCKS.md`

## Pasos (obligatorios)

1. Lee el bloque en `docs/TASKS.md` (ej. **Bloque 6.1**)
2. Verifica prerequisitos en `docs/PROGRESS.md` (bloques anteriores marcados `[x]`)
3. Implementa **todas** las tareas del bloque (`T6.X.1` … `T6.X.N`) en orden
4. Escribe **todos** los tests listados en la tabla del bloque
5. Ejecuta tests unificados del bloque:

```bash
chmod +x scripts/fase6-block-test.sh
make fase6-test BLOCK=6.1   # sustituir 6.1 por el bloque actual
```

6. Si fallan tests: corregir hasta verde
7. Marca `[x]` todas las tareas del bloque en `docs/PROGRESS.md`
8. Resume: archivos tocados, tests passed, siguiente `/bloque-6 X.Y`

## Comandos por bloque

| Bloque | Cursor | Tests |
|--------|--------|-------|
| 6.1 | `/bloque-6-1` | `make fase6-test BLOCK=6.1` |
| 6.2 | `/bloque-6-2` | `make fase6-test BLOCK=6.2` |
| 6.3 | `/bloque-6-3` | `make fase6-test BLOCK=6.3` |
| 6.4 | `/bloque-6-4` | `make fase6-test BLOCK=6.4` |
| 6.5 | `/bloque-6-5` | `make fase6-test BLOCK=6.5` |
| 6.6 | `/bloque-6-6` | `make fase6-test BLOCK=6.6` |
| 6.7 | `/bloque-6-7` | `make fase6-test BLOCK=6.7` |
| 6.8 | `/bloque-6-8` | `make fase6-test BLOCK=6.8` |
| 6.9 | `/bloque-6-9` | `make fase6-test BLOCK=6.9` |
| 6.10 | `/bloque-6-10` | `make fase6-test BLOCK=6.10` |
| 6.11 | `/bloque-6-11` | `make fase6-test BLOCK=6.11` |

**6.11** — fotos producto y logos visibles en UI (`SERVE_MEDIA`, `resolveMediaUrl`).

## Reglas

- Backend: `uv run pytest` (nunca pip)
- Frontend: Zustand + Playwright E2E
- Un bloque = un commit sugerido al final (si el usuario lo pide)
