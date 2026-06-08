#!/usr/bin/env bash
# Tests unificados por bloque Fase 6.
# Uso: ./scripts/fase6-block-test.sh 6.1
#      make fase6-test BLOCK=6.1

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BLOCK="${1:-}"

if [[ -z "$BLOCK" ]]; then
  echo "Uso: $0 <bloque>   ej: 6.1, 6.2, … 6.11, all"
  exit 1
fi

backend_pytest() {
  echo "── Backend pytest ──"
  cd "$ROOT/backend"
  uv run pytest "$@" -v --tb=short
}

backend_pytest_kw() {
  echo "── Backend pytest (-k \"$1\") ──"
  cd "$ROOT/backend"
  uv run pytest -k "$1" -v --tb=short
}

web_check() {
  echo "── web-admin lint + build ──"
  cd "$ROOT/web-admin"
  npm run lint
  npm run build
}

web_e2e() {
  echo "── Playwright E2E ──"
  cd "$ROOT/web-admin"
  # shellcheck disable=SC2068
  npx playwright test $@
}

run_block() {
  case "$1" in
    6.1)
      backend_pytest_kw "verification_token or verify_email or merchant_register or merchant_public_register or store_vertical or send_verification or resend_verification"
      ;;
    6.2)
      web_check
      web_e2e e2e/merchant_landing_renders_test.spec.ts \
        e2e/merchant_public_registration_flow_test.spec.ts \
        e2e/merchant_email_confirmation_flow_test.spec.ts
      ;;
    6.3)
      backend_pytest_kw "product_variant or product_ingredient or product_image or category_templates or update_product_with_variants or service_product_rejects_variants"
      ;;
    6.4)
      web_check
      web_e2e e2e/food_product_with_variants_test.spec.ts \
        e2e/product_photo_upload_test.spec.ts
      ;;
    6.5)
      backend_pytest_kw "merchant_dashboard"
      web_e2e e2e/merchant_dashboard_metrics_test.spec.ts
      ;;
    6.6)
      backend_pytest_kw "store_promotion or merchant_promotions"
      web_e2e e2e/merchant_create_promotion_test.spec.ts
      ;;
    6.7)
      backend_pytest_kw "store_profile or update_store_profile"
      web_e2e e2e/merchant_update_store_profile_test.spec.ts
      ;;
    6.8)
      backend_pytest_kw "local_storage or s3_storage"
      ;;
    6.9)
      web_check
      web_e2e e2e/merchant_edit_category_test.spec.ts \
        e2e/merchant_products_search_test.spec.ts \
        e2e/admin_banners_crud_test.spec.ts \
        e2e/admin_edit_coupon_test.spec.ts
      ;;
    6.10)
      backend_pytest_kw "admin_list_merchants or admin_suspend_store"
      web_e2e e2e/admin_merchant_moderation_test.spec.ts
      ;;
    6.11)
      backend_pytest_kw "media_serving or media_urls or test_media"
      web_e2e e2e/product_photo_upload_test.spec.ts \
        e2e/product_photo_visible_test.spec.ts
      ;;
    *)
      echo "Bloque desconocido: $1 (use 6.1–6.11)"
      exit 1
      ;;
  esac
}

if [[ "$BLOCK" == "all" ]]; then
  for b in 6.1 6.2 6.3 6.4 6.5 6.6 6.7 6.8 6.9 6.10 6.11; do
    echo ""
    echo "══════════════════════════════════════"
    echo " Bloque $b"
    echo "══════════════════════════════════════"
    run_block "$b"
  done
else
  run_block "$BLOCK"
fi

echo ""
echo "✅ Tests bloque $BLOCK completados"
