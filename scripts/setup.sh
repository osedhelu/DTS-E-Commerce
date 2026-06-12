#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> DTS E-Commerce — Setup Monorepo"

if [ -f .gitmodules ]; then
  echo "==> Inicializando submodules..."
  git submodule update --init --recursive
fi

command -v docker >/dev/null || { echo "❌ Docker no encontrado"; exit 1; }
command -v uv >/dev/null || { echo "❌ uv no encontrado. Instala: curl -LsSf https://astral.sh/uv/install.sh | sh"; exit 1; }
command -v flutter >/dev/null || { echo "❌ Flutter no encontrado"; exit 1; }
command -v node >/dev/null || { echo "❌ Node.js no encontrado (requerido para web-admin)"; exit 1; }
command -v npm >/dev/null || { echo "❌ npm no encontrado"; exit 1; }

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

echo "==> Web Admin (Next.js)..."
cd web-admin
if [ ! -f .env.local ]; then
  cp .env.example .env.local
  echo "   Creado web-admin/.env.local desde .env.example"
fi
npm ci
cd "$ROOT"

echo ""
echo "✅ Setup completo"
echo ""
echo "Próximos pasos:"
echo "  make backend-migrate   # migraciones"
echo "  make backend-run       # API en http://localhost:8000"
echo "  make web-admin-dev     # Frontend en http://localhost:3000"
echo "  make backend-test      # tests backend"
