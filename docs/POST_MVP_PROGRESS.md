# Registro de Actividades — Post-MVP Professionalization

**Proyecto:** DTS Delivery Platform  
**Alcance:** S0–S5 del plan post-MVP

---

## S0 — Deploy y paridad

- [ ] `railway up` o redeploy con migraciones: `0010`, `0011`, stores `0005`/`0006`, payments, orders `0003`, delivery `0003`, analytics `0002`
- [ ] Variables FCM/Firebase en Railway (customer + driver projects)
- [ ] Smoke E2E dispositivo real (ver `SMOKE_E2E_CHECKLIST.md`)
- [ ] Apple Sign-In cliente en iOS físico
- [ ] Docs stakeholder actualizados

## S1 — Horarios y zonas

- [ ] Merchant configura horarios vía `PUT /stores/{id}/opening-hours/`
- [ ] Merchant configura zonas vía `POST /stores/{id}/delivery-zones/`
- [ ] Celery Beat `sync-store-hours` activo
- [ ] Cliente respeta cobertura en checkout (error si fuera de zona)

## S2 — Pagos flexibles

- [x] Merchant crea métodos en `POST /stores/{id}/payment-methods/`
- [x] Cliente elige método en checkout (delivery + servicio)
- [x] Sandbox DTS `POST /orders/{id}/sandbox-pay/` + recibo en app cliente
- [x] Merchant confirma pago `POST /orders/{id}/confirm-payment/`
- [x] Estado `payment_status` visible en pedidos web-admin + KPI Cobrado hoy

## S3 — Conductor verificado

- [ ] Admin aprueba conductor `PATCH /accounts/admin/drivers/{id}/verification/`
- [ ] Conductor sube proof `POST /orders/{id}/proof-of-delivery/`
- [ ] Conductor solicita retiro `POST /accounts/driver/payouts/`

## S4 — UX marketplace cliente

- [x] Pantalla detalle tienda `/stores/{id}/public/`
- [x] Catálogo con búsqueda, filtros ES, imágenes, detalle público producto/servicio
- [x] Checkout servicio con paridad (dirección, agenda, cupón, pago)
- [x] Campos dinámicos por categoría en servicios (lavandería/aseo)
- [ ] ETA en tracking (`eta_minutes`)
- [ ] Map picker dirección, cached images, reordenar, sticky cart

## S5 — Marketplace + stores

- [ ] Favoritos, reviews, cupón validate
- [ ] Audit log admin `/analytics/audit/`
- [ ] Checklist stores (`STORE_RELEASE_CHECKLIST.md`)
