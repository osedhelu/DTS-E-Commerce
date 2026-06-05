---
description: Ejecutar una tarea específica por ID (ej. T1.2.3)
---

# Ejecutar tarea por ID

El usuario indicará un ID de tarea (ej. `T1.5.2`, `T4.3.1`).

## Pasos

1. Busca el ID en `docs/TASKS.md`
2. Lee descripción, proyecto, archivos y **tests obligatorios**
3. Verifica prerequisitos en `docs/PROGRESS.md` (tareas anteriores del bloque)
4. Implementa **solo** esa tarea
5. Escribe y ejecuta los tests listados
6. Marca `[x]` en `docs/PROGRESS.md`
7. Resume: qué hiciste, tests ejecutados, siguiente tarea sugerida

## Si el ID no existe

Lista tareas pendientes del bloque/fase actual.

## Formato de respuesta

```
✅ T1.5.2 — OrderStateMachine
Archivos: features/orders/domain/services.py, tests/domain/test_state_machine.py
Tests: 8 passed
Siguiente: T1.5.3
```
