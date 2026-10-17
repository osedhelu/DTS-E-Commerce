# Fase 6 — Despliegue y Lanzamiento (Manifiesto)

> Complementa `docs/DEPLOY_RAILWAY.md`, `docs/DEPLOY_DOCKER.md`, `docs/CI_GITHUB_ACTIONS.md`,
> `docs/STORE_RELEASE_CHECKLIST.md` y `docs/SMOKE_E2E_CHECKLIST.md`.
> Este documento lista **lo pendiente específico de la Fase 6** (rideshare + ajustes de calidad).

## 1. Migraciones pendientes a aplicar (backend)

Backlog completo de migraciones **nuevas** que no existen en staging/producción:

| App         | Migración                                        | Qué agrega                                                  |
| ----------- | ------------------------------------------------ | ----------------------------------------------------------- |
| `accounts`  | `0013_module_access`                             | Tabla `ModuleAccess` (Fase 4, T4.1)                         |
| `orders`    | `0005_alter_order_order_type_alter_order_status` | `order_type`/`status` flexibilizados (rideshare, Fase 1)    |
| `orders`    | `0006_add_order_type_status_index`               | **Índice compuesto `(order_type, status)`** (hallazgo T5.7) |
| `rides`     | `0001_initial`                                   | Modelos de viajes (Fase 1)                                  |
| `fleet`     | `0001_initial`                                   | Modelos de flota (Fase 1)                                   |
| `chat`      | `0003_alter_orderchatmessage_image`              | Drift de schema (choices/opciones)                          |
| `marketing` | `0005_alter_storepromotionmodel_discount_type`   | Drift de schema                                             |
| `payments`  | `0002_alter_storepaymentmethod_method_type`      | Drift de schema                                             |
| `products`  | `0006_alter_product_product_type`                | Drift de schema                                             |
| `stores`    | `0007_alter_store_status_alter_store_vertical`   | Drift de schema                                             |

### Railway (API)

```bash
# Opción A — release command (recomendado): ejecutar migraciones antes de servir tráfico
# En el deploy service config:  python manage.py migrate --noinput

# Opción B — manual, una sola vez:
railway run python manage.py migrate --noinput

# Verificación post-migración (debe salir limpio, sin drift):
railway run python manage.py makemigrations --check --dry-run
```

### Docker (make)

```bash
make backend-migrate-all   # aplica todas las migraciones en el contenedor
make restart-api           # reconstruye API + workers tras migrar
make doctor                # verifica ALLOWED_HOSTS + salud de la API
```

## 2. Web-admin — despliegue en Vercel

### Variables de entorno

| Variable              | Valor típico              | Requerida                 |
| --------------------- | ------------------------- | ------------------------- |
| `NEXT_PUBLIC_API_URL` | `https://api.dtsdrop.com` | ✅ (browser + BFF)        |
| `SUPPORT_EMAIL`       | soporte del merchant      | opcional (BFF de soporte) |
| `SUPPORT_WEBHOOK_URL` | webhook de soporte        | opcional                  |

### Pasos

1. Importar el repo `web-admin` en Vercel. Framework preset: **Next.js**
2. Build command: `npm ci && npm run build` — Output: `out`/standalone (estándar Next)
3. Configurar las env vars en Project Settings → Environment Variables (deployments de producción y preview)
4. **Importante (CORS):** el backend debe incluir el dominio de Vercel en `CORS_ALLOWED_ORIGINS` (si no, el BFF del browser falla). Ver `make doctor` tras el deploy.
5. Las rutas BFF (`/api/admin/*`, `/api/merchant/*`, `/api/public/*`) viven en el mismo dominio — no requiere config adicional.

## 3. Flutter — builds/bundles generados (local, macOS)

Artefactos **release** ya generados en este workspace:

| App      | APK (Android)                                                            | AAB (Play Console)                                                          | iOS (App Store Connect)                                  |
| -------- | ------------------------------------------------------------------------ | --------------------------------------------------------------------------- | -------------------------------------------------------- |
| Customer | `flutter-customer/build/app/outputs/flutter-apk/app-release.apk` (59 MB) | `flutter-customer/build/app/outputs/bundle/release/app-release.aab` (48 MB) | `flutter-customer/build/ios/iphoneos/Runner.app` (56 MB) |
| Driver   | `flutter-driver/build/app/outputs/flutter-apk/app-release.apk` (64 MB)   | `flutter-driver/build/app/outputs/bundle/release/app-release.aab` (54 MB)   | `flutter-driver/build/ios/iphoneos/Runner.app` (64 MB)   |

### Notas importantes

- **AAB:** se generó con `./gradlew bundleRelease` directo (no `flutter build appbundle`), por el bug conocido de Flutter CLI con NDK 28 (`flutter/flutter#186810`, `#188608`: el check post-build `_isAabStrippedOfDebugSymbols` falla aunque el bundle sea válido). El AAB es válido para Play Console.
- **iOS:** el `Runner.app` local es `--no-codesign` (verificación/CI). Para TestFlight/App Store: abrir `ios/Runner.xcworkspace` en Xcode, seleccionar el equipo de firma y archivar. Ver `docs/APP_STORE_CONNECT_REVIEW.md`.
- **Android SHA-1 de firma:** requisito previo de Google Sign-In. Ver `docs/PLAY_STORE_GOOGLE_SIGNIN.md`.
- Releases desde CI: los workflows de GitHub Actions por submodule (`docs/CI_GITHUB_ACTIONS.md`) pueden reproducirlos sin el workaround si el NDK/toolchain es completo.

### Play Console (Soft Launch)

1. Crear release en _Internal testing_ con el AAB correspondiente
2. Agregar el grupo de pilotos (email) — ideal para el soft launch
3. Pre-lanzar: revisar consola de pre-lanzamiento (crash/signals/accessibility)

### App Store Connect

1. Archivar desde Xcode con firma de distribución
2. Subir con Transporter o Xcode Organizer
3. TestFlight → grupo de pilotos _Internal_ (máx. 100 usuarios sin revisión externa)

## 4. Soft Launch — checklist

- [ ] Smoke prod: `docs/SMOKE_E2E_CHECKLIST.md` contra `api.dtsdrop.com` (solo smoke que no muten datos)
- [ ] Migraciones aplicadas y `makemigrations --check` limpio en staging **y** prod
- [ ] `CORS_ALLOWED_ORIGINS` incluye dominio Vercel
- [ ] `SERVE_MEDIA=true` en `docker-infrastructure/.env` (fotos de productos) — ver `docs/MEDIA_STORAGE.md`
- [ ] Convocar 20–50 pilotos (clientes + 10–15 conductores piloto)
- [ ] Monitorear errores de pago/geolocalización en los primeros 7 días
- [ ] Regla de oro: **no** publicar en abierto (production track) hasta 2 semanas de pilotos sin incidencias críticas

## 5. Verificación final (estado al cierre de la Fase 6)

| Check                                                        | Estado                              |
| ------------------------------------------------------------ | ----------------------------------- |
| Backend pytest (453 tests)                                   | ✅ passed                           |
| web-admin unit (17) + lint (0 errores) + build (66 páginas)  | ✅                                  |
| Playwright E2E web-admin (35 specs)                          | ✅ 35/35                            |
| Flutter customer (128 a) / driver (67 a) + `flutter analyze` | ✅                                  |
| Migraciones sin drift (`makemigrations --check`)             | ✅ tras commits `25732eb`/`3adb721` |
| Índice `orders_order_type_status_idx` (T5.7)                 | ✅ migración `orders/0006`          |

### Deuda técnica documentada (fuera de alcance Fase 6)

- 33 errores de ruff pre-existentes en backend (fuera de `features/orders/`, ya limpio)
- 2 warnings de lint en `ProductEditForm.tsx` (web-admin, pre-existentes)
- AAB requiere workaround local del bug de Flutter CLI (NDK 28) — CI inmune
- 7 specs E2E merchant desactualizados: corregidos (4) + root cause de feedback de categorías (fix de código)
