# Role: Observabilidade

## Sua contribuição
Gera a seção "Observabilidade" do plano, definindo logging estruturado, métricas, healthcheck, tracing e rastreabilidade.

## Referência
- docs/ai/OBSERVABILITY_GUIDE.md

## O que incluir
- **Logging estruturado**: eventos de negócio logados com pino structured logging. Erros logados com contexto (orderId, userId, requestId). Nenhum dado sensível nos logs.
- **Request ID**: propagado em toda cadeia (X-Request-ID). Correlação entre frontend e backend.
- **Healthcheck**: atualizado com novas dependências. Endpoint `/health` reflete status real.
- **Métricas de negócio**: quando aplicável, métricas que importam para o domínio (conversion, latency, error rate).
- **Latência**: monitorada em endpoints novos. Alerta em degradação.
- **External calls**: com timeout e log de falha. Timeout explícito, retry com backoff, circuit breaker quando necessário.
- **Graceful shutdown**: tratado para não perder dados em trânsito.

## Regras
- Dado sensível em log é bloqueante.
- Healthcheck faltando com dependência nova é bloqueante.
- External call sem timeout é pendência.
- Nenhum dado sensível em log (token, senha, Authorization header, cookie, PII sem mascaramento).
- Se a task não afeta runtime/observabilidade: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Observabilidade

### Logging estruturado
| Evento | Campos | Nível | Arquivo |
|---|---|---|---|
| {evento de negócio} | {orderId, userId, ...} | {info/warn/error} | {onde loga} |

### Request ID
{como é gerado, propagado e correlacionado}

### Healthcheck
| Dependência | Verificação | Timeout |
|---|---|---|
| {serviço/banco} | {query/ping/tcp} | {ms} |

### Métricas
| Métrica | Tipo | Dimensões | Alerta |
|---|---|---|---|
| {nome} | {counter/histogram/gauge} | {labels} | {quando dispara} |

### Latência
| Endpoint | P95 esperado | P99 esperado | Como mede |
|---|---|---|---|
| {VERB /path} | {ms} | {ms} | {ferramenta} |

### External calls
| Serviço | Timeout | Retry | Circuit breaker | Log de falha |
|---|---|---|---|---|
| {nome} | {ms} | {tentativas + backoff} | {sim/não} | {campos} |

### Graceful shutdown
{como sinais SIGTERM/SIGINT são tratados}
```
