---
description: Mostrar progreso del desarrollo y siguiente tarea recomendada
---

# Estado del progreso

1. Lee `docs/PROGRESS.md`
2. Cuenta tareas completadas vs total por fase
3. Identifica la **siguiente tarea recomendada**
4. Muestra resumen:

```
Fase 1: 3/28 (11%)
Fase 2: 0/15 (0%)
...
Siguiente: T1.2.2 — Email, Phone value objects
Comando: /tarea T1.2.2
```

5. Si Fase 3 está al 100% y Fase 6 incompleta → **`/fase-6`** o bloque pendiente (`/bloque-6-X`).
6. Si Fase 6 ≥ 6.10 pero **fotos producto no se ven** → **`/bloque-6-11`** (T6.11.5 E2E integración pendiente).
7. Si Fase 6 al 100% (incl. 6.11) → sugiere **`/fase-4`** (Flutter).
8. Referencia [MERCHANT_ONBOARDING.md](../docs/MERCHANT_ONBOARDING.md) y [MEDIA_STORAGE.md](../docs/MEDIA_STORAGE.md).
