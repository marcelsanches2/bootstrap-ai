# Observability Guide

Logs, metrics, healthcheck and tracing for Python backend.

## Structured logging

### Setup with structlog

```python
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer(),
    ],
)

logger = structlog.get_logger()
```

### Usage

```python
# Business events
logger.info("user_created", user_id=user.id, email=user.email)
logger.info("order_placed", order_id=order.id, total=order.total)

# Errors with context
logger.error("payment_failed", order_id=order.id, gateway_error=str(e))

# Warning for anomalous situations
logger.warning("slow_query", query=query_str, duration_ms=elapsed)

# Request logging via middleware
logger.info("request_completed", method=request.method, path=request.url.path,
            status=response.status_code, duration_ms=elapsed)
```

### Context vars

```python
# Middleware that adds request_id
import uuid
from starlette.middleware.base import BaseHTTPMiddleware

class RequestIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
        structlog.contextvars.clear_contextvars()
        structlog.contextvars.bind_contextvars(request_id=request_id)
        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        return response
```

All logs from the request will have `request_id` automatically.

## Metrics

### What to measure

- **Latency**: response time histogram per endpoint.
- **Throughput**: requests per second.
- **Error rate**: % of 5xx per endpoint.
- **DB connections**: pool usage, wait time.
- **External calls**: latency and error rate of external services.
- **Business metrics**: orders/min, signups/min, revenue/min.

### With Prometheus

```python
from prometheus_client import Counter, Histogram, generate_latest
from fastapi import Response

REQUEST_COUNT = Counter("http_requests_total", "Total requests", ["method", "path", "status"])
REQUEST_LATENCY = Histogram("http_request_duration_seconds", "Request latency", ["method", "path"])

@router.get("/metrics")
async def metrics():
    return Response(content=generate_latest(), media_type="text/plain")
```

## Healthcheck

### Endpoint

```python
@router.get("/health")
async def health(db: AsyncSession = Depends(get_db)):
    checks = {}

    # Database
    try:
        await db.execute(text("SELECT 1"))
        checks["database"] = "ok"
    except Exception as e:
        checks["database"] = f"error: {e}"

    # External service (e.g.: Redis)
    try:
        await redis.ping()
        checks["redis"] = "ok"
    except Exception as e:
        checks["redis"] = f"error: {e}"

    all_ok = all(v == "ok" for v in checks.values())
    status_code = 200 if all_ok else 503

    return JSONResponse(
        status_code=status_code,
        content={"status": "ok" if all_ok else "degraded", "checks": checks},
    )
```

### Rule

- Healthcheck must NOT require authentication.
- Must be lightweight (no heavy query).
- Used by load balancer and orchestrator.
- Return 503 if any critical dependency is down.

## Tracing

### Correlation IDs

Every request receives an `X-Request-ID`. Propagate to:

- Logs (via context vars).
- External calls (header).
- Responses (header).

### OpenTelemetry (optional)

```python
from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

tracer = trace.get_tracer(__name__)

FastAPIInstrumentor.instrument_app(app)

# Custom span
with tracer.start_as_current_span("process_payment") as span:
    span.set_attribute("order.id", order.id)
    span.set_attribute("order.total", str(order.total))
    await payment_service.process(order)
```

## Alerts

### Suggested thresholds

| Metric | Warning | Critical |
|---|---|---|
| 5xx rate | > 1% | > 5% |
| P99 latency | > 2s | > 5s |
| DB pool usage | > 70% | > 90% |
| Memory usage | > 80% | > 95% |
| External error rate | > 5% | > 20% |
| Queue depth | > 1000 | > 5000 |

### Incident response

1. Alert triggered.
2. Check logs with correlation ID.
3. Check metrics on dashboard.
4. Check recent deploy.
5. If necessary: rollback.
6. Post-mortem in `docs/incidents/YYYY-MM-DD-<slug>.md`.

## Scale signals

Monitor as volume grows:

- Queries getting slow (P99 rising).
- Connection pool exhausting.
- Memory growing (possible leak).
- External calls accumulating timeouts.
- Queue depth growing without consuming.

## Hard rules

- Never log sensitive data (password, token, PII).
- Always have healthcheck endpoint.
- Always propagate request_id.
- Always log with structured logging.
- Never use `print()` for logging.
- Always configure alerts in production.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Do not log sensitive data**: Never log password, token, PII without masking.
- **Mandatory healthcheck**: Always have a functional `/health` endpoint.
- **Mandatory request ID**: Always propagate `X-Request-ID` in logs, external calls and responses.
- **Structured logging**: Always use structlog (JSON), never `print()`.
- **Alerts in production**: Always configure alerts for critical metrics in production.
- **Healthcheck without auth**: Healthcheck must not require authentication.
- **503 on dependency down**: Return 503 if any critical dependency is down.
