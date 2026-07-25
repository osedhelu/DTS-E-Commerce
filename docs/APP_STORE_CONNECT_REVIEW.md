# App Store Connect — Review Information (DTS)

Valores para el formulario de App Store Connect (apps **cliente** y **conductor**).  
**No publicar contraseñas** en la web pública.

## Contacto

| Campo | Valor |
|-------|--------|
| Contact first name | Oscar |
| Contact last name | Herrera |
| Contact phone | +573017982676 |
| Contact email | soporte@dtsdrop.com |

## Demo account

| Campo | Valor |
|-------|--------|
| Demo account required | **Yes** |
| Demo user | `test@test.com` |
| Demo password | `ADMadm1234` |

> Cuenta de prueba cliente ya cargada en App Store Connect / TestFlight Beta Review. Si deja de funcionar, crea otra y actualiza este doc + ASC.

## Notes (copiar a App Store Connect)

```
Login: Google Sign-In or Sign in with Apple (iOS). Demo account credentials are in Review Information above.

Review guide (no passwords): https://dtsdrop.com/en/app-review

What to test (customer): browse stores, featured products, place/view order, tracking, order chat.
What to test (driver): go online, accept offer, delivery map/status, order chat.

Privacy: https://dtsdrop.com/es/privacy
Terms: https://dtsdrop.com/es/terms
Delete account: https://dtsdrop.com/es/delete-account
Support: Oscar Herrera <soporte@dtsdrop.com>
```

## URLs públicas (Privacy Policy URL)

| Uso | URL |
|-----|-----|
| Privacy Policy (ES) | https://dtsdrop.com/es/privacy |
| Privacy Policy (EN) | https://dtsdrop.com/en/privacy |
| Terms (ES) | https://dtsdrop.com/es/terms |
| Terms (EN) | https://dtsdrop.com/en/terms |
| Delete account | https://dtsdrop.com/es/delete-account |
| App Review guide | https://dtsdrop.com/es/app-review |

En App Store Connect → App Privacy / Privacy Policy URL, usa como mínimo:

`https://dtsdrop.com/es/privacy`

## Solicitudes de eliminación de cuenta

El formulario en `/delete-account` hace `POST /api/public/delete-account-request` y deja traza en logs del web-admin (`[delete-account-request]`). Opcional: configura `SUPPORT_WEBHOOK_URL` o `SUPPORT_EMAIL` en el servicio Next.js.
