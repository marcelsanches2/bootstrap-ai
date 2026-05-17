# Deploy React Web

## Build

Build production deve passar antes de entrega relevante.

### Vite

```bash
# Build de produção
npx vite build

# Preview local do build
npx vite preview

# Output padrão: dist/
```

Configuração típica `vite.config.ts`:

```ts
export default defineConfig({
  build: {
    outDir: 'dist',
    sourcemap: true, // para debug em produção, não para servir publicamente
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
# Build de produção
npx next build

# Start do servidor
npx next start

# Output padrão: .next/
```

Variáveis de ambiente em Next.js:

- `NEXT_PUBLIC_*` — expostas no client (embarcadas no bundle).
- Sem prefixo — disponíveis apenas em server components / API routes.

**Nunca** coloque segredo em variáveis `NEXT_PUBLIC_*`.

---

## Variáveis de ambiente

- `.env` real fora do git (adicionar ao `.gitignore`).
- `.env.example` com todas as chaves necessárias, sem valores sensíveis.
- Feature flags e URLs de API documentadas no README ou em `docs/ai/`.

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

### Validação de env com Zod

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

## Cache e CDN

### Assets estáticos

- Arquivos em `assets/` são versionados pelo hash no nome (Vite/Next.js fazem automaticamente).
- Cache longo para assets com hash (1 ano é seguro).
- HTML e entrypoint precisam permitir atualização rápida (cache curto ou no-cache).

### Configuração Nginx

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

### Mudança de contrato frontend/backend

Ao alterar contrato de API:

1. Comunique o backend sobre breaking changes.
2. Se possível, versione a API (`/v2/users`).
3. Cache antigo no client pode mostrar dados desatualizados — considere invalidação.

---

## Headers de segurança

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
# Instalar Vercel CLI
npm i -g vercel

# Deploy preview
vercel

# Deploy produção
vercel --prod
```

Configurações importantes:

- Variáveis de ambiente em Settings → Environment Variables.
- Preview deploy automático por branch.
- Domínio customizado em Settings → Domains.

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
# Build e run
docker build -t react-app .
docker run -p 8080:80 react-app
```

---

## SPA Fallback

Para SPA com React Router, configure o servidor para redirecionar rotas não-encontradas para `index.html`:

```nginx
# Nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

**Importante:** Não aplique fallback SPA em apps Next.js com SSR — o Next.js gerencia rotas no servidor.

---

## Rollback

Plano de rollback deve cobrir:

1. **Build anterior acessível:** mantenha artefato ou imagem Docker da versão anterior.
2. **Rollback de env:** se mudou variável de ambiente, reverta junto.
3. **Contrato de API:** se mudou contrato, garanta que versão anterior funciona com backend atual.
4. **Cache do client:** usuários com versão antiga em cache podem ter comportamento inconsistente.

```bash
# Docker rollback
docker tag react-app:latest react-app:backup
docker build -t react-app:latest .
# Se der problema:
docker stop react-app-container
docker run -d --name react-app-container -p 8080:80 react-app:backup
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

```ts
// vite.config.ts
import viteCompression from 'vite-plugin-compression';

export default defineConfig({
  plugins: [viteCompression({ algorithm: 'brotliCompress' })],
});
```

---

## Anti-patterns

- **Segredo em `NEXT_PUBLIC_*` ou `VITE_*`:** variáveis públicas são embarcadas no bundle e visíveis no browser.
- **`.env` commitado:** sempre adicione ao `.gitignore`.
- **Sem sourcemap em produção:** dificulta debug de erros em produção. Gere, mas não sirva publicamente.
- **Cache agressivo em HTML:** impede atualização rápida. Reserve cache longo para assets com hash.
- **Deploy sem build check:** rode `npm run build` (e `npm run lint` + `npx tsc --noEmit`) antes de deploy.
- **Fallback SPA em app com SSR:** quebra rotas server-rendered.
- **Sem rollback planejado:** todo deploy deve ter forma de voltar.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

### Segurança
- **Nunca colocar segredo em `NEXT_PUBLIC_*` ou `VITE_*`**: variáveis públicas são embarcadas no bundle e visíveis no browser.
- **Nunca commitar `.env` real**: `.env` deve estar no `.gitignore`; só commitar `.env.example` sem valores sensíveis.
- **Headers de segurança obrigatórios**: X-Frame-Options, X-Content-Type-Options, Referrer-Policy devem estar configurados.

### Build e deploy
- **Build production deve passar antes de entrega relevante**: rode `npm run build` (e `npm run lint` + `npx tsc --noEmit`) antes de deploy.
- **Todo deploy deve ter rollback planejado**: manter artefato/imagem da versão anterior acessível.
- **Não aplicar fallback SPA em app Next.js com SSR**: quebra rotas server-rendered.

### Cache e env
- **Cache agressivo só para assets com hash**: HTML e entrypoint devem ter cache curto ou no-cache.
- **Sourcemap em produção deve ser gerado, mas não servido publicamente**: dificulta debug se ausente.
- **`.env.example` deve ter todas as chaves necessárias**: sem valores sensíveis, documentando cada variável.
