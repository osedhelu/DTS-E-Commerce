# Graph Report - .  (2026-08-07)

## Corpus Check
- Corpus is ~26,945 words - fits in a single context window. You may not need a graph.

## Summary
- 172 nodes · 146 edges · 45 communities (14 shown, 31 thin omitted)
- Extraction: 0% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Community 0
- Community 1
- Community 2
- Community 3
- Community 4
- Community 5
- Community 6
- Community 7
- Community 8
- Community 9
- Community 10
- Community 11
- Community 12
- Community 13
- Community 14
- Community 15
- Community 16
- Community 17
- Community 18
- Community 19
- Community 20
- Community 21
- Community 22
- Community 23
- Community 24
- Community 25
- Community 26
- Community 27
- Community 28
- Community 29
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44

## God Nodes (most connected - your core abstractions)
1. `Backend (Django + DRF)` - 13 edges
2. `Web Admin (Next.js + React)` - 8 edges
3. `Fase 6 - Merchant Onboarding Portal` - 8 edges
4. `Flutter Customer App` - 7 edges
5. `Docker Compose Setup` - 7 edges
6. `Monorepo with 4 Submodules` - 6 edges
7. `Flutter Driver App` - 6 edges
8. `Celery + Redis Broker` - 5 edges
9. `Entrypoint Migration Flow` - 5 edges
10. `PostGIS Database` - 4 edges

## Surprising Connections (you probably didn't know these)
- `Fase 3 - Web Admin Frontend` ----> `Web Admin (Next.js + React)`  [HIGH]
  ROADMAP.md → MONOREPO.md
- `Celery + Redis Broker` ----> `Docker Infrastructure`  [HIGH]
  TASKS.md → MONOREPO.md
- `make up` ----> `Docker Compose Setup`  [0.95]
  AGENTS.md → DEPLOY_DOCKER.md
- `DTS E-Commerce` ----> `Monorepo with 4 Submodules`  [HIGH]
  ROADMAP.md → MONOREPO.md
- `Clean Architecture` ----> `Backend (Django + DRF)`  [HIGH]
  ROADMAP.md → MONOREPO.md

## Communities (45 total, 31 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.12
Nodes (18): Backend (Django + DRF), Bloque 1.2 - Accounts, Celery + Redis Broker, Clean Architecture, Coverage Testing, DailySalesReport, Device Token FCM, Django Channels (+10 more)

### Community 1 - "Community 1"
Cohesion: 0.14
Nodes (17): Cookie-based JWT Auth, EmailVerificationToken, Fase 6 - Merchant Onboarding Portal, FOOD Vertical, Mailpit SMTP Server, Media Serving (SERVE_MEDIA), Middleware Auth Guard, Next.js Web Admin (+9 more)

### Community 2 - "Community 2"
Cohesion: 0.13
Nodes (16): Apple Authentication, Customer Saved Addresses, Customer Profile, Delivery Offers, Driver Earnings API, Driver KYC Verification, Event-Driven Push Notifications, FCM Push Notifications (+8 more)

### Community 3 - "Community 3"
Cohesion: 0.13
Nodes (15): Bloque 1.4 - Products, Bloque 1.5 - Orders, Categories Hierarchy, Merchant Landing /vender, NotificationType Enum, OrderStatus Enum, ProductType Enum, Public Merchant Routes (+7 more)

### Community 4 - "Community 4"
Cohesion: 0.17
Nodes (13): Cloudinary Storage Backend, Docker Compose Setup, Docker Daily Commands, Docker PostGIS + Redis Requirement, Docker Server Requirements, Local Storage Backend, Make Commands - Root, make docker-up (+5 more)

### Community 5 - "Community 5"
Cohesion: 0.22
Nodes (9): Backend Feature Structure, Django Admin Interface, Django to Clean Architecture Mapping, Fase 6 - Merchant Onboarding Priority, Flutter Feature Structure, Flutter Riverpod Testing, ScopedPermission Pattern, Task Workflow Process (+1 more)

### Community 6 - "Community 6"
Cohesion: 0.25
Nodes (8): ALLOWED_HOSTS and CSRF Configuration, Docker: Git Pull Update, Docker Server Installation Steps, Docker Server Service URLs, Entrypoint Migration Flow, make backend-createsuperuser, make up, Railway Pre-deploy Commands

### Community 7 - "Community 7"
Cohesion: 0.25
Nodes (8): Backend Stack Definition, Bloque 1.1 - Django Setup, Bloque 1.3 - Stores, Docker Infrastructure, DriverMatcher Service, Geographic Query (PostGIS), PostGIS Database, uv Package Manager

### Community 8 - "Community 8"
Cohesion: 0.38
Nodes (7): CI with GitHub Actions, DTS E-Commerce, Fase 4 - Flutter Mobile, Flutter Customer App, Flutter Driver App, Flutter with Riverpod, Monorepo with 4 Submodules

### Community 9 - "Community 9"
Cohesion: 0.33
Nodes (6): Category Hierarchy (2 Levels), Order States - Physical Products, Order States - Services, ProductType Domain Model, ServiceOrderDetails Model, StockValidator Business Rule

### Community 10 - "Community 10"
Cohesion: 0.33
Nodes (6): Railway Backend Configuration, Railway Celery Workers and Beat, Railway Deployment Architecture, Railway Environment Variables, Railway Internal Networking, Railway: Local Dev with Remote DB

### Community 11 - "Community 11"
Cohesion: 0.50
Nodes (4): /api/v1 Endpoint, DRF Serializers, Fase 3 - Web Admin Frontend, Multi-Role Permission System

### Community 12 - "Community 12"
Cohesion: 0.50
Nodes (4): Merchant KPI Dashboard, Merchant Portal, Super Admin Dashboard, Zustand Store Pattern

### Community 13 - "Community 13"
Cohesion: 0.67
Nodes (3): Monorepo Clone with Submodules, Monorepo Structure Definition, Submodule Git Workflow

## Knowledge Gaps
- **104 isolated node(s):** `DTS E-Commerce`, `Fase 1 - Backend Architecture`, `User Roles`, `Bloque 1.3 - Stores`, `Bloque 1.6 - Delivery` (+99 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **31 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Backend (Django + DRF)` connect `Community 0` to `Community 8`, `Community 1`, `Community 5`, `Community 7`?**
  _High betweenness centrality (0.155) - this node is a cross-community bridge._
- **Why does `Fase 6 - Merchant Onboarding Portal` connect `Community 1` to `Community 0`?**
  _High betweenness centrality (0.116) - this node is a cross-community bridge._
- **What connects `DTS E-Commerce`, `Fase 1 - Backend Architecture`, `User Roles` to the rest of the system?**
  _104 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.11764705882352941 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.13970588235294118 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._