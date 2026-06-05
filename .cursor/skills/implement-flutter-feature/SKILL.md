---
name: implement-flutter-feature
description: Implementa un feature Flutter con Clean Architecture en flutter-customer o flutter-driver. Usar en tareas T4.x, T5.3, T5.4, o al crear pantallas/módulos móviles.
disable-model-invocation: true
---

# Implementar Feature Flutter

## Estructura

```
lib/features/<modulo>/
├── domain/entities/
├── domain/repositories/       # abstract
├── domain/usecases/
├── application/providers/
├── infrastructure/datasources/
├── infrastructure/models/
├── infrastructure/repositories/
└── presentation/screens/

test/features/<modulo>/
├── domain/
├── infrastructure/
└── presentation/
```

## Orden de implementación

1. **Entity** en `domain/entities/`
2. **Repository interface** en `domain/repositories/`
3. **Use case** en `domain/usecases/` + test con mocktail
4. **DTO + mapper** en `infrastructure/models/`
5. **Datasource** (dio) en `infrastructure/datasources/`
6. **Repository impl** en `infrastructure/repositories/`
7. **Provider** Riverpod en `application/providers/`
8. **Screen** en `presentation/screens/` + widget test
9. Registrar en `core/di/` y rutas `go_router`

## Tests

```bash
cd flutter-customer && flutter test test/features/<modulo>/
```

## Dependencias

- Estado: `flutter_riverpod`
- HTTP: `dio` con interceptors JWT en `core/network/`
- Mocks: `mocktail`

## Regla

`presentation/` nunca importa `infrastructure/` — solo use cases vía providers.
