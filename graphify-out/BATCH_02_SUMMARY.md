# Graphify Batch 2 Extraction Summary

**Output File:** `.graphify_chunk_02.json`  
**Status:** ✅ Complete and validated

## Documents Processed (10 files)

1. `/tmp/dts-focus/docs/MEDIA_STORAGE.md` — Media storage backends and configuration
2. `/tmp/dts-focus/docs/PRODUCTS_AND_SERVICES.md` — Product types, categories, service orders
3. `/tmp/dts-focus/docs/ARCHITECTURE.md` — Vertical Slice + Clean Architecture patterns
4. `/tmp/dts-focus/docs/DEPLOY_DOCKER.md` — Docker server deployment guide
5. `/tmp/dts-focus/docs/DEPLOY_RAILWAY.md` — Railway platform deployment
6. `/tmp/dts-focus/docs/CI_GITHUB_ACTIONS.md` — GitHub Actions CI/CD workflows
7. `/tmp/dts-focus/rules/project-overview.mdc` — General monorepo context
8. `/tmp/dts-focus/rules/monorepo.mdc` — Monorepo structure conventions
9. `/tmp/dts-focus/AGENTS.md` — Agent development guide
10. `/tmp/dts-focus/README.md` — Project overview

## Extraction Statistics

- **Total Nodes:** 102
- **Total Edges:** 46
- **Hyperedges:** 0 (empty, as specified)
- **File Size:** 1,061 lines JSON

## Key Categories Extracted

### Infrastructure & DevOps (25 nodes)
- Docker Compose setup, PostGIS + Redis requirements
- Railway deployment architecture with internal networking
- Media storage backends (local, S3, Cloudinary)
- Entrypoint migration flow
- Django Admin interface
- ALLOWED_HOSTS and CSRF configuration

### Developer Commands & Workflows (27 nodes)
- Make commands (setup, docker-up, backend-test, web-admin-dev, flutter-test, etc.)
- Task workflow process
- Docker daily operations
- Git pull update workflow
- Debugging patterns (6 types)
- Railway CLI operations

### Architecture Patterns (11 nodes)
- Vertical Slice + Clean Architecture
- Backend feature structure (domain/application/infrastructure)
- Flutter feature structure
- Django to Clean Architecture mapping
- Web-admin component patterns
- ScopedPermission authorization pattern

### Domain Models (8 nodes)
- ProductType (PHYSICAL vs SERVICE)
- Category hierarchy (2-level)
- Order states (physical delivery vs service)
- ServiceOrderDetails model
- Stock validation rules

### CI/CD & Testing (7 nodes)
- GitHub Actions CI matrix (5 independent workflows)
- Branch triggers (main, develop, master)
- Unit tests (no secrets required)
- E2E optional tests
- CI activation checklist
- Realtime smoke tests

### Technology Stacks & Tools (15 nodes)
- Backend: Django + DRF + Celery + Channels + PostGIS
- Web-admin: Next.js + React + Tailwind
- Flutter apps: Riverpod + Clean Architecture
- UV package manager
- pytest Django DB markers
- Cursor AI shortcuts

### Deployment & Setup (9 nodes)
- Docker server requirements and installation steps
- Railway services and configuration
- Railway environment variables
- Railway pre-deploy commands
- Railway Celery workers
- Production security checklist

## Relationship Types (Label Distribution)

- **includes** (3 edges) — Component inclusion relationships
- **enables_in** (1 edge) — Enables functionality in environment
- **stores_media_via** (1 edge) — Storage mechanism
- **configured_by** (1 edge) — Configuration dependency
- **orchestrates** (2 edges) — Command orchestration
- **starts** / **starts_full** (2 edges) — Service startup
- **triggers** (3 edges) — Workflow triggering
- **verifies** (1 edge) — Verification relationships
- **uses** (4 edges) — Usage relationships
- **references_via** (1 edge) — Reference mechanism
- **can_use** (1 edge) — Optional component
- **implements** (1 edge) — Implementation
- **extends** (1 edge) — Extension relationship
- **contains** (1 edge) — Containment relationship
- **requires** (1 edge) — Requirement relationship
- **follows** (1 edge) — Pattern following
- **enforces** (1 edge) — Rule enforcement
- **organizes** (1 edge) — Organization
- **manages_dependencies** (1 edge) — Dependency management
- **satisfied_by** (1 edge) — Satisfaction relationship
- **used_in** (1 edge) — Usage context
- **final_step_of** (1 edge) — Process step
- **defines** (1 edge) — Definition relationship
- **defines_conventions** (1 edge) — Convention definition
- **current_focus** (1 edge) — Priority/focus
- **manages** (1 edge) — Management relationship
- **leverages** (1 edge) — Leverage relationship
- **exposes** (1 edge) — Exposure relationship
- **precedes** (1 edge) — Ordering relationship
- **connects_to** (1 edge) — Connection relationship
- **initializes** (1 edge) — Initialization

## Emphasis Areas Covered

✅ **Infrastructure & DevOps**: Docker, Railway, PostGIS, Redis, migrations  
✅ **Developer Commands**: All make commands with descriptions  
✅ **Setup Gotchas**: Submodules, uv, GDAL, PostGIS requirements  
✅ **Testing Patterns**: pytest markers, smoke tests, E2E optional  
✅ **Code Organization**: Vertical Slice, features/, Clean Architecture  
✅ **Deployment Flows**: Docker server, Railway, git pull updates  
✅ **CI Pipeline**: GitHub Actions matrix, branch triggers, no-secret tests  

## Confidence Scores

- **High (0.95):** 68 nodes/edges — Core infrastructure, deployment, architecture
- **Medium (0.90):** 18 nodes/edges — Important workflows, patterns
- **Lower (0.85):** 16 nodes/edges — Optional features, debugging workflows

## Notes for Knowledge Graph Integration

1. **Batch 2 builds on Batch 1** — This extraction emphasizes infrastructure, deployment, and developer workflows rather than domain-specific entities
2. **Cross-file consistency** — References to MEDIA_STORAGE.md, PRODUCTS_AND_SERVICES.md, etc. are consistently mapped
3. **Make commands** — All 19 key make commands documented as individual workflow nodes
4. **Railway platform specifics** — Internal networking (${{postgis.DATABASE_URL}}) vs public URLs carefully distinguished
5. **Testing emphasis** — CI/CD patterns include both smoke tests and full test suites; no-secrets philosophy documented
6. **Architecture binding** — Vertical Slice pattern tied to actual implementation in backend/flutter/web-admin

