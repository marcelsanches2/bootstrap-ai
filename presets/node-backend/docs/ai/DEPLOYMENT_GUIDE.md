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

---

## Deploy e operação — checklist de produção

Este guia existe para orientar implementação real em `node-backend`. Ele deve ser usado por `/plan`, `/jarvis-plan-revisor`, `/refactor` e `/jarvis-test-flow` antes de qualquer mudança relevante.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **build**: declarar regra, exceção permitida e evidência esperada.
- **configuração**: declarar regra, exceção permitida e evidência esperada.
- **healthcheck**: declarar regra, exceção permitida e evidência esperada.
- **rollback**: declarar regra, exceção permitida e evidência esperada.
- **observabilidade**: declarar regra, exceção permitida e evidência esperada.

### Regras específicas para backend Node.js/TypeScript

- Use o runtime esperado: Node.js, TypeScript, Express/Fastify/Nest quando presentes, Prisma/Drizzle quando presentes.
- Não introduza framework paralelo sem justificar migração e custo de manutenção.
- Padronize validação na borda do sistema; dentro do domínio, trabalhe com tipos já confiáveis.
- Trate erro com categoria operacional: entrada inválida, regra de negócio, dependência externa, bug interno ou indisponibilidade.
- Centralize configuração por ambiente e mantenha secrets fora do repositório.
- Prefira funções pequenas com contrato claro a helpers genéricos difíceis de testar.
- Evite estado global mutável; quando inevitável, documente ciclo de vida e concorrência.
- Registre decisões que afetem deploy, segurança, dados ou compatibilidade em `plans/`.

### Validação mínima

Antes de considerar uma mudança pronta, execute ou justifique por que não executou:

```bash
npm run typecheck && npm test && npm run lint quando configurado
```

Além disso:

- [ ] Teste unitário cobre regra de negócio principal.
- [ ] Teste de integração cobre fronteira externa relevante.
- [ ] Caso de erro previsível tem teste ou simulação.
- [ ] Build/typecheck passa sem warnings novos relevantes.
- [ ] Documentação alterada quando contrato ou operação mudou.

### Revisão de risco

Classifique cada mudança antes de implementar:

- **Baixo risco**: arquivo isolado, sem contrato externo, sem estado persistente.
- **Médio risco**: altera fluxo, API interna, componente compartilhado ou configuração.
- **Alto risco**: altera schema, autenticação, autorização, pagamento, deploy, cache, fila, storage ou contrato público.

Para risco alto, o plano precisa conter:

- sequência de deploy;
- rollback;
- migração/backfill quando aplicável;
- métrica ou log para confirmar sucesso;
- teste de regressão;
- responsável por validar produção.

### Anti-patterns bloqueantes

- Capturar exceção genérica e continuar sem log estruturado.
- Criar abstração antes de existir segundo uso real.
- Misturar validação de entrada, regra de negócio e acesso externo no mesmo bloco.
- Depender de ordem implícita de execução sem teste.
- Adicionar dependência que só economiza poucas linhas de código trivial.
- Fazer mudança de schema sem rollback ou sem compatibilidade temporária.
- Usar dado real em teste automatizado.
- Commitar `.env`, token, dump, fixture sensível ou configuração local.

### Como o Jarvis deve usar este guia

Ao revisar um plano, o Jarvis deve produzir achados com:

```md
- Evidência: arquivo/seção do plano
- Violação: regra deste guia
- Impacto: risco concreto
- Correção: alteração objetiva
- Validação: comando ou teste esperado
```

Comentário sem evidência deve ser descartado.
