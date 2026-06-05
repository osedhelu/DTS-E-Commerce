---
description: Ejecutar Fase 5 — Tracking en tiempo real con WebSockets
---

# Fase 5 — Tracking Tiempo Real

## Prerequisito

Fases 1 y 4 completas (API + apps con tracking básico).

## Alcance

- `backend/` — Django Channels + TrackingConsumer
- `flutter-customer/` — WebSocket en tracking
- `flutter-driver/` — emitir ubicación por WS
- `docs/FIREBASE_TRACKING.md` — alternativa documentada (T5.5.1)

## Tareas

T5.1.1 Channels setup → T5.1.2 Consumer → T5.2.1 Broadcast → T5.3.1 Customer WS → T5.4.1 Driver WS → T5.5.1 Firebase doc

## Tests

- Backend: channels testing con `pytest-asyncio` o `ChannelsLiveServerTestCase`
- Flutter: mock WebSocket channel en datasource tests

Latencia objetivo: < 2 segundos cliente ↔ conductor.
