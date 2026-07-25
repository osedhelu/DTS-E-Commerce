# CI — GitHub Actions por repositorio

Cada app tiene su propio workflow en `.github/workflows/ci.yml`. El monorepo raíz también ejecuta la misma batería con submodules.

| Repo | Workflow | Qué corre |
|------|----------|-----------|
| [DTS-E-Commerce](https://github.com/osedhelu/DTS-E-Commerce) | `.github/workflows/ci.yml` | backend + 2 Flutter + web-admin |
| [DTS-backend](https://github.com/osedhelu/DTS-backend) | `backend/.github/workflows/ci.yml` | PostGIS + GDAL + pytest (smoke realtime + suite completa) |
| [DTS-web-admin](https://github.com/osedhelu/DTS-web-admin) | `web-admin/.github/workflows/ci.yml` | lint + `test:unit` + build |
| [DTS-flutter-customer](https://github.com/osedhelu/DTS-flutter-customer) | `flutter-customer/.github/workflows/ci.yml` | analyze + WS URI smoke + `flutter test` |
| [DTS-flutter-driver](https://github.com/osedhelu/DTS-flutter-driver) | `flutter-driver/.github/workflows/ci.yml` | analyze + WS/offers smoke + `flutter test` |

Branches disparan CI: `main`, `develop` (y `master` en submodules por compatibilidad).

---

## ¿Hay que registrar Secrets / Variables?

### Unit / integración (CI por defecto) — **no hace falta nada**

Los tests mockean FCM, usan PostGIS/Redis como **services** del runner, y Channel layer en memoria. **No** necesitas pegar credenciales de Firebase, Railway ni Google en GitHub Actions para que pase el CI actual.

| Variable | ¿Secret? | Dónde | Notas |
|----------|----------|-------|-------|
| — | — | — | Ninguna obligatoria |

El job de `web-admin` define en el YAML:

```yaml
NEXT_PUBLIC_API_URL: http://localhost:8000/api/v1
```

Es un placeholder de build; no llama al backend real.

### Opcional — solo si activas E2E Playwright en CI

Hoy el job E2E está **comentado** en `web-admin`. Si lo descomentas, registra en el repo **DTS-web-admin**:

**Settings → Secrets and variables → Actions → Secrets**

| Secret | Ejemplo | Uso |
|--------|---------|-----|
| `E2E_BASE_URL` | `https://tu-web.up.railway.app` | Base URL Playwright |
| `E2E_MERCHANT_EMAIL` | `merchant@…` | Login comercio demo |
| `E2E_MERCHANT_PASSWORD` | `••••` | Password demo |

**Variables (opcionales):**

| Variable | Valor | Uso |
|----------|-------|-----|
| `RUN_E2E` | `true` | Gate del job e2e (si usas `vars.RUN_E2E`) |

También hace falta un entorno estable (backend + web desplegados) o levantar stack en el mismo workflow.

### Producción / deploy (no CI de tests)

Estas van en **Railway** (o el host), no en GitHub Actions de pytest:

| Variable | Servicio |
|----------|----------|
| `DATABASE_URL`, `REDIS_URL`, `SECRET_KEY`, `ALLOWED_HOSTS` | DTS-backend / workers |
| `FIREBASE_*_SERVICE_ACCOUNT_JSON` o paths FCM | backend (push real) |
| `NEXT_PUBLIC_API_URL`, `WEB_URL` | web-admin / backend |
| Google Maps / Sign-In client IDs | apps Flutter (build store) |

---

## Activar Actions en cada repo (checklist)

Haz esto **una vez** por repositorio en GitHub:

1. Abre el repo → **Settings → Actions → General**
2. **Actions permissions:** Allow all actions and reusable workflows
3. **Workflow permissions:** Read and write (o Read) según tu política
4. Confirma que no hay branch protection bloqueando checks sin workflow histórico

Luego:

```bash
# En cada submodule, commit + push del workflow
cd backend && git checkout -b chore/ci-github-actions
git add .github/workflows/ci.yml && git commit -m "chore(ci): GitHub Actions pytest PostGIS + realtime smoke"
git push -u origin HEAD

cd ../web-admin && # igual con ci.yml + package.json (+ package-lock si cambió)
cd ../flutter-customer && # ci.yml
cd ../flutter-driver && # ci.yml

# Monorepo raíz
cd .. && git add .github/workflows/ci.yml docs/CI_GITHUB_ACTIONS.md
git commit -m "chore(ci): ampliar monorepo CI y documentar secrets"
git push
```

Tras el push, revisa la pestaña **Actions** de cada repo.

---

## Smoke Realtime que corre en CI (E28 + bloque A–D)

**Backend**

- `test_order_signals` (push READY / searching_driver)
- `features/notifications/tests/` (mapper, observability, recipients, chat push)
- `features/chat/tests/` (ACL merchant, participants)
- `test_ws_origin` (NativeClientOriginValidator)
- `test_get_order_tracking_destination`
- `test_radius_and_work_zone`

**Flutter**

- `env_ws_uri_test.dart` (customer + driver)
- `test/features/offers/` (driver refresh)

**web-admin**

- `npm run test:unit` → order-chat-store (B11)

---

## Fallos frecuentes

| Síntoma | Causa | Fix |
|---------|-------|-----|
| GDAL import error | Falta `CI=true` + `GDAL_LIBRARY_PATH` | Ya van en el workflow |
| PostGIS health fail | Imagen lenta | Reintentar; health retries ya configurados |
| `flutter analyze` fails | Warnings tratados como error | Corregir código o ajustar `analysis_options.yaml` |
| Submodule en monorepo vacío | Checkout sin `submodules: recursive` | El YAML raíz ya lo pide |
| Actions no aparece en submodule | Workflow solo en monorepo | Hay que **pushear** `.github/` al remote del submodule |
