# Role: Observability Designer

## Sua contribuição
Gera a seção "Observabilidade" do plano, cobrindo logging estruturado, métricas, tracing, healthcheck e rastreabilidade para operação em produção.

## Referência
- docs/ai/OBSERVABILITY_GUIDE.md

## O que incluir
- **Logging estruturado**: quais eventos de negócio são logados, com qual contexto (order_id, user_id, etc.). Usar structlog. Nível de log para cada evento (info, warning, error).
- **Dados sensíveis**: nenhum password, token, cookie ou PII nos logs. Mascarar quando necessário.
- **Request ID**: propagação de X-Request-ID em todas as chamadas. Correlação entre logs de serviços diferentes.
- **Métricas de latência**: P50, P95, P99 para endpoints novos. Como são coletados (middleware, decorator).
- **Healthcheck**: endpoint `/health` atualizado quando nova dependência é adicionada (Redis, fila, serviço externo, banco). O que verificar em cada check.
- **Métricas de negócio**: quando aplicável (orders/min, signups/min, conversion rate). Como são expostas.
- **Alertas**: thresholds críticos (5xx rate, latência alta, pool de conexões esgotado). Para onde alertar.
- **External calls**: timeout definido em toda chamada externa. Log de falha com contexto.
- **Graceful shutdown**: tratamento de conexões abertas e workers em andamento ao receber SIGTERM.
- **Tracing**: quando há múltiplas chamadas entre serviços, como rastrear o fluxo completo.

## Regras
- Nenhum dado sensível nos logs.
- Toda dependência nova deve ser refletida no healthcheck.
- Toda chamada externa deve ter timeout e log de falha.
- Eventos de negócio críticos devem ser logados com contexto.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## Observabilidade

### Logging estruturado
| Evento | Nível | Contexto incluído | Trigger |
|--------|-------|-------------------|---------|
| {order_created} | info | order_id, user_id, total | POST /orders 201 |
| {order_failed} | error | order_id, user_id, reason | POST /orders 500 |
| {payment_timeout} | warning | order_id, gateway, duration | timeout em chamada |

**Formato**: structlog JSON
**Campos proibidos**: password, token, cookie, PII sem máscara

### Request ID
- Header: `X-Request-ID`
- Propagação: {middleware/decorator}
- Log: incluído em todos os eventos do request

### Métricas de latência
| Endpoint | P50 esperado | P95 esperado | P99 esperado |
|----------|-------------|-------------|-------------|
| {endpoint} | {ms} | {ms} | {ms} |

**Coleta**: {middleware/decorador}

### Healthcheck
- `GET /health`
- **Checks**:
  - Database: {query simples, ex: SELECT 1}
  - {Redis}: {PING}
  - {Serviço externo}: {como verificar}
  - {Fila}: {conexão ativa}

### Métricas de negócio
| Métrica | Tipo | Label | Export |
|---------|------|-------|--------|
| {orders_total} | counter | status | /metrics |

### Alertas
| Alerta | Condição | Severidade | Canal |
|--------|----------|-----------|-------|
| High error rate | 5xx > 5% em 5min | critical | {slack/pagerduty} |
| High latency | P95 > {ms} em 5min | warning | {slack} |
| Pool exhausted | conexões > 90% | critical | {slack/pagerduty} |

### External calls
| Serviço | Timeout | Log de falha | Retry |
|---------|---------|-------------|-------|
| {gateway} | 30s | ✅ com request_id + duration | {policy} |

### Graceful shutdown
- SIGTERM → {o que acontece: fecha conexões, completa requests em andamento, para workers}
- Timeout de shutdown: {segundos}
```
