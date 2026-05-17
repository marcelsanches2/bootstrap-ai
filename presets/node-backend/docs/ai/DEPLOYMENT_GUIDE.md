# Deployment Guide

Deploy, env vars e rollback para Node.js backend.

## Environment variables

```typescript
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string().min(32),
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']),
  CORS_ORIGINS: z.string().default(''),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

export const config = envSchema.parse(process.env);
```

Sempre `.env.example` atualizado. Nunca commitar `.env`.

## Build

```bash
npm run build     # tsc
npm run start     # node dist/index.js
```

### Dockerfile

```dockerfile
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
RUN npx prisma generate

FROM node:20-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/prisma ./prisma
USER node
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

## Systemd

```ini
[Unit]
Description=App API
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/app
EnvironmentFile=/opt/app/.env
ExecStart=/opt/app/node_modules/.bin/node dist/index.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## Deploy checklist

1. `npx prisma migrate deploy`
2. Reiniciar serviço
3. Verificar healthcheck
4. Monitorar 15 minutos

## Rollback

1. Detectar problema.
2. `git revert <commit>` ou checkout anterior.
3. Rebuild e redeploy.
4. Se migration: `npx prisma migrate resolve --rolled-back <migration>` se necessário.
5. Verificar healthcheck.

## Graceful shutdown

```typescript
process.on('SIGTERM', async () => {
  logger.info('Shutting down...');
  server.close();
  await prisma.$disconnect();
  process.exit(0);
});
```

## Regras duras

- Nunca deployar sem migration com downgrade.
- Nunca `NODE_ENV=development` em produção.
- Nunca servir sem HTTPS.
- Nunca hardcodar env vars.
- Sempre ter rollback testado.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Nunca deployar sem migration com downgrade**: Toda migration precisa de caminho de rollback documentado.
- **Nunca `NODE_ENV=development` em produção**: Ambiente de produção deve ter `NODE_ENV=production`.
- **Nunca servir sem HTTPS**: TLS é obrigatório em produção.
- **Nunca hardcodar env vars**: Usar env vars via Zod validation.
- **Sempre ter rollback testado**: Rollback deve ser validado antes de deploy.
- **Sempre `.env.example` atualizado**: Nunca commitar `.env` real.
- **Sempre graceful shutdown**: Tratar SIGTERM para fechar conexões corretamente.
