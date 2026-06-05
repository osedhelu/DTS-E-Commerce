FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        gdal-bin \
        libgdal-dev \
        libgeos-dev \
        libproj-dev \
        libpq-dev \
        gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/backend

COPY backend/pyproject.toml backend/uv.lock ./
RUN uv sync --frozen --no-dev

COPY backend/ ./

# Estáticos (admin, Swagger) embebidos en la imagen — no requiere DB
ENV DJANGO_SETTINGS_MODULE=core.settings \
    SECRET_KEY=collectstatic-build-only \
    DB_HOST=localhost \
    DB_NAME=dts_delivery \
    DB_USER=postgres \
    DB_PASSWORD=postgres
RUN uv run --no-dev python manage.py collectstatic --noinput

COPY docker-infrastructure/backend/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
