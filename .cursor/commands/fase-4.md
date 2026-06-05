---
description: Ejecutar Fase 4 — Apps Flutter Cliente y Conductor
---

# Fase 4 — Desarrollo Móvil Flutter

## Prerequisito

Fase 1 completa (API disponible). Idealmente Fase 2 también.

## Proyectos

- `flutter-customer/` — bloques 4.1 a 4.5
- `flutter-driver/` — bloques 4.6 a 4.9

## Arquitectura obligatoria

```
lib/features/<modulo>/
├── domain/
├── application/
├── infrastructure/
└── presentation/
```

Riverpod para estado. Ver `.cursor/rules/flutter-clean-architecture.mdc`.

## Por cada tarea T4.x.x

1. Implementa capa domain primero + tests
2. Infrastructure (API con dio) + tests
3. Application (providers) + presentation
4. `flutter test test/features/<modulo>/`
5. Actualiza `docs/PROGRESS.md`

## Orden cliente

auth → stores → catalog → cart/checkout → tracking

## Orden conductor

auth → availability → orders → location
