---
name: implement-django-feature
description: Implementa un módulo Django con Clean Architecture vertical slice en backend/features/. Usar al trabajar en backend, tareas T1.x, T2.x, T3.x, o cuando el usuario pida crear/modificar un feature Django.
disable-model-invocation: true
---

# Implementar Feature Django

## Estructura objetivo

```
backend/features/<modulo>/
├── domain/
│   ├── entities.py
│   ├── value_objects.py
│   ├── repositories.py    # Protocol
│   └── services.py
├── application/
│   ├── use_cases/
│   └── dto.py
├── infrastructure/
│   ├── models.py
│   ├── repositories.py
│   ├── serializers.py
│   ├── views.py
│   ├── signals.py
│   └── tasks.py
├── tests/
│   ├── domain/
│   ├── application/
│   └── infrastructure/
└── apps.py
```

## Workflow

1. Consultar `docs/TASKS.md` para el ID de tarea
2. Implementar `domain/` primero (sin imports Django)
3. `application/use_cases/` con inyección de repos
4. `infrastructure/` con ORM, DRF, signals
5. Tests por capa según TASKS.md
6. `cd backend && uv run pytest features/<modulo>/tests/ -v`
7. Marcar progreso en `docs/PROGRESS.md`

## Django integration

- Registrar app en `core/settings/base.py` INSTALLED_APPS
- URLs en `features/<modulo>/infrastructure/urls.py`, incluir en `core/urls.py`
- `AUTH_USER_MODEL` ya es `accounts.CustomUser`

## Anti-patterns

- ❌ Lógica de negocio en `views.py` o `serializers.py`
- ❌ Importar `models.py` desde `domain/`
- ❌ Saltar tests de la tarea
