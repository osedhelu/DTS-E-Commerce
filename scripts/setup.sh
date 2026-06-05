#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> DTS E-Commerce — Setup Monorepo"

command -v docker >/dev/null || { echo "❌ Docker no encontrado"; exit 1; }
command -v uv >/dev/null || { echo "❌ uv no encontrado. Instala: curl -LsSf https://astral.sh/uv/install.sh | sh"; exit 1; }
command -v flutter >/dev/null || { echo "❌ Flutter no encontrado"; exit 1; }

echo "==> Levantando PostGIS + Redis..."
docker compose up -d

echo "==> Backend..."
cd backend
if [ ! -f .env ]; then
  cp .env.example .env
  echo "   Creado backend/.env desde .env.example"
fi
uv sync
cd "$ROOT"

echo "==> Flutter Customer..."
cd flutter-customer
flutter pub get
cd "$ROOT"

echo "==> Flutter Driver..."
cd flutter-driver
flutter pub get
cd "$ROOT"

echo ""
echo "✅ Setup completo"
echo ""
echo "Próximos pasos:"
echo "  make backend-migrate   # migraciones (cuando existan modelos)"
echo "  make backend-run       # API en http://localhost:8000"
echo "  make backend-test      # tests backend"
