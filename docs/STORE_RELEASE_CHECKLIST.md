# Checklist — Publicación App Store / Play Store

---

## Común (cliente + conductor)

- [ ] Version code/name incrementado en `pubspec.yaml`
- [ ] Iconos y splash actualizados
- [x] Política de privacidad URL accesible (`https://dtsdrop.com/es/privacy` — ver `docs/APP_STORE_CONNECT_REVIEW.md`)
- [x] Términos y eliminación de cuenta públicos (`/es/terms`, `/es/delete-account`)
- [ ] Permisos justificados (ubicación, cámara, notificaciones)
- [ ] Crash-free rate > 99% en TestFlight/Internal testing (mín. 3 días)
- [ ] Sin logs de tokens/credenciales en release build

## iOS

- [ ] Sign in with Apple habilitado (cliente + conductor)
- [ ] `aps-environment` en entitlements (push)
- [ ] Background modes: remote-notification
- [ ] App Store Connect: screenshots 6.7" y 5.5"
- [ ] Export compliance / encryption declarado

## Android

- [ ] `google-services.json` producción
- [ ] SHA-1/256 en **Firebase** (debug + upload + **Play App Signing**)
- [ ] SHA-1 en **Google Cloud API key** (Apps para Android) — ver guía abajo
- [ ] Target SDK según Play requirements
- [ ] Data safety form completado
- [ ] Play App Signing activo
- [ ] Google Sign-In probado con install desde Play Internal (no solo `flutter run`)

> **Guía completa (evitar “Android client … are blocked”):**  
> [`docs/PLAY_STORE_GOOGLE_SIGNIN.md`](PLAY_STORE_GOOGLE_SIGNIN.md)

## Post-launch

- [ ] Monitoreo Railway logs + Sentry (opcional)
- [ ] Rollback plan documentado en `DEPLOY_RAILWAY.md`
