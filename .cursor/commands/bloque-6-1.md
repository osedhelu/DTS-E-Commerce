---
description: "Fase 6 bloque 6.1: Backend registro público + verificación email"
---

# Bloque 6.1 — Backend registro + email

Implementa **T6.1.1 – T6.1.9** (ver `docs/TASKS.md` Bloque 6.1).

## Alcance

- `EmailVerificationToken` domain + model + migración
- `StoreVertical` enum (FOOD, SERVICES, RETAIL)
- `RegisterMerchantWithStoreUseCase` (atómico user + profile + store + categorías semilla)
- `VerifyEmailUseCase`
- APIs: `POST /accounts/merchant/register/`, `POST /accounts/verify-email/`, `POST /accounts/resend-verification/`
- Celery: `send_merchant_verification_email`

## Tests obligatorios

`test_verification_token_expired_raises`, `test_verification_token_persistence`, `test_store_vertical_values`, `test_merchant_register_creates_store_and_categories`, `test_verify_email_activates_merchant`, `test_merchant_public_register_201`, `test_merchant_register_duplicate_email_400`, `test_verify_email_api_200`, `test_send_verification_email_task`, `test_resend_verification_email`

## Validar

```bash
make fase6-test BLOCK=6.1
```

Marca T6.1.1–T6.1.9 en `docs/PROGRESS.md`. Siguiente: `/bloque-6-2`.
