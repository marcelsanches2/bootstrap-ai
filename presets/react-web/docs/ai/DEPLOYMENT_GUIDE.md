# React Web Deployment

## Build

Production build must pass before relevant delivery.

### Vite

```bash
# Production build
npx vite build

# Local preview of build
npx vite preview

# Default output: dist/
```

Typical `vite.config.ts` configuration:

```ts
export default defineConfig({
  build: {
    outDir: 'dist',
    sourcemap: true, // for production debug, not to serve publicly
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

### Next.js

```bash
# Production build
npx next build

# Start server
npx next start

# Default output: .next/
```

Environment variables in Next.js:

- `NEXT_PUBLIC_*` — exposed on the client (embedded in the bundle).
- No prefix — available only in server components / API routes.

**Never** put secrets in `NEXT_PUBLIC_*` variables.

---

## Environment variables

- Real `.env` outside git (add to `.gitignore`).
- `.env.example` with all required keys, without sensitive values.
- Feature flags and API URLs documented in README or `docs/ai/`.

```bash
# .env.example
VITE_API_URL=
VITE_APP_TITLE=
VITE_ENABLE_ANALYTICS=false

# Next.js
NEXT_PUBLIC_API_URL=
NEXT_PUBLIC_APP_TITLE=
DATABASE_URL=           # server-only
```

### Env validation with Zod

```ts
// shared/config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  VITE_API_URL: z.string().url(),
  VITE_APP_TITLE: z.string().default('App'),
});

export const env = envSchema.parse(import.meta.env);
```

---

## Cache and CDN

### Static assets

- Files in `assets/` are versioned by hash in the name (Vite/Next.js do this automatically).
- Long cache for assets with hash (1 year is safe).
- HTML and entrypoint need to allow quick updates (short cache or no-cache).

### Nginx configuration

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

### Frontend/backend contract changes

When changing API contract:

1. Communicate breaking changes to the backend.
2. If possible, version the API (`/v2/users`).
3. Stale client cache may show outdated data — consider invalidation.

---

## Security headers

### Nginx

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';" always;
```

### Next.js (next.config.js)

```js
const securityHeaders = [
  { key: 'X-Frame-Options', value: 'SAMEORIGIN' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
];

module.exports = {
  async headers() {
    return [{ source: '/(.*)', headers: securityHeaders }];
  },
};
```

---

## Hosting

### Vercel (Next.js)

```bash
# Install Vercel CLI
npm i -g vercel

# Preview deploy
vercel

# Production deploy
vercel --prod
```

Important configurations:

- Environment variables in Settings → Environment Variables.
- Automatic preview deploy per branch.
- Custom domain in Settings → Domains.

### VPS / Docker

```dockerfile
# Multi-stage build
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

```bash
# Build and run
docker build -t react-app .
docker run -p 8080:80 react-app
```

---

## SPA Fallback

For SPAs with React Router, configure the server to redirect unfound routes to `index.html`:

```nginx
# Nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

**Important:** Do not apply SPA fallback in Next.js apps with SSR — Next.js manages routes on the server.

---

## Rollback

Rollback plan must cover:

1. **Previous build accessible:** keep artifact or Docker image of the previous version.
2. **Env rollback:** if you changed environment variables, revert them too.
3. **API contract:** if you changed the contract, ensure the previous version works with the current backend.
4. **Client cache:** users with old cached version may have inconsistent behavior.

```bash
# Docker rollback
docker tag react-app:latest react-app:backup
docker build -t react-app:latest .
# If there's a problem:
docker stop react-app-container
docker run -d --name react-app-container -p 8080:80 react-app:backup
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

```ts
// vite.config.ts
import viteCompression from 'vite-plugin-compression';

export default defineConfig({
  plugins: [viteCompression({ algorithm: 'brotliCompress' })],
});
```

---

## Anti-patterns

- **Secret in `NEXT_PUBLIC_*` or `VITE_*`:** public variables are embedded in the bundle and visible in the browser.
- **Committed `.env`:** always add to `.gitignore`.
- **No sourcemap in production:** makes debugging production errors harder. Generate, but do not serve publicly.
- **Aggressive cache on HTML:** prevents quick updates. Reserve long cache for assets with hash.
- **Deploy without build check:** run `npm run build` (and `npm run lint` + `npx tsc --noEmit`) before deploy.
- **SPA fallback in SSR app:** breaks server-rendered routes.
- **No planned rollback:** every deploy must have a way back.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any below.

### Security
- **Never put secrets in `NEXT_PUBLIC_*` or `VITE_*`**: public variables are embedded in the bundle and visible in the browser.
- **Never commit real `.env`**: `.env` must be in `.gitignore`; only commit `.env.example` without sensitive values.
- **Security headers required**: X-Frame-Options, X-Content-Type-Options, Referrer-Policy must be configured.

### Build and deploy
- **Production build must pass before relevant delivery**: run `npm run build` (and `npm run lint` + `npx tsc --noEmit`) before deploy.
- **Every deploy must have planned rollback**: keep previous artifact/image accessible.
- **Do not apply SPA fallback in Next.js app with SSR**: breaks server-rendered routes.

### Cache and env
- **Aggressive cache only for assets with hash**: HTML and entrypoint must have short cache or no-cache.
- **Sourcemap in production must be generated but not served publicly**: makes debugging harder if absent.
- **`.env.example` must have all required keys**: without sensitive values, documenting each variable.
