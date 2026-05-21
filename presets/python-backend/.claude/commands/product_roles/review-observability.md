# Role: Observability Designer

## Your contribution
Generates the "Observability" section of the plan, covering structured logging, metrics, tracing, healthcheck and traceability for production operations.

## Reference
- docs/ai/OBSERVABILITY_GUIDE.md

## What to include
- **Structured logging**: which business events are logged, with what context (order_id, user_id, etc.). Use structlog. Log level for each event (info, warning, error).
- **Sensitive data**: no password, token, cookie or PII in logs. Mask when necessary.
- **Request ID**: X-Request-ID propagation across all calls. Correlation between logs from different services.
- **Latency metrics**: P50, P95, P99 for new endpoints. How they are collected (middleware, decorator).
- **Healthcheck**: `/health` endpoint updated when a new dependency is added (Redis, queue, external service, database). What to verify in each check.
- **Business metrics**: when applicable (orders/min, signups/min, conversion rate). How they are exposed.
- **Alerts**: critical thresholds (5xx rate, high latency, exhausted connection pool). Where to alert.
- **External calls**: timeout defined on every external call. Failure log with context.
- **Graceful shutdown**: handling of open connections and in-progress workers on SIGTERM.
- **Tracing**: when there are multiple calls between services, how to trace the complete flow.

## Rules
- No sensitive data in logs.
- Every new dependency must be reflected in the healthcheck.
- Every external call must have timeout and failure log.
- Critical business events must be logged with context.
- If it does not apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## Observability

### Structured logging
| Event | Level | Included context | Trigger |
|-------|-------|-----------------|---------|
| {order_created} | info | order_id, user_id, total | POST /orders 201 |
| {order_failed} | error | order_id, user_id, reason | POST /orders 500 |
| {payment_timeout} | warning | order_id, gateway, duration | timeout on call |

**Format**: structlog JSON
**Prohibited fields**: password, token, cookie, unmasked PII

### Request ID
- Header: `X-Request-ID`
- Propagation: {middleware/decorator}
- Log: included in all events from the request

### Latency metrics
| Endpoint | Expected P50 | Expected P95 | Expected P99 |
|----------|-------------|-------------|-------------|
| {endpoint} | {ms} | {ms} | {ms} |

**Collection**: {middleware/decorator}

### Healthcheck
- `GET /health`
- **Checks**:
  - Database: {simple query, e.g.: SELECT 1}
  - {Redis}: {PING}
  - {External service}: {how to verify}
  - {Queue}: {active connection}

### Business metrics
| Metric | Type | Label | Export |
|--------|------|-------|--------|
| {orders_total} | counter | status | /metrics |

### Alerts
| Alert | Condition | Severity | Channel |
|-------|-----------|----------|---------|
| High error rate | 5xx > 5% in 5min | critical | {slack/pagerduty} |
| High latency | P95 > {ms} in 5min | warning | {slack} |
| Pool exhausted | connections > 90% | critical | {slack/pagerduty} |

### External calls
| Service | Timeout | Failure log | Retry |
|---------|---------|-------------|-------|
| {gateway} | 30s | ✅ with request_id + duration | {policy} |

### Graceful shutdown
- SIGTERM → {what happens: closes connections, completes in-progress requests, stops workers}
- Shutdown timeout: {seconds}
```
