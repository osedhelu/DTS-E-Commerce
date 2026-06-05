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

auth → stores → catalog → cart/checkout → tracking → **push (T4.1.5, T4.5.3–4.5.5)**

Consulta `docs/PUSH_NOTIFICATIONS.md` para integrar FCM sin romper el flujo.

## Push notifications (cliente)

- T4.1.5: Firebase init
- T4.5.3: Registrar token en backend (`T1.2.8` debe existir)
- T4.5.4–4.5.5: Recibir push "pedido en camino" → abrir tracking

## Orden conductor

auth → availability → orders (+ T4.8.2 FCM alerta) → location
