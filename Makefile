.PHONY: help setup up down logs ps \
	docker-up docker-down docker-logs docker-up-full docker-down-full docker-logs-full docker-ps \
	backend-shell backend-createsuperuser backend-migrate-docker \
	backend-sync backend-test backend-migrate backend-run \
	web-admin-sync web-admin-dev web-admin-build web-admin-lint \
	flutter-sync flutter-test test lint

DOCKER_ENV_FILE = docker-infrastructure/.env
DOCKER_COMPOSE_FULL = docker compose --env-file $(DOCKER_ENV_FILE) -f docker-infrastructure/docker-compose.yml

help:
	@echo "DTS E-Commerce Monorepo"
	@echo ""
	@echo "── 100% Docker (solo necesitas Docker instalado) ──"
	@echo "  make up                 Levantar TODO: DB + Redis + API + workers"
	@echo "  make down               Detener stack completo"
	@echo "  make logs               Ver logs"
	@echo "  make ps                 Estado de contenedores"
	@echo "  make backend-createsuperuser   Crear admin Django"
	@echo "  make backend-shell      Shell Django en contenedor"
	@echo ""
	@echo "── Desarrollo local (requiere uv, GDAL, Node, Flutter) ──"
	@echo "  make setup              Deps locales + solo infra Docker"
	@echo "  make docker-up          Solo PostGIS + Redis + Mailpit"
	@echo "  make backend-run        Django en host :8000"
	@echo "  make web-admin-dev      Next.js :3000"
	@echo "  make backend-test       pytest en host"
	@echo "  make test               Todos los tests locales"

# ── Flujo Docker (recomendado en servidor) ────────────────────────────────────

$(DOCKER_ENV_FILE):
	cp docker-infrastructure/.env.example $(DOCKER_ENV_FILE)

up: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_FULL) up -d --build
	@echo ""
	@echo "✅ Stack levantado"
	@echo "   API:     http://localhost:8000"
	@echo "   Docs:    http://localhost:8000/api/v1/docs/"
	@echo "   Mailpit: http://localhost:8025"
	@echo ""
	@echo "   Crear admin: make backend-createsuperuser"

down: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_FULL) down

logs: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_FULL) logs -f

ps: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_FULL) ps

backend-createsuperuser: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_FULL) exec api uv run python manage.py createsuperuser

backend-shell: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_FULL) exec api uv run python manage.py shell

backend-migrate-docker: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_FULL) --profile tools run --rm backend-migrate

# Alias legacy
docker-up-full: up
docker-down-full: down
docker-logs-full: logs
docker-ps: ps

# ── Solo infraestructura (dev con uv en host) ────────────────────────────────

setup: docker-up backend-sync web-admin-sync flutter-sync
	@echo "✅ Monorepo listo (modo desarrollo local)."
	@echo "   Para solo Docker: make up"

docker-up:
	docker compose up -d

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f

# ── Backend en host (requiere GDAL + uv) ─────────────────────────────────────

backend-sync:
	cd backend && test -f .env || cp .env.example .env
	cd backend && uv sync

backend-test:
	cd backend && uv run pytest -v

backend-migrate:
	cd backend && uv run python manage.py migrate

backend-run:
	cd backend && uv run python manage.py runserver 0.0.0.0:8000

# ── Web admin ────────────────────────────────────────────────────────────────

web-admin-sync:
	cd web-admin && test -f .env.local || cp .env.example .env.local
	cd web-admin && npm ci

web-admin-dev:
	cd web-admin && npm run dev

web-admin-build:
	cd web-admin && npm run build

web-admin-lint:
	cd web-admin && npm run lint

# ── Flutter ──────────────────────────────────────────────────────────────────

flutter-sync:
	cd flutter-customer && flutter pub get
	cd flutter-driver && flutter pub get

flutter-test:
	cd flutter-customer && flutter test
	cd flutter-driver && flutter test

test: backend-test flutter-test

lint: web-admin-lint
	cd backend && uv run ruff check .
