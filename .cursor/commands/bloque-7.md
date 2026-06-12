---
description: Ejecutar un bloque Fase 7 completo. Uso: /bloque-7 7.1
---

# Bloque Fase 7 — implementar + validar

El usuario indicará el bloque: `7.1`, `7.2`, … `7.7`.

Si no indica bloque, lista bloques pendientes en `docs/PROGRESS.md` y sugiere **7.1** (E2E) si está incompleto.

## Referencia

- Tareas y tests: `docs/TASKS.md` sección **FASE 7 — Bloque X**
- Análisis gaps: `docs/ADMIN_MATURITY.md`
- Comandos test: `docs/FASE7_BLOCKS.md`

## Pasos (obligatorios)

1. Lee el bloque en `docs/TASKS.md` (ej. **Bloque 7.1**)
2. Verifica prerequisitos en `docs/PROGRESS.md`
3. Implementa **todas** las tareas del bloque (`T7.X.1` … `T7.X.N`) en orden
4. Escribe **todos** los tests listados en la tabla del bloque
5. Ejecuta tests según `docs/FASE7_BLOCKS.md`
6. Si fallan tests: corregir hasta verde
7. Marca `[x]` todas las tareas del bloque en `docs/PROGRESS.md`
8. Resume: archivos tocados, tests passed, siguiente `/bloque-7-X`

## Comandos por bloque

| Bloque | Cursor | Enfoque |
|--------|--------|---------|
| 7.1 | `/bloque-7-1` | E2E promos fechas, plantillas, SVG, reactivar promo; CI TS |
| 7.2 | `/bloque-7-2` | Horarios tienda + zonas entrega |
| 7.3 | `/bloque-7-3` | Celery desactivar promos expiradas |
| 7.4 | `/bloque-7-4` | ADR variantes vs parámetros |
| 7.5 | `/bloque-7-5` | Auditoría, alertas, export Excel |
| 7.6 | `/bloque-7-6` | StoreMember, equipo, multi-tienda |
| 7.7 | `/bloque-7-7` | WS pedidos web (requiere Fase 5 parcial) |

## Reglas

- Backend: `uv run pytest` (nunca pip)
- Frontend: Zustand + Playwright E2E
- Un bloque = un commit sugerido al final (si el usuario lo pide)
