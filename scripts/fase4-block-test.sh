#!/usr/bin/env bash
# Tests unificados por bloque Fase 4 (Flutter + backend gap).
# Uso: ./scripts/fase4-block-test.sh 4.1
#      make fase4-test BLOCK=4.1

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BLOCK="${1:-}"

if [[ -z "$BLOCK" ]]; then
  echo "Uso: $0 <bloque>   ej: 4.0, 4.1, … 4.9, all"
  exit 1
fi

flutter_customer_test() {
  echo "── flutter-customer ──"
  cd "$ROOT/flutter-customer"
  flutter test "$@"
}

flutter_driver_test() {
  echo "── flutter-driver ──"
  cd "$ROOT/flutter-driver"
  flutter test "$@"
}

backend_pytest_kw() {
  echo "── Backend pytest (-k \"$1\") ──"
  cd "$ROOT/backend"
  uv run pytest -k "$1" -v --tb=short
}

run_block() {
  case "$1" in
    4.0)
      backend_pytest_kw "driver_toggle_online or driver_updates_location or driver_availability"
      ;;
    4.1)
      flutter_customer_test test/features/auth test/core/network
      ;;
    4.2)
      flutter_customer_test test/features/stores
      ;;
    4.3)
      flutter_customer_test test/features/catalog
      ;;
    4.4)
      flutter_customer_test test/features/cart test/features/checkout
      ;;
    4.5)
      flutter_customer_test test/features/tracking test/features/notifications test/core/firebase
      ;;
    4.6)
      flutter_driver_test test/features/auth test/core/network
      ;;
    4.7)
      flutter_driver_test test/features/availability
      ;;
    4.8)
      flutter_driver_test test/features/orders
      ;;
    4.9)
      flutter_driver_test test/features/location
      ;;
    *)
      echo "Bloque desconocido: $1 (use 4.0–4.9)"
      exit 1
      ;;
  esac
}

if [[ "$BLOCK" == "all" ]]; then
  for b in 4.0 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9; do
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
