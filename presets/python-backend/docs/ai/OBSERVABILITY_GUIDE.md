# Observability Guide

Logs, métricas, healthcheck e tracing para Python backend.

## Structured logging

### Setup com structlog

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

### Uso

```python
# Eventos de negócio
logger.info("user_created", user_id=user.id, email=user.email)
logger.info("order_placed", order_id=order.id, total=order.total)

# Erros com contexto
logger.error("payment_failed", order_id=order.id, gateway_error=str(e))

# Warning para situações anômalas
logger.warning("slow_query", query=query_str, duration_ms=elapsed)

# Request logging via middleware
logger.info("request_completed", method=request.method, path=request.url.path,
            status=response.status_code, duration_ms=elapsed)
```

### Context vars

```python
# Middleware que adiciona request_id
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

Todos os logs da request terão `request_id` automaticamente.

## Métricas

### O que medir

- **Latência**: histograma de tempo de response por endpoint.
- **Throughput**: requests por segundo.
- **Erro rate**: % de 5xx por endpoint.
- **DB connections**: pool usage, wait time.
- **External calls**: latência e erro rate de serviços externos.
- **Business metrics**: orders/min, signups/min, revenue/min.

### Com Prometheus

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

    # External service (ex: Redis)
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

### Regra

- Healthcheck NÃO deve requerer autenticação.
- Deve ser leve (sem query pesada).
- Usado por load balancer e orchestrator.
- Retornar 503 se qualquer dependência crítica está down.

## Tracing

### Correlation IDs

Todo request recebe um `X-Request-ID`. Propagar para:

- Logs (via context vars).
- Chamadas externas (header).
- Responses (header).

### OpenTelemetry (opcional)

```python
from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

tracer = trace.get_tracer(__name__)

FastAPIInstrumentor.instrument_app(app)

# Span customizado
with tracer.start_as_current_span("process_payment") as span:
    span.set_attribute("order.id", order.id)
    span.set_attribute("order.total", str(order.total))
    await payment_service.process(order)
```

## Alertas

### Thresholds sugeridos

| Métrica | Warning | Critical |
|---|---|---|
| 5xx rate | > 1% | > 5% |
| P99 latência | > 2s | > 5s |
| DB pool usage | > 70% | > 90% |
| Memory usage | > 80% | > 95% |
| External error rate | > 5% | > 20% |
| Queue depth | > 1000 | > 5000 |

### Incident response

1. Alerta disparado.
2. Verificar logs com correlation ID.
3. Verificar métricas no dashboard.
4. Verificar deploy recente.
5. Se necessário: rollback.
6. Post-mortem em `docs/incidents/YYYY-MM-DD-<slug>.md`.

## Sinais de escala

Monitorar quando volume cresce:

- Queries ficando lentas (P99 subindo).
- Pool de conexões esgotando.
- Memory crescendo (possível leak).
- External calls acumulando timeout.
- Queue depth crescendo sem consumir.

## Regras duras

- Nunca logar dados sensíveis (senha, token, PII).
- Sempre ter healthcheck endpoint.
- Sempre propagar request_id.
- Sempre logar com structured logging.
- Nunca usar `print()` para logging.
- Sempre configurar alertas em produção.
