# Role: Observability Engineer

## Your contribution
Generates the "Observability" section of the plan, defining structured logs, metrics, tracing, healthcheck, and graceful shutdown.

## Reference
- docs/ai/OBSERVABILITY_GUIDE.md

## What to include
- **Structured logs**: business events logged with pino (or equivalent) in JSON format. Include relevant context (orderId, userId, requestId).
- **Errors with context**: every error logged with sufficient information for diagnosis (stack trace, parameters, entity id).
- **No sensitive data in logs**: password, token, Authorization header, cookie, PII — masked or omitted.
- **Propagated Request ID**: `X-Request-ID` generated at entry and propagated throughout the chain (logs, external calls).
- **Latency**: monitored on new endpoints. Define acceptable p95/p99 when relevant.
- **Healthcheck**: `/health` endpoint updated with new dependencies. Each dependency verified (DB, Redis, queue, external service).
- **Business metrics**: when applicable, define metrics that matter for business (e.g., orders/minute, processing time).
- **External calls**: configured timeout and failure logging with context.
- **Graceful shutdown**: SIGTERM/SIGINT handled — close server, drain connections, complete in-progress jobs.

## Rules
- Sensitive data in log is a BLOCKER.
- Missing healthcheck with new dependency is a BLOCKER.
- Every external call needs a timeout.
- If it doesn't apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## Observability

### Structured logs
| Event | Mandatory fields | Level |
|-------|-----------------|-------|
| {event} | {requestId, userId, ...} | info/warn/error |

### Errors
- Format: `{ error, message, stack, requestId, {entity}Id }`
- No sensitive data in log.

### Request ID
- Header: `X-Request-ID`
- Generation: {middleware/tool}
- Propagation: {logs, external calls, async context}

### Latency
| Endpoint | Acceptable p95 | Acceptable p99 |
|----------|---------------|---------------|
| {path} | {ms} | {ms} |

### Healthcheck
```
GET /health
Response 200:
{
  status: "ok",
  checks: {
    database: "ok",
    {dependency}: "ok"
  }
}
```

### Business metrics
| Metric | Type | Source |
|--------|------|--------|
| {metric} | {counter/gauge/histogram} | {where to collect} |

### External calls
| Service | Timeout | Failure log |
|---------|---------|-------------|
| {service} | {ms} | {logged fields} |

### Graceful shutdown
1. Receive SIGTERM/SIGINT
2. Stop accepting new connections
3. Complete in-progress requests (deadline: {ms})
4. Close connection pool
5. Log: "shutdown complete"
```
