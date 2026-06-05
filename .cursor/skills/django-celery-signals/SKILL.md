---
name: django-celery-signals
description: Implementa Signals y tareas Celery en el backend DTS para flujos asíncronos de pedidos, notificaciones y analytics. Usar en Fase 2 (T2.x) o al automatizar cambios de estado de Order.
disable-model-invocation: true
---

# Celery + Signals (Fase 2)

## Principio

- **Signals**: detectar cambios DB → encolar tarea (rápido, no bloquear)
- **Celery tasks**: trabajo pesado (geo, push, email, reportes)

## Patrón Signal

```python
# features/orders/infrastructure/signals.py
@receiver(post_save, sender=OrderModel)
def on_order_status_change(sender, instance, **kwargs):
    if instance.tracker.has_changed("status"):
        if instance.status == OrderStatus.READY_FOR_PICKUP:
            assign_driver_task.delay(instance.id)
```

Registrar en `features/orders/apps.py`:
```python
def ready(self):
    import features.orders.infrastructure.signals  # noqa
```

## Patrón Task

```python
# features/delivery/infrastructure/tasks.py
@shared_task(bind=True, max_retries=3)
def assign_driver_task(self, order_id: int):
    use_case = AssignDriverUseCase(...)
    use_case.execute(order_id)
```

## Tests

- `CELERY_TASK_ALWAYS_EAGER=True` en `core/settings/test.py`
- Mock servicios externos (FCM, email)
- `test_signal_enqueues_assign_driver`: verificar `.delay` llamado

## Celery Beat (analytics)

```python
# core/celery.py
app.conf.beat_schedule = {
    "nightly-stats": {
        "task": "features.analytics.infrastructure.tasks.calculate_daily_stats",
        "schedule": crontab(hour=2, minute=0),
    },
}
```
