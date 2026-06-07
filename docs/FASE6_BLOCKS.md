# Fase 6 — Guía por bloques (comandos + tests)

Ejecuta **un bloque completo** (implementación + tests unificados) con Cursor o Make.

**Documento maestro:** [MERCHANT_ONBOARDING.md](MERCHANT_ONBOARDING.md) · **Tareas:** [TASKS.md](TASKS.md) Fase 6

---

## Comandos rápidos

| Acción | Cursor | Terminal |
|--------|--------|----------|
| Implementar bloque 6.1 | `/bloque-6.1` | — |
| Implementar bloque 6.2 | `/bloque-6.2` | — |
| … | `/bloque-6.X` | — |
| Solo tests bloque 6.1 | — | `make fase6-test BLOCK=6.1` |
| Tests todos los bloques | — | `make fase6-test BLOCK=all` |
| Una tarea suelta | `/tarea T6.1.4` | `make fase6-test-task TASK=T6.1.4` |

---

## Bloque 6.1 — Backend registro + email

**Tareas:** T6.1.1 – T6.1.9  
**Proyecto:** `backend/`

| Test esperado | Tipo |
|---------------|------|
| `test_verification_token_expired_raises` | domain |
| `test_verification_token_persistence` | infra |
| `test_store_vertical_values` | domain stores |
| `test_merchant_register_creates_store_and_categories` | application |
| `test_verify_email_activates_merchant` | application |
| `test_merchant_public_register_201` | API |
| `test_merchant_register_duplicate_email_400` | API |
| `test_verify_email_api_200` | API |
| `test_send_verification_email_task` | Celery |
| `test_resend_verification_email` | API |

```bash
make fase6-test BLOCK=6.1
# equivalente:
./scripts/fase6-block-test.sh 6.1
```

---

## Bloque 6.2 — Landing + wizard registro

**Tareas:** T6.2.1 – T6.2.11  
**Proyecto:** `web-admin/`

| Test | Tipo |
|------|------|
| `merchant_landing_renders_test` | E2E |
| `merchant_public_registration_flow_test` | E2E |
| `merchant_email_confirmation_flow_test` | E2E |
| `npm run build` + `lint` | CI |

```bash
make fase6-test BLOCK=6.2
cd web-admin && npm run test:e2e:fase6-6.2
```

---

## Bloque 6.3 — Backend catálogo enriquecido

**Tareas:** T6.3.1 – T6.3.7 · **Proyecto:** `backend/`

```bash
make fase6-test BLOCK=6.3
```

---

## Bloque 6.4 — Frontend catálogo enriquecido

**Tareas:** T6.4.1 – T6.4.9 · **Proyecto:** `web-admin/`

| E2E |
|-----|
| `food_product_with_variants_test` |
| `product_photo_upload_test` |

```bash
make fase6-test BLOCK=6.4
```

---

## Bloque 6.5 — Dashboard merchant

**Tareas:** T6.5.1 – T6.5.5 · **Backend + web-admin**

```bash
make fase6-test BLOCK=6.5
```

---

## Bloque 6.6 — Promociones merchant

**Tareas:** T6.6.1 – T6.6.5

```bash
make fase6-test BLOCK=6.6
```

---

## Bloque 6.7 — Configuración tienda

**Tareas:** T6.7.1 – T6.7.4

```bash
make fase6-test BLOCK=6.7
```

---

## Bloque 6.8 — Storage imágenes

**Tareas:** T6.8.1 – T6.8.3 · **Backend**

```bash
make fase6-test BLOCK=6.8
```

---

## Bloque 6.9 — UX gaps Fase 3

**Tareas:** T6.9.1 – T6.9.5 · **web-admin**

```bash
make fase6-test BLOCK=6.9
```

---

## Bloque 6.10 — Admin moderación

**Tareas:** T6.10.1 – T6.10.4

```bash
make fase6-test BLOCK=6.10
```

---

## Workflow recomendado por bloque

1. `/bloque-6.1` — el agente implementa T6.1.1…T6.1.9
2. `make fase6-test BLOCK=6.1` — valida tests unificados
3. Marca `[x]` en `PROGRESS.md` bloque 6.1
4. `/bloque-6.2` — siguiente bloque

## Prerequisitos tests

```bash
make docker-up          # PostGIS + Redis + Mailpit
make backend-sync
cd backend && uv run python manage.py migrate
```

E2E web-admin requiere Playwright:

```bash
cd web-admin && npx playwright install chromium
```
