# E-Commerce Production

A full-stack e-commerce administration platform built with **Flutter**, **Django REST Framework**, and **PostgreSQL**. The repository brings together an admin-facing Flutter application, a Django API, supporting data services, and an AI-agent/MCP experimentation layer.

> **Project status:** Active development / portfolio project. Features and setup may evolve. The repository currently focuses on the administration experience and backend foundations; verify individual flows in the source before treating them as production-ready.

## At a glance

- **Admin frontend:** Flutter and Dart
- **Backend API:** Python, Django, Django REST Framework
- **Database:** PostgreSQL
- **Caching / background-work infrastructure:** Redis; Celery configuration is present
- **Authentication:** Custom Django user model and JWT-based API authentication
- **Frontend architecture:** Feature-oriented structure, Bloc state management, dependency injection, repository/data-source separation
- **Additional exploration:** AI chat/agent services and a custom Model Context Protocol (MCP) server layer

## Project goals

The project explores how to build and maintain the core pieces of an e-commerce management system rather than only a standalone UI:

- Organize backend functionality into Django apps and service modules.
- Separate frontend presentation, state management, domain logic, and data access.
- Connect a Flutter admin client to authenticated REST APIs.
- Support product catalogue and variant management workflows.
- Add operational foundations such as caching, background tasks, and database services.
- Experiment with AI-assisted chat/analytics and tool-oriented integrations.

## Architecture

```text
e_commerce_production/
├── frontend/
│   └── frontend_admin/          # Flutter admin application
│       └── lib/
│           ├── app/             # App setup and Bloc observer
│           ├── core/            # DI, networking, auth, routing, theme, utilities
│           └── features/        # Auth, categories, chat, products, variations
├── backend/
│   └── backend_admin/           # Django project and API
│       ├── authentication/     # User, authentication, profile, verification
│       ├── ecommerce/           # E-commerce domain
│       ├── inventory/           # Inventory-related operations
│       ├── analytics/           # Analytics endpoints/models
│       ├── recommendations/     # Recommendation functionality
│       ├── admin_dashboard/     # Admin product/category services and views
│       └── ai_agents/            # Chat agents, analytics, MCP tools/server
├── postgresql/
│   └── docker-compose.yml       # PostgreSQL and pgAdmin
└── redis/
    └── docker-compose.yml       # Redis and RedisInsight
```

### Request flow

1. The Flutter admin interface dispatches Bloc events and renders states.
2. Feature/domain code communicates through repository and data-source abstractions.
3. The networking layer uses Dio to call the Django REST API and handle authentication concerns.
4. Django REST Framework routes requests to app-level views, serializers, and service modules.
5. PostgreSQL stores application data; Redis is configured for caching and background-work infrastructure.
6. The AI-agent area contains chat/analytics components and an MCP server/tool layer.

## Main capabilities represented in the codebase

### Admin application

- **Authentication foundation:** Login and authentication-state handling, shared preferences, token management, and an API client/interceptor layer.
- **Product management:** Product-related screens and API integration, including image-selection utilities.
- **Product variations:** Dedicated variation workflows for product options, sizes, prices, and stock-related information.
- **Category management:** A separate feature area for category operations.
- **Chat interface:** A chat feature connected to the backend AI-agent functionality.
- **Reusable app infrastructure:** Dependency injection, route definitions, shared theme, responsive/layout helpers, and common utilities.

### Backend

- **Authentication and identity:** Custom user model, JWT authentication configuration, profile and email-verification modules.
- **E-commerce domain:** Django app for core commerce entities and API functionality.
- **Product and category administration:** Dedicated dashboard views, serializers, and service modules for product, variant, filtering, image, and cache concerns.
- **Inventory:** Separate app for inventory-related models and operations.
- **Analytics and recommendations:** Dedicated Django apps for these domains.
- **AI-agent services:** Chat API/serialization, agent services, analytics and cache helpers, monitoring/metrics components, and an MCP server/tool layer.

### Local infrastructure

- PostgreSQL 17 with persistent Docker volume and pgAdmin.
- Redis 8 with append-only persistence and a health check.
- RedisInsight for inspecting Redis during development.

## Technology stack

| Area | Technologies |
|---|---|
| Admin UI | Flutter, Dart |
| State management | flutter_bloc / Bloc, Equatable |
| Networking | Dio, HTTP-related utilities |
| Dependency injection | GetIt |
| Functional/error modelling | dartz |
| UI and data presentation | Google Fonts, glassmorphism, fl_chart |
| Media and files | image_picker, file_picker, cached_network_image |
| Backend | Python, Django, Django REST Framework |
| API security | Simple JWT, Django authentication and permissions |
| Data | PostgreSQL |
| Cache / task infrastructure | Redis, django-redis, Celery configuration |
| Local services | Docker Compose |
| AI integration experiments | Python agent services, custom MCP server/tools |

## Getting started

### Prerequisites

Install the following tools before running the project:

- Git
- Flutter SDK compatible with the Dart constraint in `frontend/frontend_admin/pubspec.yaml`
- Python compatible with the backend dependencies
- PostgreSQL
- Redis
- Docker Desktop (recommended for local PostgreSQL and Redis services)

> The repository does not currently provide a single, complete root-level setup script. Configure each service separately and use environment variables for credentials and secrets.

### 1. Clone the repository

```bash
git clone https://github.com/HoTienQuoc/e_commerce_production.git
cd e_commerce_production
```

### 2. Start PostgreSQL

```bash
cd postgresql
docker compose up -d
```

The Compose configuration exposes PostgreSQL on port `5432` and pgAdmin on port `5050`. **Before sharing or deploying this setup, replace the sample development credentials in the Compose file with secure values.**

### 3. Start Redis

Open another terminal from the repository root:

```bash
cd redis
docker compose up -d
```

Redis is exposed on port `6379`; RedisInsight is exposed on port `5540`. Use these services only in a trusted local development environment unless access controls and network exposure have been properly configured.

### 4. Configure the Django backend

```bash
cd backend/backend_admin
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Create a local `.env` file based on the configuration expected by `backend_admin/settings.py`. At minimum, review the following settings and supply values appropriate to your environment:

- `SECRET_KEY`
- `DEBUG`
- `ALLOWED_HOSTS`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
- `DB_HOST`
- `DB_PORT`
- Email credentials if email verification is enabled
- `REDIS_URL` and any CORS settings required for your setup

Then apply migrations and run the development server:

```bash
python manage.py migrate
python manage.py runserver 0.0.0.0:8001
```

If `requirements.txt` is absent or does not match the current source, install the backend dependencies from the project's actual dependency manifest before running these commands. Create an administrative account with `python manage.py createsuperuser` if needed.

### 5. Run the Flutter admin app

```bash
cd frontend/frontend_admin
flutter pub get
flutter run
```

Configure the API base URL for the device or platform you are using. For an Android emulator, `localhost` usually refers to the emulator itself rather than your development machine; use the emulator's host bridge address. For a physical device, use the development machine's reachable LAN address. Ensure Django's host and CORS settings match your development setup.

## Engineering practices demonstrated

- **Feature-oriented organization:** Frontend features are separated from shared application infrastructure.
- **Explicit state management:** Bloc is used to model UI events and states rather than placing all logic directly in widgets.
- **Layered code organization:** Repository/data-source/use-case patterns appear in the frontend architecture.
- **Dependency injection:** GetIt-based service registration supports decoupling and testability.
- **API boundary management:** A shared Dio client and authentication/networking components centralize HTTP concerns.
- **Backend domain separation:** Django apps divide authentication, commerce, inventory, analytics, recommendations, dashboard services, and AI functionality.
- **Operational awareness:** Docker Compose definitions provide reproducible local PostgreSQL and Redis services.
- **Resilience-oriented AI components:** The AI/chat code includes separate cache, monitoring, metrics, and circuit-breaker modules.

## Repository map

- [Flutter admin source](./frontend/frontend_admin/lib)
- [Flutter dependencies](./frontend/frontend_admin/pubspec.yaml)
- [Django project](./backend/backend_admin/backend_admin)
- [Authentication app](./backend/backend_admin/authentication)
- [E-commerce app](./backend/backend_admin/ecommerce)
- [Inventory app](./backend/backend_admin/inventory)
- [Analytics app](./backend/backend_admin/analytics)
- [Recommendations app](./backend/backend_admin/recommendations)
- [Admin dashboard services](./backend/backend_admin/admin_dashboard)
- [AI agents and MCP layer](./backend/backend_admin/ai_agents)
- [PostgreSQL Compose file](./postgresql/docker-compose.yml)
- [Redis Compose file](./redis/docker-compose.yml)

## Current limitations and next steps

This README describes the structure and configuration visible in the repository; it does not imply that every feature is fully tested or production-hardened. Before presenting the project as production-ready, consider completing and documenting:

- A reliable end-to-end setup with a verified dependency manifest and environment template.
- Automated backend and Flutter tests, plus CI checks for formatting, linting, migrations, and API integration.
- Production-safe CORS/host settings, secret management, cookie/security settings, and removal of sample credentials.
- API documentation, example requests, and a clear list of supported workflows.
- Screenshots or a short demo video of completed admin workflows.
- Deployment instructions, logging, monitoring, backup/restore, and error-handling guidance.
- A feature checklist distinguishing implemented, in-progress, and planned functionality.

## About

**Author:** [Ho Tien Quoc](https://github.com/HoTienQuoc)  
**Repository:** [HoTienQuoc/e_commerce_production](https://github.com/HoTienQuoc/e_commerce_production)

This project is intended to demonstrate practical full-stack development across frontend architecture, REST API integration, backend domain organization, and local infrastructure.
