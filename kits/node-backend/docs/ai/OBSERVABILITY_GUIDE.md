# Observability Guide

Logs, métricas e healthcheck para Node.js backend.

## Structured logging

```typescript
import pino from 'pino';
const logger = pino({ level: config.LOG_LEVEL || 'info' });

logger.info({ userId: user.id }, 'user_created');
logger.error({ orderId: order.id, err: err.message }, 'payment_failed');
logger.warn({ duration: elapsed, query }, 'slow_query');
```

## Request ID

```typescript
import { v4 as uuidv4 } from 'uuid';

app.use((req, res, next) => {
  req.id = req.headers['x-request-id']?.toString() || uuidv4();
  res.setHeader('X-Request-ID', req.id);
  next();
});
```

## Healthcheck

```typescript
app.get('/health', async (req, res) => {
  const checks: Record<string, string> = {};

  try {
    await prisma.$queryRaw`SELECT 1`;
    checks.database = 'ok';
  } catch (e) {
    checks.database = 'error';
  }

  const status = Object.values(checks).every(v => v === 'ok') ? 200 : 503;
  res.status(status).json({ status: status === 200 ? 'ok' : 'degraded', checks });
});
```

## Métricas

```typescript
import { Counter, Histogram, register } from 'prom-client';

const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'path', 'status'],
});

const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Request duration',
  labelNames: ['method', 'path'],
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

## Alertas

| Métrica | Warning | Critical |
|---|---|---|
| 5xx rate | > 1% | > 5% |
| P99 latência | > 2s | > 5s |
| DB connections | > 70% | > 90% |
| Memory | > 80% | > 95% |

## Regras duras

- Nunca logar dados sensíveis.
- Sempre ter healthcheck.
- Sempre propagar request ID.
- Nunca usar `console.log` em produção.

---

## Observabilidade — checklist de produção

Este guia existe para orientar implementação real em `node-backend`. Ele deve ser usado por `/plan`, `/jarvis-plan-revisor`, `/refactor` e `/jarvis-test-flow` antes de qualquer mudança relevante.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **logs**: declarar regra, exceção permitida e evidência esperada.
- **métricas**: declarar regra, exceção permitida e evidência esperada.
- **traces**: declarar regra, exceção permitida e evidência esperada.
- **alertas**: declarar regra, exceção permitida e evidência esperada.
- **runbook**: declarar regra, exceção permitida e evidência esperada.

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
