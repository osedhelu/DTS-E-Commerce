#!/usr/bin/env bash
# Test de una tarea individual Fase 4 por ID.
# Uso: ./scripts/fase4-task-test.sh T4.2.1

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TASK="${1:-}"

if [[ -z "$TASK" ]]; then
  echo "Uso: $0 T4.X.Y"
  exit 1
fi

cd "$ROOT"

case "$TASK" in
  T4.0.1)
    cd backend && uv run pytest -k "driver_toggle_online or driver_updates_location" -v
    ;;
  T4.1.1)
    cd flutter-customer && flutter test
    ;;
  T4.1.2)
    cd flutter-customer && flutter test test/core/network/api_client_adds_auth_header_test.dart
    ;;
  T4.1.3)
    cd flutter-customer && flutter test test/features/auth/domain/login_usecase_test.dart
    ;;
  T4.1.4)
    cd flutter-customer && flutter test test/features/auth/presentation/login_screen_widget_test.dart
    ;;
  T4.1.5)
    cd flutter-customer && flutter test test/core/firebase/firebase_init_test.dart
    ;;
  T4.2.1)
    cd flutter-customer && flutter test test/features/stores/domain/get_stores_usecase_test.dart
    ;;
  T4.2.2)
    cd flutter-customer && flutter test test/features/stores/infrastructure/stores_repository_maps_dto_test.dart
    ;;
  T4.2.3)
    cd flutter-customer && flutter test test/features/stores/presentation/store_list_shows_stores_test.dart
    ;;
  T4.3.1)
    cd flutter-customer && flutter test test/features/catalog/domain/get_products_usecase_test.dart
    ;;
  T4.3.2)
    cd flutter-customer && flutter test test/features/catalog/presentation/add_to_cart_from_catalog_test.dart
    ;;
  T4.3.3)
    cd flutter-customer && flutter test test/features/catalog/presentation/catalog_filter_by_category_test.dart
    ;;
  T4.3.4)
    cd flutter-customer && flutter test test/features/catalog/presentation/service_detail_screen_test.dart
    ;;
  T4.4.1)
    cd flutter-customer && flutter test test/features/cart/domain/
    ;;
  T4.4.2)
    cd flutter-customer && flutter test test/features/checkout/domain/create_order_usecase_test.dart
    ;;
  T4.4.3)
    cd flutter-customer && flutter test test/features/checkout/presentation/checkout_flow_widget_test.dart
    ;;
  T4.4.4)
    cd flutter-customer && flutter test test/features/checkout/presentation/service_checkout_flow_test.dart
    ;;
  T4.4.5)
    cd flutter-customer && flutter test test/features/checkout/presentation/service_order_tracking_test.dart
    ;;
  T4.5.1)
    cd flutter-customer && flutter test test/features/tracking/domain/get_tracking_usecase_test.dart
    ;;
  T4.5.2)
    cd flutter-customer && flutter test test/features/tracking/presentation/tracking_map_widget_test.dart
    ;;
  T4.5.3)
    cd flutter-customer && flutter test test/features/notifications/register_fcm_token_usecase_test.dart
    ;;
  T4.5.4)
    cd flutter-customer && flutter test test/features/notifications/push_notification_handler_test.dart
    ;;
  T4.5.5)
    cd flutter-customer && flutter test test/features/notifications/push_opens_tracking_screen_test.dart
    ;;
  T4.6.1)
    cd flutter-driver && flutter test
    ;;
  T4.6.2)
    cd flutter-driver && flutter test test/features/auth/domain/driver_login_usecase_test.dart
    ;;
  T4.7.1)
    cd flutter-driver && flutter test test/features/availability/domain/toggle_online_usecase_test.dart
    ;;
  T4.7.2)
    cd flutter-driver && flutter test test/features/availability/presentation/availability_switch_widget_test.dart
    ;;
  T4.8.1)
    cd flutter-driver && flutter test test/features/orders/domain/accept_order_usecase_test.dart
    ;;
  T4.8.2)
    cd flutter-driver && flutter test test/features/orders/notifications/new_order_notification_handler_test.dart
    ;;
  T4.8.3)
    cd flutter-driver && flutter test test/features/orders/presentation/driver_order_flow_widget_test.dart
    ;;
  T4.9.1)
    cd flutter-driver && flutter test test/features/location/domain/send_location_usecase_test.dart
    ;;
  T4.9.2)
    cd flutter-driver && flutter test test/features/location/infrastructure/location_service_interval_test.dart
    ;;
  T4.9.3)
    cd flutter-driver && flutter test test/features/location/infrastructure/location_permission_test.dart
    ;;
  *)
    echo "Tarea $TASK: ver docs/FASE4_BLOCKS.md o docs/TASKS.md"
    exit 1
    ;;
esac

echo "✅ Test tarea $TASK"
