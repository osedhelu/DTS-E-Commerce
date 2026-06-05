.PHONY: help setup docker-up docker-down docker-logs backend-sync backend-test backend-migrate backend-run web-admin-sync web-admin-dev web-admin-build web-admin-lint flutter-sync flutter-test test lint

help:
	@echo "DTS E-Commerce Monorepo"
	@echo ""
	@echo "  make setup            Instalar dependencias de todos los proyectos"
	@echo "  make docker-up        Levantar PostGIS + Redis + Mailpit"
	@echo "  make docker-down      Detener servicios Docker"
	@echo "  make backend-test     Tests del backend"
	@echo "  make backend-run      Servidor Django en :8000"
	@echo "  make web-admin-dev    Next.js en :3000"
	@echo "  make web-admin-build  Build producción web-admin"
	@echo "  make flutter-test     Tests de ambas apps Flutter"
	@echo "  make test             Todos los tests"

setup: docker-up backend-sync web-admin-sync flutter-sync
	@echo "✅ Monorepo listo."
	@echo "   backend: cp backend/.env.example → backend/.env si no existe"
	@echo "   web-admin: cp web-admin/.env.example → web-admin/.env.local si no existe"

docker-up:
	docker compose up -d

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f

backend-sync:
	cd backend && test -f .env || cp .env.example .env
	cd backend && uv sync

backend-test:
	cd backend && uv run pytest -v

backend-migrate:
	cd backend && uv run python manage.py migrate

backend-run:
	cd backend && uv run python manage.py runserver 0.0.0.0:8000

web-admin-sync:
	cd web-admin && test -f .env.local || cp .env.example .env.local
	cd web-admin && npm ci

web-admin-dev:
	cd web-admin && npm run dev

web-admin-build:
	cd web-admin && npm run build

web-admin-lint:
	cd web-admin && npm run lint

flutter-sync:
	cd flutter-customer && flutter pub get
	cd flutter-driver && flutter pub get

flutter-test:
	cd flutter-customer && flutter test
	cd flutter-driver && flutter test

test: backend-test flutter-test

lint: web-admin-lint
	cd backend && uv run ruff check .
