# Fase 4 — Guía por bloques (Flutter Cliente + Conductor)

Ejecuta **un bloque completo** con Cursor o Make.

**Tareas:** [TASKS.md](TASKS.md) Fase 4 · **API:** [FLUTTER_API.md](FLUTTER_API.md) · **Progreso:** [PROGRESS.md](PROGRESS.md)

**API staging:** `https://dts-backend-production-c84e.up.railway.app/api/v1`

---

## Comandos rápidos

| Acción | Cursor | Terminal |
|--------|--------|----------|
| Fase completa | `/fase-4` | — |
| Bloque 4.0 (backend gap) | `/bloque-4-0` | `make fase4-test BLOCK=4.0` |
| Bloque 4.1 | `/bloque-4-1` | `make fase4-test BLOCK=4.1` |
| … | `/bloque-4-X` | `make fase4-test BLOCK=4.X` |
| Todos los bloques | — | `make fase4-test BLOCK=all` |
| Una tarea | `/tarea T4.2.1` | `make fase4-test-task TASK=T4.2.1` |

---

## Bloque 4.0 — Backend driver availability (T4.0.1)

**Proyecto:** `backend/`  
**Prerequisito** para bloques 4.7 y 4.9.

| Endpoint | `PATCH /api/v1/accounts/driver/availability/` |
| Body | `{ "is_online": true, "latitude": 4.71, "longitude": -74.07 }` |

Tests: `test_driver_toggle_online`, `test_driver_updates_location`

```bash
make fase4-test BLOCK=4.0
```

---

## Bloque 4.1 — Cliente core + auth

**Tareas:** T4.1.1 – T4.1.4 · **Proyecto:** `flutter-customer/`

| Test | Archivo |
|------|---------|
| `flutter test` | setup |
| `api_client_adds_auth_header_test` | `test/core/network/` |
| `login_usecase_success_test`, `login_usecase_failure_test` | `test/features/auth/domain/` |
| `login_screen_widget_test` | `test/features/auth/presentation/` |

```bash
make fase4-test BLOCK=4.1
```

---

## Bloque 4.2 — Cliente stores

**Tareas:** T4.2.1 – T4.2.3

```bash
make fase4-test BLOCK=4.2
```

---

## Bloque 4.3 — Cliente catalog

**Tareas:** T4.3.1 – T4.3.4

```bash
make fase4-test BLOCK=4.3
```

---

## Bloque 4.4 — Cliente cart + checkout

**Tareas:** T4.4.1 – T4.4.5

```bash
make fase4-test BLOCK=4.4
```

---

## Bloque 4.5 — Cliente tracking + push

**Tareas:** T4.1.5, T4.5.1 – T4.5.5

Requiere Celery worker + FCM en Railway para prueba manual.

```bash
make fase4-test BLOCK=4.5
```

---

## Bloque 4.6 — Conductor setup + auth

**Tareas:** T4.6.1 – T4.6.2 · **Proyecto:** `flutter-driver/`

```bash
make fase4-test BLOCK=4.6
```

---

## Bloque 4.7 — Conductor availability

**Tareas:** T4.7.1 – T4.7.2 · **Prerequisito:** bloque 4.0

```bash
make fase4-test BLOCK=4.7
```

---

## Bloque 4.8 — Conductor orders

**Tareas:** T4.8.1 – T4.8.3

```bash
make fase4-test BLOCK=4.8
```

---

## Bloque 4.9 — Conductor location

**Tareas:** T4.9.1 – T4.9.3

```bash
make fase4-test BLOCK=4.9
```

---

## Criterio de salida Fase 4

- 32/32 tareas en PROGRESS.md
- `make flutter-test` verde
- Flujos manuales contra Railway staging documentados en checklist final
