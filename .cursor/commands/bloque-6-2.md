---
description: "Fase 6 bloque 6.2: Landing /vender + wizard registro + confirmar email"
---

# Bloque 6.2 — Frontend landing + wizard

Implementa **T6.2.1 – T6.2.11**.

## Prerequisito

Bloque 6.1 completo (API registro + verify email).

## Alcance

- `/vender` landing pública
- `/registro-comercio` wizard 3 pasos + `onboarding-store` Zustand
- BFF `/api/public/merchant/register`
- `/confirmar-email`, `/registro-comercio/exito`
- Middleware rutas públicas sin JWT

## Tests

`merchant_landing_renders_test`, `merchant_public_registration_flow_test`, `merchant_email_confirmation_flow_test`, `npm run lint`, `npm run build`

## Validar

```bash
make fase6-test BLOCK=6.2
```

Siguiente: `/bloque-6-3`.
