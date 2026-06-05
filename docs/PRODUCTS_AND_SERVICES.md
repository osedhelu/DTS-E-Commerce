# Catálogo: Productos físicos y Servicios a domicilio

Documento de referencia para el módulo `products` y su impacto en pedidos, portales y apps móviles.

**Estado:** decisión de diseño adoptada en Fase 1.4  
**Relacionado:** [TASKS.md](TASKS.md) bloques 1.4–1.5, [PROGRESS.md](PROGRESS.md)

---

## Objetivo de negocio

La plataforma no vende solo comida. También soporta **servicios** que el comercio (o su personal) presta en el domicilio del cliente, con pago a través de la app.

**Ejemplo — Limpieza a domicilio:**
1. Merchant crea tienda *“Limpieza Express”*
2. Categoría raíz *Servicios del hogar* → subcategoría *Limpieza*
3. Servicio *“Limpieza profunda apartamento”* — precio fijo, duración estimada 180 min
4. Cliente solicita el servicio, indica dirección y notas
5. Merchant acepta y agenda; proveedor va al domicilio
6. Servicio completado → pago confirmado en la app

---

## Modelo de dominio (Fase 1.4)

### Jerarquía de categorías (2 niveles)

| Nivel | Campo | Ejemplo |
|-------|-------|---------|
| Categoría raíz | `parent_id = null` | Comida, Servicios del hogar |
| Subcategoría | `parent_id = id padre` | Hamburguesas, Limpieza, Plomería |

Cada categoría pertenece a una **tienda** (`store_id`).

### Tipos de ítem (`ProductType`)

| Tipo | Descripción | Stock | Visita a domicilio |
|------|-------------|-------|-------------------|
| `PHYSICAL` | Comida, bebidas, artículos tangibles | Sí (`tracks_stock`) | No |
| `SERVICE` | Limpieza, reparaciones, etc. | No | Sí (`requires_on_site_visit`) |

### Campos clave en `Product`

| Campo | PHYSICAL | SERVICE |
|-------|----------|---------|
| `price` | Obligatorio > 0 | Obligatorio > 0 |
| `stock` | Inventario | Ignorado (siempre 0) |
| `category_id` | Categoría raíz | Categoría raíz |
| `subcategory_id` | Opcional | Recomendado |
| `duration_minutes` | — | Duración estimada del servicio |
| `description` | Ingredientes, etc. | Qué incluye el servicio |

**Implementado en código (T1.4.1):**
- `backend/features/products/domain/entities.py` — `Category`, `Product`, `ProductType`
- Tests: `test_product_price_positive`, `test_category_hierarchy`, `test_service_product_on_site_visit`

**Pendiente de implementar:** ver [PROGRESS.md](PROGRESS.md) bloque 1.4 (T1.4.2 en adelante).

---

## Reglas de negocio

### StockValidator (T1.4.2)
- Solo valida stock para `ProductType.PHYSICAL`
- Los servicios **nunca** fallan por stock insuficiente

### Modelos ORM (T1.4.3)
- `Category.parent` → FK self nullable (subcategorías)
- `Product.product_type`, `duration_minutes`, `requires_on_site_visit`
- Índice por `(store_id, product_type)` para filtros en API

### API catálogo (T1.4.5)
- `GET /stores/{id}/categories/` — árbol raíz + subcategorías
- `GET /stores/{id}/products/?type=physical|service&category=&subcategory=`
- CRUD merchant distingue campos según `product_type`

---

## Pedidos: dos flujos (Fase 1.5)

### Pedido de productos físicos (delivery)
Flujo existente con conductor:

```
CREATED → ACCEPTED_BY_MERCHANT → IN_PREPARATION → READY_FOR_PICKUP
→ SEARCHING_DRIVER → DRIVER_ASSIGNED → PICKED_UP → ON_THE_WAY → DELIVERED
```

### Pedido de servicio (sin conductor de plataforma)
El proveedor es el comercio o su personal asignado — **no** pasa por `SEARCHING_DRIVER`:

```
CREATED → ACCEPTED_BY_MERCHANT → SCHEDULED → PROVIDER_EN_ROUTE
→ IN_PROGRESS → COMPLETED → (PAID)
(CANCELLED en cualquier punto previo a IN_PROGRESS)
```

Campos adicionales en pedido de servicio (`ServiceOrderDetails`, T1.5.8):
- `service_address` — dirección del cliente (GeoLocation / texto)
- `scheduled_at` — fecha/hora acordada (opcional al crear, merchant confirma)
- `customer_notes` — instrucciones (*“timbre roto, llamar al llegar”*)
- `duration_minutes` — copiado del producto al crear el ítem

**Tareas nuevas:** T1.5.8, T1.5.9, T1.5.10 en [TASKS.md](TASKS.md).

---

## Portales web (Fase 3)

| Tarea | Entregable |
|-------|------------|
| T3.1.2 | CRUD productos **y servicios** (formulario condicional por tipo) |
| T3.1.4 | CRUD categorías y subcategorías por tienda |
| T3.1.5 | Gestión stock solo productos físicos |
| T3.2.4 | Dashboard pedidos de servicio (aceptar, agendar, marcar en curso/completado) |

---

## Apps Flutter (Fase 4)

| Tarea | Entregable |
|-------|------------|
| T4.3.3 | Catálogo con filtros categoría/subcategoría y badge Physical/Service |
| T4.3.4 | Detalle servicio: duración, descripción, botón *Solicitar* |
| T4.4.4 | Checkout servicio: dirección del cliente + notas + ventana horaria preferida |
| T4.4.5 | Seguimiento pedido servicio (estados sin mapa de conductor, opcional mapa proveedor) |

La app **conductor** sigue siendo para delivery de productos físicos. Servicios a domicilio los gestiona el merchant desde portal o app merchant futura (fuera de alcance Fase 4 inicial).

---

## Matriz: qué está hecho vs pendiente

| Componente | Estado | Tarea |
|------------|--------|-------|
| `ProductType`, `Category` jerárquica, `Product` servicio | ✅ Hecho | T1.4.1 |
| `StockValidator` (solo PHYSICAL) | ✅ Hecho | T1.4.2 |
| Modelos ORM Category parent + Product type | ✅ Hecho | T1.4.3 |
| Use cases CRUD producto/servicio/categorías | ✅ Hecho | T1.4.4 |
| API catálogo con árbol categorías | ⬜ Pendiente | T1.4.5 |
| `OrderType` + detalles servicio | ⬜ Pendiente | T1.5.8 |
| State machine pedido servicio | ⬜ Pendiente | T1.5.9 |
| API checkout servicio | ⬜ Pendiente | T1.5.10 |
| Portal CRUD categorías | ⬜ Pendiente | T3.1.4 |
| Flutter catálogo/filtros servicio | ⬜ Pendiente | T4.3.3–T4.3.4 |
| Flutter checkout servicio | ⬜ Pendiente | T4.4.4 |

---

## Convención para el agente

Al implementar tareas del bloque **1.4** o **1.5**, leer este documento antes de codificar.  
Al completar una fila de la matriz, actualizar [PROGRESS.md](PROGRESS.md).
