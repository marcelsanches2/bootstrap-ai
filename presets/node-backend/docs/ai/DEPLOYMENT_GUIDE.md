# Deployment Guide

Deploy, env vars, and rollback for Node.js backend.

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

Always keep `.env.example` updated. Never commit `.env`.

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
2. Restart service
3. Verify healthcheck
4. Monitor for 15 minutes

## Rollback

1. Detect the problem.
2. `git revert <commit>` or checkout previous version.
3. Rebuild and redeploy.
4. If migration: `npx prisma migrate resolve --rolled-back <migration>` if needed.
5. Verify healthcheck.

## Graceful shutdown

```typescript
process.on('SIGTERM', async () => {
  logger.info('Shutting down...');
  server.close();
  await prisma.$disconnect();
  process.exit(0);
});
```

## Hard rules

- Never deploy without a migration with downgrade path.
- Never `NODE_ENV=development` in production.
- Never serve without HTTPS.
- Never hardcode env vars.
- Always have a tested rollback.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any of the rules below.

- **Never deploy without a migration with downgrade**: Every migration needs a documented rollback path.
- **Never `NODE_ENV=development` in production**: Production environment must have `NODE_ENV=production`.
- **Never serve without HTTPS**: TLS is mandatory in production.
- **Never hardcode env vars**: Use env vars via Zod validation.
- **Always have a tested rollback**: Rollback must be validated before deploy.
- **Always keep `.env.example` updated**: Never commit real `.env`.
- **Always graceful shutdown**: Handle SIGTERM to close connections properly.
