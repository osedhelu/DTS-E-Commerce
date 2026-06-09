#!/usr/bin/env bash
set -euo pipefail

wait_for_db() {
  echo "==> Esperando PostgreSQL (${DB_HOST:-db}:${DB_PORT:-5432})..."
  until uv run --no-dev python - <<'PY'
import os
import sys

import psycopg

try:
    conn = psycopg.connect(
        dbname=os.environ.get("DB_NAME", "dts_delivery"),
        user=os.environ.get("DB_USER", "postgres"),
        password=os.environ.get("DB_PASSWORD", "postgres"),
        host=os.environ.get("DB_HOST", "db"),
        port=os.environ.get("DB_PORT", "5432"),
        connect_timeout=3,
    )
    conn.close()
except Exception:
    sys.exit(1)
PY
  do
    sleep 2
  done
  echo "==> PostgreSQL listo."
}

wait_for_db

MEDIA_DIR="${MEDIA_ROOT:-/app/backend/media}"
export MEDIA_ROOT="$MEDIA_DIR"
mkdir -p "$MEDIA_DIR"
echo "==> MEDIA_ROOT=${MEDIA_DIR}"

if [[ "${RUN_MIGRATIONS:-true}" == "true" ]]; then
  echo "==> Aplicando migraciones..."
  uv run --no-dev python manage.py migrate --noinput
  echo "==> Verificando tablas críticas (analytics, delivery)..."
  uv run --no-dev python scripts/repair_migration_tables.py
  echo "==> Recolectando archivos estáticos (admin, Swagger)..."
  uv run --no-dev python manage.py collectstatic --noinput --clear
fi

exec "$@"
