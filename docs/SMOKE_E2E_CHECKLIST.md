# Smoke E2E — Piloto producción

**Backend:** `https://dts-backend-production-c84e.up.railway.app/api/v1`  
**Duración estimada:** 45–60 min con 2 dispositivos

---

## Pre-requisitos

- [ ] Backend desplegado con migraciones al día
- [ ] Comercio de prueba con productos activos y tienda OPEN
- [ ] Conductor verificado (`verification_status=approved`) y online
- [ ] Cliente con dirección guardada dentro de zona de entrega
- [ ] FCM configurado (push en foreground/background)

---

## Flujo A — Cliente (flutter-customer)

| # | Paso | OK |
|---|------|-----|
| 1 | Login email o Google/Apple | ☐ |
| 2 | Home carga tiendas + chips Productos/Servicios + búsqueda | ☐ |
| 3 | Detalle tienda muestra horarios/zona | ☐ |
| 4 | Catálogo: buscar servicio (ej. aseo/lavandería), filtrar categoría/subcategoría, ver imagen | ☐ |
| 5 | Detalle servicio: campos dinámicos + solicitar → checkout servicio | ☐ |
| 6 | Checkout servicio: dirección, agenda, cupón, método de pago | ☐ |
| 7 | Sandbox DTS: formulario tarjeta 4242 → recibo con comisión/neto | ☐ |
| 8 | Pedido `payment_status=paid` en API + tab Pedidos | ☐ |
| 9 | Tracking mapa muestra ETA | ☐ |
| 10 | Chat con conductor responde en vivo | ☐ |
| 11 | Push al cambiar estado (asignado, en camino) | ☐ |

## Flujo A2 — Cliente delivery (opcional)

| # | Paso | OK |
|---|------|-----|
| 1 | Catálogo productos físicos → carrito → checkout delivery | ☐ |
| 2 | Método QR/efectivo o sandbox según entorno | ☐ |

---

## Flujo B — Conductor (flutter-driver)

| # | Paso | OK |
|---|------|-----|
| 1 | Login + toggle online | ☐ |
| 2 | Recibe oferta push + modal countdown | ☐ |
| 3 | Acepta → mapa activo pickup/dropoff | ☐ |
| 4 | Chat con cliente | ☐ |
| 5 | Marca entregado + foto proof of delivery | ☐ |
| 6 | Ganancias reflejan pedido entregado | ☐ |

---

## Flujo C — Merchant (web-admin / API)

| # | Paso | OK |
|---|------|-----|
| 1 | Dashboard muestra KPI **Cobrado hoy** tras sandbox-pay | ☐ |
| 2 | Tabla pedidos muestra badge `payment_status` (Pagado/Pendiente) | ☐ |
| 3 | Detalle/card pedido servicio muestra referencia de pago | ☐ |
| 4 | Confirma pago manual (QR/efectivo) si aplica | ☐ |

---

## Criterio de éxito

Los 3 roles completan un pedido real sin intervención manual en base de datos.
