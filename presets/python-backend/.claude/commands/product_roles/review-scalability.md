# Role: Scalability Designer

## Sua contribuição
Gera a seção "Escala" do plano, cobrindo concorrência, filas, cache, pool de conexões e comportamento sob carga.

## Referência
- docs/ai/SCALABILITY_GUIDE.md
- docs/ai/DATABASE_GUIDE.md
- docs/ai/OBSERVABILITY_GUIDE.md
- docs/ai/DEPLOYMENT_GUIDE.md

## O que incluir
- **Volume e caminho quente**: identifique endpoints, jobs, queries que podem receber alto volume. Estimativa de RPS/throughput. Justifique se o volume é baixo.
- **Banco e queries**: estratégia para queries em tabelas crescentes — paginação (offset para <1M, cursor para >1M), índices, N+1, filtros, ordenação. Custo de queries críticas.
- **Concorrência e idempotência**: onde há read-modify-write, retries, webhooks, jobs paralelos, criação duplicada. Como mitigar: transação, constraint, lock pessimista (`with_for_update`), idempotency key.
- **Limites e backpressure**: payload máximo, paginação com limites, rate limit, pool de conexões (tamanho, timeout), timeout em queries, fila com tamanho máximo, consumo de memória por request.
- **Cache e invalidação**: se houver cache, defina chave, TTL, escopo (por usuário/tenant/global), estratégia de invalidação, stale data handling, métricas de hit/miss.
- **Filas e jobs**: idempotência do job, retry/backoff policy, dead-letter queue, concorrência máxima de workers, backlog monitoring, logging por job_id.
- **Integrações externas**: timeout, retry seguro (não duplicar efeito), degradação graceful, circuit breaker quando necessário, métricas de latência e erro, teste de falha.
- **Observabilidade de escala**: latência P95/P99, taxa de erro, throughput, pool/conexões, backlog de filas — tudo com request/job ID para diagnóstico.
- **Validação de performance**: teste concorrente, teste de query com volume, benchmark ou smoke test de carga quando a feature é crítica.

## Regras
- Toda tabela crescente precisa de estratégia de paginação.
- Saldo/estoque/crédito precisam de lock pessimista ou constraint transacional.
- Toda chamada externa precisa de timeout e retry seguro.
- Todo pool de conexões precisa de tamanho e timeout definidos.
- Cache proposto sem invalidação não é aceitável.
- Job que pode duplicar efeito precisa de idempotência.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## Escala

### Volume e caminho quente
| Endpoint/Job | RPS estimado | Caminho quente? | Justificativa |
|-------------|-------------|----------------|---------------|
| {endpoint} | {n} | sim/não | {motivo} |

### Banco e queries
| Query | Tabela (crescimento) | Estratégia | Índices |
|-------|---------------------|------------|---------|
| {listagem X} | {tabela} (~{n}/mês) | paginação offset/cursor | {índices necessários} |

### Concorrência e idempotência
| Operação | Risco | Mitigação |
|----------|-------|-----------|
| {operação} | {read-modify-write / retry duplicado} | {lock / constraint / idempotency key} |

### Limites e backpressure
| Recurso | Limite | Configuração |
|---------|--------|-------------|
| Pool de conexões | {max_connections} | `pool_size={n}, max_overflow={n}` |
| Query timeout | {ms} | `statement_timeout` |
| Payload máximo | {KB/MB} | {middleware/nginx} |
| Paginação | limit max {n} | validação no schema |
| Rate limit | {n}/{período} | {middleware/redis} |
| Fila backlog | {max_size} | {configuração} |

### Cache
| Dado | Chave | TTL | Escopo | Invaliação |
|------|-------|-----|--------|-----------|
| {dado} | `{template}` | {segundos} | {global/user} | {evento/timeout} |

{Se não houver cache: "Nenhum cache necessário para esta feature — justificativa: ..."}

### Filas e jobs
| Job | Idempotência | Retry | Backoff | Dead-letter | Concorrência máx |
|-----|-------------|-------|---------|-------------|-----------------|
| {job} | {chave} | {max retries} | {expo/random} | {queue} | {workers} |

{Se não houver jobs: "Nenhum processamento assíncrono necessário para esta feature."}

### Integrações externas
| Serviço | Timeout | Retry | Circuit breaker | Métricas | Teste de falha |
|---------|---------|-------|-----------------|----------|---------------|
| {serviço} | {ms} | {policy} | {sim/não} | latência, erro | {descrição} |

### Observabilidade de escala
| Métrica | Threshold de alerta | Como diagnosticar |
|---------|-------------------|-------------------|
| Latência P95 | > {ms} | {log + métrica} |
| Taxa de erro 5xx | > {n}% | {log + métrica} |
| Pool esgotado | > {n}% uso | {métrica de pool} |
| Backlog de fila | > {n} mensagens | {métrica de fila} |

### Validação de performance
- **Teste**: {tipo — concorrente / query com volume / benchmark / smoke de carga}
- **Cenário**: {descrição do teste}
- **Critério de sucesso**: {resultado esperado}
{Se não for necessário: "Feature não tem risco de escala — justificativa: ..."}
```
