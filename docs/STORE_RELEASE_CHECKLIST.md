# Checklist — Publicación App Store / Play Store

---

## Común (cliente + conductor)

- [ ] Version code/name incrementado en `pubspec.yaml`
- [ ] Iconos y splash actualizados
- [ ] Política de privacidad URL accesible
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
- [ ] SHA-1/256 en Firebase Console
- [ ] Target SDK según Play requirements
- [ ] Data safety form completado
- [ ] Play App Signing activo

## Post-launch

- [ ] Monitoreo Railway logs + Sentry (opcional)
- [ ] Rollback plan documentado en `DEPLOY_RAILWAY.md`
