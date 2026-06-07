.PHONY: help setup up down logs ps doctor restart-api install-server backend-migrate-all backend-check-db \
	docker-up docker-down docker-logs docker-up-full docker-down-full docker-logs-full docker-ps \
	backend-shell backend-createsuperuser backend-migrate-docker \
	backend-sync backend-test backend-migrate backend-run \
	web-admin-sync web-admin-dev web-admin-build web-admin-lint \
	flutter-sync flutter-test test lint \
	fase6-test fase6-test-task fase6-test-all

export COMPOSE_PROJECT_NAME := dts

DOCKER_ENV_FILE = docker-infrastructure/.env
DOCKER_COMPOSE = docker compose -p dts --env-file $(DOCKER_ENV_FILE)
DOCKER_COMPOSE_INFRA = $(DOCKER_COMPOSE) -f docker-compose.yml
DOCKER_COMPOSE_FULL = $(DOCKER_COMPOSE) -f docker-infrastructure/docker-compose.yml

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
	@echo "  make doctor             Diagnóstico ALLOWED_HOSTS / API"
	@echo "  make restart-api        Recrear API tras cambiar .env"
	@echo "  make backend-migrate-all   Migraciones en contenedor API"
	@echo "  make backend-check-db      Verificar tablas en PostGIS"
	@echo "  make install-server        Alias: up + mensaje post-instalación"
	@echo ""
	@echo "── Desarrollo local (requiere uv, GDAL, Node, Flutter) ──"
	@echo "  make setup              Deps locales + solo infra Docker"
	@echo "  make docker-up          Solo PostGIS + Redis + Mailpit"
	@echo "  make backend-run        Django en host :8000"
	@echo "  make web-admin-dev      Next.js :3000"
	@echo "  make backend-test       pytest en host"
	@echo "  make test               Todos los tests locales"
	@echo ""
	@echo "── Fase 6 — Portal comercio (por bloques) ──"
	@echo "  make fase6-test BLOCK=6.1   Tests unificados bloque 6.1"
	@echo "  make fase6-test BLOCK=all   Todos los bloques 6.1–6.10"
	@echo "  make fase6-test-task TASK=T6.1.4   Test de una tarea"
	@echo "  Ver docs/FASE6_BLOCKS.md · Cursor: /bloque-6-1"

# ── Flujo Docker (recomendado en servidor) ────────────────────────────────────

$(DOCKER_ENV_FILE):
	cp docker-infrastructure/.env.example $(DOCKER_ENV_FILE)

up: $(DOCKER_ENV_FILE)
	@echo "==> Deteniendo stacks anteriores (evita conflicto de nombres)..."
	-$(DOCKER_COMPOSE_INFRA) down
	-$(DOCKER_COMPOSE_FULL) down
	@for c in dts-postgis dts-redis dts-mailpit dts-api dts-celery-worker dts-celery-beat; do \
		docker rm -f $$c 2>/dev/null || true; \
	done
	$(DOCKER_COMPOSE_FULL) up -d --build --force-recreate
	@echo ""
	@echo "✅ Stack levantado"
	@echo "   API:     http://localhost:8000"
	@echo "   Docs:    http://localhost:8000/api/v1/docs/"
	@echo "   Red:     http://extreme.local:8000/api/v1/docs/"
	@echo "   Mailpit: http://localhost:8025"
	@echo ""
	@echo "   Crear admin: make backend-createsuperuser"
	@echo "   Guía: docs/DEPLOY_DOCKER.md"

install-server: up
	@echo ""
	@echo "📖 Documentación: docs/DEPLOY_DOCKER.md"
	@echo "   Siguiente paso obligatorio (solo 1ª vez): make backend-createsuperuser"

down: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_FULL) down
	-$(DOCKER_COMPOSE_INFRA) down

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

backend-migrate-all: $(DOCKER_ENV_FILE)
	docker exec dts-api uv run --no-dev python manage.py migrate --noinput

backend-check-db: $(DOCKER_ENV_FILE)
	@echo "── Tablas analytics ──"
	@docker exec dts-postgis psql -U postgres -d dts_delivery -c "\dt analytics*"
	@echo "── Tablas delivery ──"
	@docker exec dts-postgis psql -U postgres -d dts_delivery -c "\dt delivery*"
	@echo "── Migraciones analytics / delivery ──"
	@docker exec dts-api uv run --no-dev python manage.py showmigrations analytics delivery

restart-api: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_FULL) up -d --build --force-recreate api celery-worker celery-beat

backend-admin-check: $(DOCKER_ENV_FILE)
	@docker exec dts-api uv run --no-dev python -c "\
from django.contrib import admin; \
import django; django.setup(); \
from features.accounts.infrastructure.models import CustomUser; \
from features.stores.infrastructure.models import Store; \
from features.orders.infrastructure.models import Order; \
regs = admin.site._registry; \
print('CustomUser:', CustomUser in regs); \
print('Store:', Store in regs); \
print('Order:', Order in regs); \
print('Total modelos admin:', len(regs))"

doctor: $(DOCKER_ENV_FILE)
	@echo "── docker-infrastructure/.env ──"
	@grep -E '^(ALLOWED_HOSTS|CSRF_TRUSTED_ORIGINS|API_PORT)=' $(DOCKER_ENV_FILE) 2>/dev/null || echo "(sin .env)"
	@echo ""
	@echo "── Contenedor dts-api ──"
	@docker exec dts-api printenv ALLOWED_HOSTS 2>/dev/null || echo "dts-api no está corriendo"
	@echo ""
	@echo "── Prueba localhost ──"
	@curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8000/api/v1/docs/ || true
	@echo "── Prueba extreme.local (header Host) ──"
	@curl -s -o /dev/null -w "HTTP %{http_code}\n" -H "Host: extreme.local" http://localhost:8000/api/v1/docs/ || true
	@echo ""
	@echo "Si extreme.local da 400 → edita ALLOWED_HOSTS en docker-infrastructure/.env"
	@echo "Luego: make restart-api"

# Alias legacy
docker-up-full: up
docker-down-full: down
docker-logs-full: logs
docker-ps: ps

# ── Solo infraestructura (dev con uv en host) ────────────────────────────────

setup: docker-up backend-sync web-admin-sync flutter-sync
	@echo "✅ Monorepo listo (modo desarrollo local)."
	@echo "   Para solo Docker: make up"

docker-up: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_INFRA) up -d

docker-down: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_INFRA) down

docker-logs: $(DOCKER_ENV_FILE)
	$(DOCKER_COMPOSE_INFRA) logs -f

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

# ── Fase 6 — tests por bloque ────────────────────────────────────────────────

fase6-test:
	@chmod +x scripts/fase6-block-test.sh
	@./scripts/fase6-block-test.sh $(or $(BLOCK),6.1)

fase6-test-all:
	@chmod +x scripts/fase6-block-test.sh
	@./scripts/fase6-block-test.sh all

fase6-test-task:
	@chmod +x scripts/fase6-task-test.sh
	@./scripts/fase6-task-test.sh $(TASK)

lint: web-admin-lint
	cd backend && uv run ruff check .
