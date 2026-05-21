# Deployment Guide

Deploy, env vars, build and rollback for Python backend.

## Environment variables

### Configuration via pydantic-settings

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Database
    database_url: str
    database_pool_size: int = 20

    # Auth
    secret_key: str
    access_token_expire_minutes: int = 15

    # App
    debug: bool = False
    cors_origins: list[str] = []
    log_level: str = "INFO"

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}
```

### .env.example

```bash
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/app
SECRET_KEY=change-me-in-production
DEBUG=false
CORS_ORIGINS=["https://app.example.com"]
LOG_LEVEL=INFO
```

### Rules

- Never commit real `.env`.
- Never use default values in production.
- Always provide an updated `.env.example`.
- Secrets via env vars, never in code.

## Build

### Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install deps
COPY pyproject.toml .
RUN pip install --no-cache-dir .

# Copy code
COPY . .

# Collect static (if applicable)
# RUN python -m collectstatic

# Non-root user
RUN useradd -m appuser
USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### docker-compose.yml (dev)

```yaml
services:
  app:
    build: .
    ports: ["8000:8000"]
    env_file: .env
    depends_on:
      db: { condition: service_healthy }

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    ports: ["5432:5432"]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 5s
      retries: 5
```

## Deploy

### Systemd (bare metal)

```ini
# /etc/systemd/app/app.service
[Unit]
Description=App API
After=network.target postgresql.service

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/app
EnvironmentFile=/opt/app/.env
ExecStart=/opt/app/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Deploy checklist

1. `alembic upgrade head` (with backup first in production).
2. Restart service.
3. Verify healthcheck.
4. Verify logs.
5. Monitor for 15 minutes.

### Nginx (reverse proxy)

```nginx
server {
    listen 80;
    server_name api.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate /etc/ssl/certs/app.crt;
    ssl_certificate_key /etc/ssl/private/app.key;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;
    }

    location /health {
        proxy_pass http://127.0.0.1:8000/health;
        access_log off;
    }
}
```

## Rollback

### Procedure

1. Detect problem (alert, error, complaint).
2. `git revert <commit>` or checkout previous version.
3. Redeploy.
4. If migration: `alembic downgrade -1` BEFORE redeploying old code.
5. Verify healthcheck.
6. Post-mortem in `docs/incidents/`.

### Rule

- Always have migration with tested downgrade.
- Never rollback migration without backup.
- Never revert code without reverting corresponding migration.

## Graceful shutdown

```python
import signal
import asyncio

@app.on_event("startup")
async def startup():
    app.state.db_engine = engine

@app.on_event("shutdown")
async def shutdown():
    await app.state.db_engine.dispose()
```

uvicorn already handles SIGTERM gracefully. Workers finish in-progress requests.

## Hard rules

- Never deploy without migration with downgrade.
- Never use `DEBUG=true` in production.
- Never serve without HTTPS.
- Never hardcode env vars.
- Never deploy without verifying healthcheck.
- Always have tested rollback before deploy.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Migration with downgrade**: Never deploy without migration with tested downgrade.
- **DEBUG=false in production**: Never use `DEBUG=true` in production.
- **HTTPS mandatory**: Never serve API in production without HTTPS.
- **No hardcode of env vars**: Never hardcode environment variables; use Settings.
- **Post-deploy healthcheck**: Never deploy without verifying healthcheck.
- **Tested rollback**: Always have tested rollback before deploy.
- **Do not commit `.env`**: Never commit real `.env`.
- **No default values in production**: Never use default values for secrets in production.
- **Migration rollback with backup**: Never rollback migration without backup.
- **Revert code and migration together**: Never revert code without reverting corresponding migration.
