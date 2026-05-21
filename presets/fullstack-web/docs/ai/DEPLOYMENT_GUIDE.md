# Deployment Guide — Fullstack Web

Deploy, env vars, build, hosting, and rollback for fullstack applications.

---

## Environment variables

### Validation with Zod

Use a Zod schema to validate env vars on startup. For fullstack frameworks (Next.js/Remix), separate public from private variables:

```typescript
// shared/config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  // Server-only
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string().min(32),
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']),
  CORS_ORIGINS: z.string().default(''),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),

  // Public (framework prefix)
  NEXT_PUBLIC_API_URL: z.string().url(),    // Next.js
  // VITE_API_URL: z.string().url(),        // Vite (separate SPA)
});

export const config = envSchema.parse(process.env);
```

### Conventions by framework

| Framework | Public (embedded in bundle) | Server |
|---|---|---|
| **Next.js** | `NEXT_PUBLIC_*` | No prefix (server-only) |
| **Remix** | `PUBLIC_*` / `VITE_*` | No prefix (loader/action) |
| **Vite SPA** | `VITE_*` | — (separate backend) |

### `.env.example`

Keep `.env.example` updated with all keys, without sensitive values:

```bash
# .env.example

# Server
DATABASE_URL=
JWT_SECRET=
PORT=3000
NODE_ENV=development
CORS_ORIGINS=
LOG_LEVEL=info

# Client (Next.js)
NEXT_PUBLIC_API_URL=
NEXT_PUBLIC_APP_TITLE=

# Client (Vite — if separate SPA)
# VITE_API_URL=
# VITE_APP_TITLE=
```

**Never** put secrets in public variables (`NEXT_PUBLIC_*`, `VITE_*`).
**Never** commit real `.env`.

---

## Build

### Next.js — fullstack (frontend + server)

```bash
npx next build    # Produces .next/ (frontend + server bundle)
npx next start    # Starts Node.js server with the app
```

### Remix — fullstack

```bash
npx remix build   # Produces build/ (client + server)
npx remix start   # Starts Node.js server
```

### Separate SPA + separate backend

```bash
# Frontend (Vite)
npx vite build    # Produces dist/

# Backend
npm run build     # tsc → dist/
npm run start     # node dist/index.js
```

### Build configuration — Vite

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    outDir: 'dist',
    sourcemap: true, // for debugging, do NOT serve publicly
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          query: ['@tanstack/react-query'],
        },
      },
    },
  },
});
```

---

## Docker

### Fullstack — single image (recommended for Next.js/Remix)

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
COPY --from=builder /app/.next ./.next           # or /app/build for Remix
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/public ./public
USER node
EXPOSE 3000
CMD ["node_modules/.bin/next", "start"]           # or remix start
```

### Separate — frontend (nginx) + backend (Node)

**Frontend:**

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Backend:**

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

---

## CDN and Cache

### Static assets

- Files in `assets/` are versioned by hash in the name (automatic by the framework).
- Long cache for assets with hash (1 year is safe).
- HTML and entrypoint need to allow quick updates (short cache or no-cache).

### Nginx — cache configuration

```nginx
# Assets with hash — aggressive cache
location /assets/ {
  expires 1y;
  add_header Cache-Control "public, immutable";
}

# HTML — no cache
location / {
  try_files $uri $uri/ /index.html;
  add_header Cache-Control "no-cache, no-store, must-revalidate";
}
```

### Frontend/backend contract

When changing API contract:

1. Communicate breaking changes between teams.
2. If possible, version the API (`/v2/users`).
3. Old client cache may show stale data — consider invalidation.

---

## Hosting

### Vercel / Managed (Next.js)

```bash
npm i -g vercel
vercel           # Preview deploy
vercel --prod    # Production deploy
```

Settings:

- Environment variables in Settings → Environment Variables.
- Automatic preview deploy per branch.
- Custom domain in Settings → Domains.

### VPS / Self-hosted with systemd

```ini
# /etc/systemd/system/app.service
[Unit]
Description=Fullstack App
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/app
EnvironmentFile=/opt/app/.env
ExecStart=/opt/app/node_modules/.bin/next start
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable app
sudo systemctl start app
```

---

## Deploy checklist

1. **Migrations** — `npx prisma migrate deploy`
2. **Build** — `npm run build` (frontend + backend)
3. **Deploy/restart** — Docker image or `sudo systemctl restart app`
4. **Healthcheck** — `curl -f http://localhost:3000/api/health`
5. **Monitor** — watch logs and metrics for 15 minutes

---

## Graceful shutdown

```typescript
process.on('SIGTERM', async () => {
  logger.info('Shutting down...');
  server.close();
  await prisma.$disconnect();
  process.exit(0);
});
```

---

## Compression

Enable gzip or brotli on the web server:

```nginx
# Nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml;
gzip_min_length 1024;
```

For Vite, generate pre-compressed assets:

```typescript
// vite.config.ts
import viteCompression from 'vite-plugin-compression';

export default defineConfig({
  plugins: [viteCompression({ algorithm: 'brotliCompress' })],
});
```

---

## Security headers — hosting/nginx level

> For middleware/application headers, see `SECURITY_GUIDE.md`.

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';" always;
```

### SPA Fallback (SPA without SSR only)

```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

**Important:** Do not apply SPA fallback in Next.js/Remix SSR apps — the framework manages server-side routes.

---

## Rollback

Rollback plan must cover:

1. **Previous build accessible** — keep artifact or Docker image of the previous version.
2. **Env rollback** — if you changed an environment variable, revert it too.
3. **Migration** — `npx prisma migrate resolve --rolled-back <migration>` if necessary.
4. **API contract** — ensure previous version works with migrated data.
5. **Client cache** — users with old cached version may have inconsistent behavior.

```bash
# Docker rollback
docker tag app:latest app:backup
docker build -t app:latest .
# If something goes wrong:
docker stop app-container
docker run -d --name app-container -p 3000:3000 app:backup
```

---

## Anti-patterns

- **Secret in `NEXT_PUBLIC_*` or `VITE_*`:** public variables are embedded in the bundle and visible in the browser.
- **Committed `.env`:** always add to `.gitignore`.
- **`NODE_ENV=development` in production:** changes framework behavior, errors, and performance.
- **No sourcemap in production:** makes debugging harder. Generate, but do not serve publicly.
- **Aggressive cache on HTML:** prevents updates. Reserve long cache for assets with hash.
- **Deploy without build check:** run `npm run build` + `npm run lint` + `npx tsc --noEmit` before deploy.
- **SPA fallback in SSR app:** breaks server-rendered routes.
- **Deploy without migration with downgrade:** every migration needs a documented rollback path.
- **Serving without HTTPS:** never in production.
- **Hardcoded env vars:** always use environment variables.
- **No planned rollback:** every deploy must have a way to go back.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

### Secrets and env vars
- **Secret in `NEXT_PUBLIC_*` or `VITE_*`**: public variables are embedded in the bundle — never put secrets in them.
- **Committed `.env`**: real `.env` always in `.gitignore`.
- **Hardcoded env vars**: always use environment variables, never fixed values in code.

### Build and deploy
- **Deploy without build check**: run `npm run build` + `npm run lint` + `npx tsc --noEmit` before deploy.
- **No planned rollback**: every deploy must have a way to go back (previous image, migration rollback).
- **Deploy without migration with downgrade**: every migration needs a documented rollback path.

### Production
- **`NODE_ENV=development` in production**: changes framework behavior, errors, and performance — prohibited.
- **Serving without HTTPS**: never in production.
- **SPA fallback in SSR app**: breaks server-rendered routes (Next.js/Remix).

### Cache and assets
- **Aggressive cache on HTML**: prevents updates. Reserve long cache for assets with hash.
- **No sourcemap in production**: makes debugging harder. Generate, but do not serve publicly.
