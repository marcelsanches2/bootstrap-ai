# Observability Guide

Logs, metrics, and healthcheck for Node.js backend.

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

## Metrics

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

## Alerts

| Metric | Warning | Critical |
|---|---|---|
| 5xx rate | > 1% | > 5% |
| P99 latency | > 2s | > 5s |
| DB connections | > 70% | > 90% |
| Memory | > 80% | > 95% |

## Hard rules

- Never log sensitive data.
- Always have a healthcheck.
- Always propagate request ID.
- Never use `console.log` in production.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any of the rules below.

- **Never log sensitive data**: Passwords, tokens, PII must never appear in logs.
- **Always have a healthcheck**: `/health` endpoint verifying critical dependencies.
- **Always propagate request ID**: Every request must have a traceable ID end-to-end.
- **Never use `console.log` in production**: Use structured logger (pino).
