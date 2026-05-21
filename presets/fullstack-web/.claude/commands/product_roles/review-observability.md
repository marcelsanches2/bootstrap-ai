# Role: Observability

## Your contribution
Generates the "Observability" section of the plan, defining structured logging, metrics, healthcheck, tracing, and traceability.

## Reference
- docs/ai/OBSERVABILITY_GUIDE.md

## What to include
- **Structured logging**: business events logged with pino structured logging. Errors logged with context (orderId, userId, requestId). No sensitive data in logs.
- **Request ID**: propagated across the entire chain (X-Request-ID). Correlation between frontend and backend.
- **Healthcheck**: updated with new dependencies. `/health` endpoint reflects real status.
- **Business metrics**: when applicable, metrics that matter to the domain (conversion, latency, error rate).
- **Latency**: monitored on new endpoints. Alert on degradation.
- **External calls**: with timeout and failure logging. Explicit timeout, retry with backoff, circuit breaker when needed.
- **Graceful shutdown**: handled to not lose in-transit data.

## Rules
- Sensitive data in logs is blocking.
- Missing healthcheck with new dependency is blocking.
- External call without timeout is a pending item.
- No sensitive data in logs (token, password, Authorization header, cookie, PII without masking).
- If the task does not affect runtime/observability: write "Does not apply" and explain why.

## Output format

```md
## Observability

### Structured logging
| Event | Fields | Level | File |
|---|---|---|---|
| {business event} | {orderId, userId, ...} | {info/warn/error} | {where it logs} |

### Request ID
{how it is generated, propagated, and correlated}

### Healthcheck
| Dependency | Check | Timeout |
|---|---|---|
| {service/database} | {query/ping/tcp} | {ms} |

### Metrics
| Metric | Type | Dimensions | Alert |
|---|---|---|---|
| {name} | {counter/histogram/gauge} | {labels} | {when it fires} |

### Latency
| Endpoint | Expected P95 | Expected P99 | How to measure |
|---|---|---|---|
| {VERB /path} | {ms} | {ms} | {tool} |

### External calls
| Service | Timeout | Retry | Circuit breaker | Failure log |
|---|---|---|---|---|
| {name} | {ms} | {attempts + backoff} | {yes/no} | {fields} |

### Graceful shutdown
{how SIGTERM/SIGINT signals are handled}
```
