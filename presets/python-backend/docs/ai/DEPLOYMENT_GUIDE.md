# Deployment Guide

Deploy, env vars, build e rollback para Python backend.

## Environment variables

### Configuração via pydantic-settings

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Banco
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

### Regras

- Nunca commitar `.env` real.
- Nunca usar valores default em produção.
- Sempre fornecer `.env.example` atualizado.
- Secrets via env vars, nunca no código.

## Build

### Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Instalar deps
COPY pyproject.toml .
RUN pip install --no-cache-dir .

# Copiar código
COPY . .

# Coletar static (se aplicável)
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

### Checklist de deploy

1. `alembic upgrade head` (com backup antes em produção).
2. Reiniciar serviço.
3. Verificar healthcheck.
4. Verificar logs.
5. Monitorar por 15 minutos.

### Nginx (proxy reverso)

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

1. Detectar problema (alerta, erro, reclamação).
2. `git revert <commit>` ou checkout da versão anterior.
3. Redeploy.
4. Se migration: `alembic downgrade -1` ANTES de redeployar código antigo.
5. Verificar healthcheck.
6. Post-mortem em `docs/incidents/`.

### Regra

- Sempre ter migration com downgrade testado.
- Nunca fazer rollback de migration sem backup.
- Nunca reverter código sem reverter migration correspondente.

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

uvicorn já lida com SIGTERM graceful. Workers terminam requests em andamento.

## Regras duras

- Nunca deployar sem migration com downgrade.
- Nunca usar `DEBUG=true` em produção.
- Nunca servir sem HTTPS.
- Nunca hardcodar env vars.
- Nunca deployar sem verificar healthcheck.
- Sempre ter rollback testado antes de deploy.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Migration com downgrade**: Nunca deployar sem migration com downgrade testado.
- **DEBUG=false em produção**: Nunca usar `DEBUG=true` em produção.
- **HTTPS obrigatório**: Nunca servir API em produção sem HTTPS.
- **Sem hardcode de env vars**: Nunca hardcodar variáveis de ambiente; usar Settings.
- **Healthcheck pós-deploy**: Nunca deployar sem verificar healthcheck.
- **Rollback testado**: Sempre ter rollback testado antes de deploy.
- **Não commitar `.env`**: Nunca commitar `.env` real.
- **Sem valores default em produção**: Nunca usar valores default para secrets em produção.
- **Rollback de migration com backup**: Nunca fazer rollback de migration sem backup.
- **Reverter código e migration juntos**: Nunca reverter código sem reverter migration correspondente.
