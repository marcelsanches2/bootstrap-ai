# Role: Escala

## Sua contribuição
Gera a seção "Escala" do plano, definindo estratégias de concorrência, filas, cache, pool, limites e validação de carga para suportar produção real.

## Referência
- docs/ai/SCALABILITY_GUIDE.md
- docs/ai/DATABASE_GUIDE.md
- docs/ai/OBSERVABILITY_GUIDE.md

## O que incluir
- **Volume e caminho quente**: identifique endpoints, jobs, queries ou telas que podem receber alto volume. Justifique quando não se aplica.
- **Banco e queries**: paginação, filtros, ordenação, N+1, índices, constraints e custo de queries críticas conforme volume esperado.
- **Concorrência e idempotência**: read-modify-write, retries, webhooks, jobs paralelos, criação duplicada, saldo/estoque/crédito. Mitigação por transação, constraint, lock ou idempotency key.
- **Limites e backpressure**: payload máximo, paginação, rate limit, pool de conexões, timeouts, fila, workers e consumo de memória. Sem consumo ilimitado de recurso.
- **Cache e invalidação**: chave, TTL, escopo, invalidação, stale data e métricas. Cache sem invalidação é débito técnico.
- **Filas e jobs**: idempotência, retry/backoff, dead-letter, concorrência máxima, backlog e logging por job id.
- **Integrações externas**: timeout, retry seguro, degradação, circuit breaker, métrica e teste de falha.
- **Observabilidade de escala**: latência p95/p99, taxa de erro, throughput, pool/conexões, backlog e logs com request/job id.
- **Validação de performance/carga**: teste concorrente, teste de query com volume, benchmark ou smoke de carga proporcional ao risco.

## Regras
- Corrupção de dados por concorrência é bloqueante.
- Duplicidade financeira/operacional é bloqueante.
- Incidente sem rollback claro é bloqueante.
- Consumo ilimitado de recurso (CPU, memória, conexão, fila, rede) é bloqueante.
- Não buscar overengineering — só tratar falhas previsíveis de produção.
- Se a mudança é pequena e sem risco de escala: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Escala

### Volume e caminho quente
| Operação | Volume esperado | Estratégia |
|---|---|---|
| {endpoint/job/query} | {estimativa} | {otimização} |

### Banco e queries
| Query | Risco | Índice | Paginação |
|---|---|---|---|
| {operação} | {N+1/full scan/...} | {criado/existente} | {skip/limit} |

### Concorrência e idempotência
| Operação | Risco | Mitigação |
|---|---|---|
| {read-modify-write/retry/webhook} | {duplicidade/inconsistência} | {transaction/lock/constraint/idempotency key} |

### Limites e backpressure
| Recurso | Limite | Configuração |
|---|---|---|
| {payload/paginação/rate limit/pool/timeout/fila/workers/memória} | {valor} | {onde configura} |

### Cache
| Dado | Chave | TTL | Invaliação | Escopo |
|---|---|---|---|---|
| {dado cacheado} | {formato da chave} | {tempo} | {evento/timeout} | {global/user/tenant} |

### Filas e jobs
| Job | Idempotência | Retry | Dead-letter | Concorrência máx |
|---|---|---|---|---|
| {nome} | {como garante} | {tentativas + backoff} | {sim/não} | {workers} |

### Integrações externas
| Serviço | Timeout | Retry | Circuit breaker | Degradação |
|---|---|---|---|---|
| {nome} | {ms} | {tentativas} | {sim/não} | {fallback} |

### Observabilidade de escala
| Métrica | Threshold | Alerta |
|---|---|---|
| {p95/throughput/error rate/pool/backlog} | {valor} | {quando dispara} |

### Validação de performance
| Teste | Ferramenta | Volume | Critério de aprovação |
|---|---|---|---|
| {tipo} | {k6/artillery/manual} | {RPS/conexões} | {p95 < Xms / 0 errors} |
```
