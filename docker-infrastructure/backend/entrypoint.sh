#!/usr/bin/env bash
set -euo pipefail

wait_for_db() {
  echo "==> Esperando PostgreSQL (${DB_HOST:-db}:${DB_PORT:-5432})..."
  until uv run python - <<'PY'
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

if [[ "${RUN_MIGRATIONS:-true}" == "true" ]]; then
  echo "==> Aplicando migraciones..."
  uv run python manage.py migrate --noinput
fi

exec "$@"
