# Guía para Agentes — DTS Delivery Platform

Monorepo con 4 proyectos en **submodules Git** independientes (raíz = orchestration).

## Estructura

| Carpeta | Stack | Nota |
|---------|-------|------|
| `backend/` (submodule) | Django + DRF + Celery + Channels + PostGIS | API solo; sin templates |
| `web-admin/` (submodule) | Next.js 16 + React 19 + Zustand + Tailwind v4 | Merchant + super admin |
| `flutter-customer/` (submodule) | Flutter + Riverpod | App cliente |
| `flutter-driver/` (submodule) | Flutter + Riverpod | App conductor |

## Critical Setup Gotchas

**Submodules required:** `git clone --recurse-submodules …` or `git submodule update --init --recursive` after clone. Agents often miss this.

**Backend Python:** Uses **uv**, not pip. `uv add`, `uv sync`, `uv run python …`. Requires Python ≥ 3.12. Backend lint: `uv run ruff check .` (config in `backend/pyproject.toml`).

**Docker always needed for backend dev:** PostGIS (5432) + Redis (6379) + Mailpit (8025). Run `make docker-up` first. Backend cannot run on host without GDAL (in Docker: `make up`). Local DB: container `dts-postgis`, DB `dts_delivery`, user `postgres`.

**web-admin package manager:** Makefile + root CI use **npm** (`npm ci`), but a `pnpm-lock.yaml` + `pnpm-workspace.yaml` coexist and Fase 7 docs (`docs/FASE7_BLOCKS.md`) use `pnpm` commands. Prefer `npm` for anything wired via `make`; `pnpm` only for Fase 7 manual steps.

**Media files in Docker:** Set `SERVE_MEDIA=true` in `docker-infrastructure/.env` to serve product photos (`docker-infrastructure/.env.example` already ships it). Run `make media-check` to verify. Images stored at `/app/backend/media/products/`.

**Database:** Schema by `docs/TASKS.md` task IDs. Tests use pytest markers `@pytest.mark.django_db`. Always run `make backend-test` locally before pushing. Backend tests need PostGIS+Redis up (CI spins both as services).

## Developer Commands

| Task | Command |
|------|---------|
| **Setup** (all infra + deps) | `make setup` |
| **Just Docker** (PostGIS + Redis) | `make docker-up` / `make docker-down` |
| **All Docker** (API included) | `make up` (resets containers) / `make down` |
| **Backend tests** | `cd backend && uv run pytest -v` or `make backend-test` |
| **Backend local** (requires GDAL) | `make backend-run` → http://localhost:8000 |
| **Web-admin dev** | `make web-admin-dev` → http://localhost:3000 |
| **Web-admin lint** | `make web-admin-lint` (`npm run lint` = ESLint flat config) |
| **Web-admin unit tests** | `cd web-admin && npm run test:unit` (node test + tsx; store/order-chat only currently) |
| **Web-admin E2E** | `cd web-admin && npm run test:e2e` (Playwright; scoped per e2e script) |
| **Flutter tests** | `make flutter-test` (both apps) |
| **All tests** | `make test` (backend + both Flutter) |
| **Lint all** | `make lint` (web-admin ESLint + backend `ruff`) |
| **Create Django superuser** | `make backend-createsuperuser` (in container) |
| **Django shell** | `make backend-shell` (in container) |
| **View DB tables** | `make backend-check-db` (in container) |
| **Diagnose ALLOWED_HOSTS / API** | `make doctor` |
| **Migrate in Docker** | `make backend-migrate-all` |
| **Rebuild API container** | `make restart-api` (when code or .env changes) |

## Task Workflow

1. Read `docs/PROGRESS.md` to find incomplete tasks or Fase priority.
2. For specific task ID (e.g., T6.1.2):
   - `docs/TASKS.md` → exact scope, acceptance criteria, test names
   - For Fase 6 (merchant onboarding): `docs/MERCHANT_ONBOARDING.md` + `docs/FASE6_BLOCKS.md`
   - For Fase 7 (admin maturity): `docs/FASE7_BLOCKS.md` + `docs/ADMIN_MATURITY.md` (tasks are **not** in `docs/TASKS.md`)
   - For products/services: `docs/PRODUCTS_AND_SERVICES.md`
3. Implement using Vertical Slice + Clean Architecture (see `.cursor/rules/`).
4. Run tests listed in task definition.
5. Mark `[x]` in `docs/PROGRESS.md` and commit: `feat(scope): description` (Spanish optional).

## Architecture Principles (in `.cursor/rules/`)

**Vertical Slice + Clean Architecture** per module:

```
features/<module>/
├── domain/           # Entities, value objects, abstract repos (no framework)
├── application/      # Use cases, DTOs, services (no ORM)
└── infrastructure/   # Django models, API endpoints, tasks, UI components
```

**Backend:** DRF serializers in `infrastructure/`. Perms checks via `ScopedPermission` + roles in `CustomUser.user_role`.

**web-admin:** Server Components by default; `'use client'` only for interactivity. Zustand stores per feature in `features/*/stores/`. Consume `/api/v1/` exclusively (no BFF paths).

**Flutter:** Riverpod for state. Use case tests mock repositories with `mocktail`. Widget tests use `testWidgets` + `pumpWidget`.

## Key Docs (for high-signal context)

- `docs/ROADMAP.md` — Fase 1–6 priorities + timelines
- `docs/TASKS.md` — Full task catalog (T1.x, T2.x … T6.x) with test names
- `docs/PROGRESS.md` — Mark `[x]` to track completion
- `docs/FASE7_BLOCKS.md` + `docs/ADMIN_MATURITY.md` — Fase 7 admin maturity (blocks 7.1–7.7; tasks not in TASKS.md)
- `docs/FASE4_BLOCKS.md` — Flutter customer/driver blocks
- `docs/MERCHANT_ONBOARDING.md` — Fase 6 registration flow + portal architecture
- `docs/PRODUCTS_AND_SERVICES.md` — Dual product/service model
- `docs/MEDIA_STORAGE.md` — Product photo upload + `SERVE_MEDIA` flag
- `docs/SMOKE_E2E_CHECKLIST.md` — Production smoke (api.dtsdrop.com) before release
- `docs/STORE_RELEASE_CHECKLIST.md` + `docs/PLAY_STORE_GOOGLE_SIGNIN.md` + `docs/APP_STORE_CONNECT_REVIEW.md` — App Store/Play publishing + Google Sign-In Android SHA gotchas
- `docs/DEPLOY_DOCKER.md` — Full-stack Docker for servers
- `docs/DEPLOY_RAILWAY.md` — Railway backend deploy (PostGIS + GDAL)
- `docs/CI_GITHUB_ACTIONS.md` — GitHub Actions per submodule + secrets setup
- `docs/PUSH_NOTIFICATIONS.md` — FCM device tokens + event-driven push
- `docs/WEB_ADMIN.md` — Next.js + Zustand conventions
- `docs/FLUTTER_API.md` — REST client patterns for apps
- `docs/MONOREPO.md` — Submodule sync commands + workflow

## Test Shortcuts

```bash
# Backend — single module
cd backend && uv run pytest features/orders/tests/ -v

# Fase 6 tests (merchant portal) by block
make fase6-test BLOCK=6.1    # T6.1.x tests
make fase6-test BLOCK=all    # All blocks 6.1–6.11

# Fase 6 single task
make fase6-test-task TASK=T6.1.4

# Flutter
make fase4-test BLOCK=4.1

# web-admin — single e2e spec
cd web-admin && npm run test:e2e -- e2e/merchant_orders_list_test.spec.ts
```

## Phase Priority (Current)

✅ Fase 1–5 done (backend + web MVP + Flutter features + real-time Channels).
✅ **Fase 6 done** — Merchant onboarding + seller portal (all T6.x `[x]` in `docs/PROGRESS.md`).
⬜ **Fase 7 (NEW)** — Admin maturity (`docs/FASE7_BLOCKS.md`, blocks 7.1–7.7).
⬜ **Store release** — App Store + Play (`docs/STORE_RELEASE_CHECKLIST.md`, `docs/APP_STORE_CONNECT_REVIEW.md`, `docs/PLAY_STORE_GOOGLE_SIGNIN.md`).
⬜ Post-MVP — Payments, schedules, KYC, marketplace (`docs/POST_MVP_PROGRESS.md`).

## Submodule Note

Each project is a separate Git repo with its own CI, branch rules, and merge workflows. Always commit changes in the submodule folder, then commit the root submodule pointer (the gitlink, not `.gitmodules` — that only holds URLs). Do NOT force-push submodule branches without coordination. After a root `git pull`, run `git submodule update --init --recursive`.

## Debugging

- **API not responding?** Run `make doctor` — checks `ALLOWED_HOSTS`, Django container, and HTTP 200.
- **Photos not visible?** Run `make media-check` — inspects `SERVE_MEDIA`, `MEDIA_ROOT`, and files on disk.
- **Migrations stuck?** `make backend-check-db` to list tables; `make backend-makemigrations-all` if schema drift.
- **Container crash?** `make logs` (all) or `docker logs dts-api` (single).
- **Stale container state?** `make restart-api` rebuilds API + workers.

## Knowledge Graph (graphify)

A navigable knowledge graph of the codebase lives in `graphify-out/`. It was built from the docs, rules, and manifests — not from source code — and captures architecture, workflows, constraints, and cross-module relationships.

**What's in it:**
- `graph.html` — interactive graph (open in browser)
- `graph.json` — raw graph data (172 nodes, 146 edges, 45 communities)
- `GRAPH_REPORT.md` — audit report with god nodes, surprising connections, suggested questions

**When to use:** Before diving into a task, query the graph to understand how a concept connects to the rest of the system. Faster than re-scanning all docs.

```bash
# Query the graph (BFS traversal — broad context)
graphify query "How does order state flow work?"

# DFS — trace a specific path
graphify query "What connects Backend to Flutter apps?" --dfs

# Shortest path between two concepts
graphify path "Backend (Django + DRF)" "Flutter Customer App"

# Plain-language explanation of a concept
graphify explain "Fase 6"
```

**Key bridge nodes surfaced by the graph:**
- `Backend (Django + DRF)` connects communities 0, 1, 5, 7, 8 (highest centrality)
- `Fase 6 - Merchant Onboarding` bridges communities 0 and 1
- `Docker Compose Setup` connects infra to backend and deployment

**Rebuild:** Run `/graphify` from repo root to update. Uses `graphify.query` CLI (no API key needed for queries).

## Cursor Rules & Skills

See `.cursor/rules/` for Cursor-specific guidance (Django, Flutter, Next.js, testing, commits).

Project provides custom skills in `.cursor/skills/` for complex tasks (if any). Check `.cursor/commands/` for shortcuts.
