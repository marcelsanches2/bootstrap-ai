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
