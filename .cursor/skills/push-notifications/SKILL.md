---
name: push-notifications
description: Implementa notificaciones push FCM en DTS Delivery Platform. Usar en tareas T1.2.8, T2.2.4, T2.2.5, T2.4.x, T4.1.5, T4.5.3–4.5.5, T4.8.2, o cuando el usuario pida push, FCM, firebase messaging, o avisar al cliente que el pedido salió.
disable-model-invocation: true
---

# Push Notifications FCM

Lee primero [docs/PUSH_NOTIFICATIONS.md](../../docs/PUSH_NOTIFICATIONS.md).

## Prerequisitos por tarea

| Tarea | Requiere |
|-------|----------|
| T1.2.8 | T1.2.3 CustomUser |
| T2.4.x | T1.2.8, T1.5.4 Order model, T2.1.1 Celery |
| T4.5.3+ | T4.1.3 Login, T1.2.8 API token |
| T4.8.2 | T4.6.2 Driver login, T2.4.3 send push |

## Backend (Fase 2)

```
features/notifications/
├── domain/entities.py      # NotificationType, PushTemplate
├── domain/services.py      # OrderStatusNotificationMapper
├── application/use_cases/send_push.py
└── infrastructure/
    ├── fcm_client.py       # firebase-admin (mock en tests)
    ├── tasks.py            # send_push_task
    └── models.py           # NotificationLog (opcional)
```

## Signal pattern

```python
@receiver(post_save, sender=OrderModel)
def on_order_status_change(sender, instance, **kwargs):
    if status_changed:
        dispatch_order_push_task.delay(instance.id, instance.status)
```

## Flutter cliente (Fase 4)

1. `firebase_core` + `firebase_messaging` en pubspec
2. Tras login exitoso → `POST /api/v1/accounts/device-token/`
3. Handler: tap en push `ON_THE_WAY` → navegar a tracking

## Tests

- Mock `firebase_admin.messaging.send` en backend
- Mock `FirebaseMessaging` en Flutter con `mocktail`

## Variables

```env
FCM_CREDENTIALS_PATH=path/to/service-account.json
```
