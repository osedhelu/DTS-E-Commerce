# Madurez portal administrativo — Análisis y plan (Fase 7)

**Estado:** Fase 6 MVP ✅ · Fase 6.12 extras ✅ · **Fase 7 pendiente**  
**Tareas:** [TASKS.md](TASKS.md) Fase 7 · **Progreso:** [PROGRESS.md](PROGRESS.md)  
**Comandos:** `/fase-7` · `/bloque-7-1` … `/bloque-7-7`

---

## Veredicto honesto

| Área | Estado | Comentario |
|------|--------|------------|
| **MVP seller + super admin** | ✅ Operativo | Registro, catálogo, pedidos, promos, dashboard, moderación |
| **Production-ready admin** | ⬜ ~60 % | Falta calidad E2E, operación diaria, escala multi-usuario |
| **Producto end-to-end** | ⬜ ~67 % | Sin Flutter cliente/conductor ni WebSocket (Fases 4–5) |

**Frase para stakeholders:**

> Tenemos el portal administrativo en MVP operativo. Falta pulir tests de lo reciente, horarios/zonas de entrega, madurez de plataforma (auditoría, alertas, reportes) y las apps móviles para cerrar el ciclo completo de negocio.

---

## 1. Calidad y confianza

| Gap | Impacto | Tarea |
|-----|---------|-------|
| E2E no cubre promos con fechas, import plantillas, SVG categorías, reactivar promo | Regresiones silenciosas | T7.1.1–T7.1.4 |
| CI frontend: TypeScript estricto en specs Playwright | PRs fallan por fricción | T7.1.5 |
| Trabajo 6.12 no tenía IDs en TASKS hasta ahora | Trazabilidad | T6.12.x ✅ documentado |

**Prioridad:** 🔴 Alta — ejecutar `/bloque-7-1` primero.

---

## 2. Operación real del comercio

| Gap | Impacto | Tarea |
|-----|---------|-------|
| Horarios de tienda — marketing promete, no hay UI | Comercio debe togglear manual 24/7 | T7.2.1–T7.2.4 |
| Zonas de entrega — sin cobertura geográfica | Pedidos fuera de área | T7.2.5–T7.2.7 |
| Pedidos solo polling (~15s) | Latencia operativa | T7.7.x + Fase 5 |
| Promos expiradas: `is_active=true` pero no aplican | Confusión merchant | T7.3.x |

**Prioridad:** 🟠 Media-alta — `/bloque-7-2` y `/bloque-7-3`.

---

## 3. Modelo producto (deuda conceptual)

Conviven:

- **`ProductVariant`** — S/M/L legacy (vertical FOOD, T6.3.x)
- **`dynamic_values`** — parámetros heredables por categoría (retail, tallas/colores)

Funciona técnicamente; confunde al comercio y al desarrollador.

**Decisión requerida (T7.4.1):**

| Vertical | Recomendación |
|----------|---------------|
| FOOD | Variantes porción + ingredientes |
| RETAIL | Solo parámetros categoría |
| SERVICES | Sin variantes; duración + campos servicio |

**Prioridad:** 🟡 Media — `/bloque-7-4`.

---

## 4. Admin plataforma (más allá del CRUD)

| Gap | Tarea |
|-----|-------|
| Sin auditoría (quién suspendió tienda, editó cupón) | T7.5.1–T7.5.3 |
| Sin alertas (comercio vacío, pedido sin atender) | T7.5.4–T7.5.5 |
| Sin reportes exportables merchant (Excel) | T7.5.6–T7.5.7 |
| Admin merchants: solo tabla, sin detalle | T7.5.8 |

**Prioridad:** 🟡 Media — `/bloque-7-5`.

---

## 5. Multi-usuario y escala

| Gap | Tarea |
|-----|-------|
| Un owner por tienda; sin roles cajero/manager | T7.6.1–T7.6.3 |
| Multi-tienda: selector existe, flujos no pulidos | T7.6.4 |
| Sin notificación web pedido nuevo (sonido/badge) | T7.6.5 |

**Prioridad:** 🟢 Baja-media — `/bloque-7-6`.

---

## 6. Apps móviles (Fase 4) — el elefante

El panel admin **sin Flutter** sirve para:

- ✅ Preparar catálogo, promos, configuración
- ✅ Gestionar pedidos si el cliente ordena por otro canal
- ❌ Negocio real de delivery (cliente final + conductor)

**Siguiente fase natural:** `/fase-4` en paralelo con Fase 7.1–7.2.

---

## Orden recomendado

```
7.1 (E2E + CI)  →  7.2 (horarios/zonas)  →  7.3 (promos Celery)
       ↓
7.4 (modelo producto)     7.5 (admin plataforma)     7.6 (multi-usuario)
       ↓
Fase 4 Flutter  +  Fase 5 WS  →  7.7 (pedidos WS en web)
```

---

## Entregado recientemente (Bloque 6.12)

Documentado en [PROGRESS.md](PROGRESS.md):

- Import plantillas categorías DTS
- Promos por parámetro producto + badges
- Vigencia promos + activar/desactivar
- Iconos SVG categorías
- Borradores localStorage
- Layout merchant sidebar fijo

---

## Criterio de salida Fase 7

Considerar el portal administrativo **"bien"** cuando:

1. ✅ Bloque 7.1 verde (E2E + CI)
2. ✅ Bloque 7.2 (horarios + zonas mínimo viable)
3. ✅ Bloque 7.3 (promos lifecycle)
4. ⬜ Al menos uno de 7.5 o 7.6 según prioridad negocio
5. ⬜ Fase 4 iniciada (catálogo + checkout cliente)
