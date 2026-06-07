#!/usr/bin/env bash
# Test de una tarea individual Fase 6 por ID.
# Uso: ./scripts/fase6-task-test.sh T6.1.4
#      make fase6-test-task TASK=T6.1.4

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TASK="${1:-}"

if [[ -z "$TASK" ]]; then
  echo "Uso: $0 T6.X.Y"
  exit 1
fi

cd "$ROOT/backend"

case "$TASK" in
  T6.1.1) uv run pytest -k test_verification_token_expired_raises -v ;;
  T6.1.2) uv run pytest -k test_verification_token_persistence -v ;;
  T6.1.3) uv run pytest -k test_store_vertical_values -v ;;
  T6.1.4) uv run pytest -k test_merchant_register_creates_store_and_categories -v ;;
  T6.1.5) uv run pytest -k test_verify_email_activates_merchant -v ;;
  T6.1.6) uv run pytest -k "test_merchant_public_register_201 or test_merchant_register_duplicate_email_400" -v ;;
  T6.1.7) uv run pytest -k "test_verify_email_api_200 or test_verify_email_invalid_token_400" -v ;;
  T6.1.8) uv run pytest -k test_send_verification_email_task -v ;;
  T6.1.9) uv run pytest -k test_resend_verification_email -v ;;
  T6.2.1|T6.2.10|T6.2.11)
    cd "$ROOT/web-admin"
    case "$TASK" in
      T6.2.1) npx playwright test e2e/merchant_landing_renders_test.spec.ts ;;
      T6.2.10) npx playwright test e2e/merchant_public_registration_flow_test.spec.ts ;;
      T6.2.11) npx playwright test e2e/merchant_email_confirmation_flow_test.spec.ts ;;
    esac
    ;;
  T6.2.2) cd "$ROOT/web-admin" && npm run lint && npm run build ;;
  T6.3.*)
    uv run pytest -k "$(echo "$TASK" | sed 's/T6.3.[0-9]* //')" -v 2>/dev/null || uv run pytest -k "product_variant or product_ingredient or product_image" -v
    ;;
  *)
    echo "Tarea $TASK: busca el test en docs/TASKS.md y ejecuta:"
    echo "  cd backend && uv run pytest -k <nombre_test> -v"
    echo "  cd web-admin && npx playwright test e2e/<test>.spec.ts"
    exit 1
    ;;
esac

echo "✅ Test tarea $TASK"
