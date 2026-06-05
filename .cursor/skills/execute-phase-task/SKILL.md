---
name: execute-phase-task
description: Ejecuta una tarea del roadmap DTS por ID (T1.1.1, T4.2.3, etc.) con implementación, tests y actualización de progreso. Usar con /tarea o cuando el usuario pida completar una tarea específica del proyecto.
disable-model-invocation: true
---

# Ejecutar Tarea del Roadmap

## Fuentes de verdad

- Tareas y tests: `docs/TASKS.md`
- Progreso: `docs/PROGRESS.md`
- Arquitectura: `docs/ARCHITECTURE.md`

## Algoritmo

```
1. PARSE task_id (ej. T1.5.2)
2. FIND en TASKS.md → descripción + tests obligatorios
3. CHECK PROGRESS.md → prerequisitos del bloque
4. DETERMINE proyecto:
   - T1.x, T2.x, T5.1, T5.2 → backend/
   - T3.1–T3.4 → web-admin/ (Next.js)
   - T3.5.x → backend/ (marketing API) + web-admin/ (UI cupones)
   - T4.1-T4.5, T5.3 → flutter-customer/
   - T4.6-T4.9, T5.4 → flutter-driver/
5. IMPLEMENT (skill: implement-django-feature | implement-nextjs-feature | implement-flutter-feature)
6. RUN tests listados en TASKS.md
7. IF green → mark [x] en PROGRESS.md
8. REPORT resultado + siguiente tarea
```

## Criterio de done

- [ ] Código implementado según arquitectura
- [ ] Tests de TASKS.md escritos y verdes
- [ ] PROGRESS.md actualizado
- [ ] Sin scope creep (solo esa tarea)

## Comandos útiles

```bash
# Backend
cd backend && uv sync && make test

# Flutter
cd flutter-customer && flutter pub get && flutter test
cd flutter-driver && flutter pub get && flutter test

# web-admin
make web-admin-dev
make web-admin-build
make web-admin-lint
```
