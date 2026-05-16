# Guia de Deploy — Fullstack Web

Deploy, env vars, build, hosting e rollback para aplicação fullstack.

---

## Variáveis de ambiente

### Validação com Zod

Use um schema Zod para validar env vars na inicialização. Para fullstack frameworks (Next.js/Remix), separe variáveis públicas das privadas:

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

  // Público (prefixo framework)
  NEXT_PUBLIC_API_URL: z.string().url(),    // Next.js
  // VITE_API_URL: z.string().url(),        // Vite (SPA separada)
});

export const config = envSchema.parse(process.env);
```

### Convenções por framework

| Framework | Público (embarcado no bundle) | Servidor |
|---|---|---|
| **Next.js** | `NEXT_PUBLIC_*` | Sem prefixo (server-only) |
| **Remix** | `PUBLIC_*` / `VITE_*` | Sem prefixo (loader/action) |
| **Vite SPA** | `VITE_*` | — (backend separado) |

### `.env.example`

Mantenha `.env.example` atualizado com todas as chaves, sem valores sensíveis:

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

# Client (Vite — se SPA separada)
# VITE_API_URL=
# VITE_APP_TITLE=
```

**Nunca** coloque segredo em variáveis públicas (`NEXT_PUBLIC_*`, `VITE_*`).  
**Nunca** commite `.env` real.

---

## Build

### Next.js — fullstack (frontend + servidor)

```bash
npx next build    # Produz .next/ (frontend + server bundle)
npx next start    # Inicia servidor Node.js com a app
```

### Remix — fullstack

```bash
npx remix build   # Produz build/ (client + server)
npx remix start   # Inicia servidor Node.js
```

### SPA separada + backend separado

```bash
# Frontend (Vite)
npx vite build    # Produz dist/

# Backend
npm run build     # tsc → dist/
npm run start     # node dist/index.js
```

### Configuração de build — Vite

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    outDir: 'dist',
    sourcemap: true, // para debug, NÃO servir publicamente
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

### Fullstack — imagem única (recomendado para Next.js/Remix)

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
COPY --from=builder /app/.next ./.next           # ou /app/build para Remix
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/public ./public
USER node
EXPOSE 3000
CMD ["node_modules/.bin/next", "start"]           # ou remix start
```

### Separado — frontend (nginx) + backend (Node)

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

## CDN e Cache

### Assets estáticos

- Arquivos em `assets/` são versionados pelo hash no nome (automático pelo framework).
- Cache longo para assets com hash (1 ano é seguro).
- HTML e entrypoint precisam permitir atualização rápida (cache curto ou no-cache).

### Nginx — configuração de cache

```nginx
# Assets com hash — cache agressivo
location /assets/ {
  expires 1y;
  add_header Cache-Control "public, immutable";
}

# HTML — sem cache
location / {
  try_files $uri $uri/ /index.html;
  add_header Cache-Control "no-cache, no-store, must-revalidate";
}
```

### Contrato frontend/backend

Ao alterar contrato de API:

1. Comunique breaking changes entre as equipes.
2. Se possível, versione a API (`/v2/users`).
3. Cache antigo no client pode mostrar dados desatualizados — considere invalidação.

---

## Hosting

### Vercel / Gerenciado (Next.js)

```bash
npm i -g vercel
vercel           # Deploy preview
vercel --prod    # Deploy produção
```

Configurações:

- Variáveis de ambiente em Settings → Environment Variables.
- Preview deploy automático por branch.
- Domínio customizado em Settings → Domains.

### VPS / Self-hosted com systemd

```ini
# /etc/systemd/system/app.service
[Unit]
Description=App Fullstack
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
3. **Deploy/restart** — imagem Docker ou `sudo systemctl restart app`
4. **Healthcheck** — `curl -f http://localhost:3000/api/health`
5. **Monitorar** — acompanhe logs e métricas por 15 minutos

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

## Compressão

Habilite gzip ou brotli no servidor web:

```nginx
# Nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml;
gzip_min_length 1024;
```

Para Vite, gere assets pré-comprimidos:

```typescript
// vite.config.ts
import viteCompression from 'vite-plugin-compression';

export default defineConfig({
  plugins: [viteCompression({ algorithm: 'brotliCompress' })],
});
```

---

## Headers de segurança — nível hosting/nginx

> Para headers de middleware/aplicação, consulte `SECURITY_GUIDE.md`.

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';" always;
```

### SPA Fallback (apenas SPA sem SSR)

```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

**Importante:** Não aplique fallback SPA em apps Next.js/Remix com SSR — o framework gerencia rotas no servidor.

---

## Rollback

Plano de rollback deve cobrir:

1. **Build anterior acessível** — mantenha artefato ou imagem Docker da versão anterior.
2. **Rollback de env** — se mudou variável de ambiente, reverta junto.
3. **Migration** — `npx prisma migrate resolve --rolled-back <migration>` se necessário.
4. **API contract** — garanta que versão anterior funciona com dados migrados.
5. **Cache do client** — usuários com versão antiga em cache podem ter comportamento inconsistente.

```bash
# Docker rollback
docker tag app:latest app:backup
docker build -t app:latest .
# Se der problema:
docker stop app-container
docker run -d --name app-container -p 3000:3000 app:backup
```

---

## Anti-patterns

- **Segredo em `NEXT_PUBLIC_*` ou `VITE_*`:** variáveis públicas são embarcadas no bundle e visíveis no browser.
- **`.env` commitado:** sempre adicione ao `.gitignore`.
- **`NODE_ENV=development` em produção:** muda comportamento de frameworks, erros e performance.
- **Sem sourcemap em produção:** dificulta debug. Gere, mas não sirva publicamente.
- **Cache agressivo em HTML:** impede atualização. Reserve cache longo para assets com hash.
- **Deploy sem build check:** rode `npm run build` + `npm run lint` + `npx tsc --noEmit` antes de deploy.
- **Fallback SPA em app com SSR:** quebra rotas server-rendered.
- **Deploy sem migration com downgrade:** toda migration precisa de caminho de rollback documentado.
- **Servir sem HTTPS:** nunca em produção.
- **Hardcodar env vars:** use sempre variáveis de ambiente.
- **Sem rollback planejado:** todo deploy deve ter forma de voltar.
