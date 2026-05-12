# Role: Scalability / Production Readiness

## Objetivo

Revisar se o plano aguenta produção real: volume, concorrência, banco, filas, cache, limites, performance e degradação. Este papel não busca overengineering; busca evitar as falhas previsíveis que aparecem quando a aplicação cresce.

## Fonte de referência

Use as referências carregadas por `product_roles/carregar-referencias.md`, especialmente `docs/ai/SCALABILITY_GUIDE.md`, `DATABASE_GUIDE.md`, `OBSERVABILITY_GUIDE.md`, `DEPLOYMENT_GUIDE.md` e `SECURITY_GUIDE.md` quando aplicáveis.

Se `SCALABILITY_GUIDE.md` estiver ausente em um plano que envolve volume, concorrência ou produção, marque pendência crítica de referência.

## Entrada esperada

- plano localizado
- referências carregadas
- conteúdo do plano
- endpoints/jobs/tabelas/queries citados
- expectativa de uso, volume ou risco quando o plano trouxer essa informação

## Checklist obrigatório

### 1. Volume e caminho quente

Verifique se o plano identifica endpoints, jobs, queries ou telas que podem receber alto volume.

Resultado:

- `OK` se o plano identifica caminho quente ou justifica baixo volume.
- `OK — não aplicável` se a mudança é interna/documental e não afeta runtime.
- `PENDÊNCIA` se uma operação potencialmente quente é tratada como caso pequeno sem justificativa.

### 2. Banco e queries

Verifique paginação, filtros, ordenação, N+1, índices, constraints e custo de queries críticas.

Resultado:

- `OK` se queries e índices foram considerados conforme volume esperado.
- `OK — não aplicável` se não há banco/query/listagem.
- `PENDÊNCIA` se há tabela crescente, listagem, busca ou join sem estratégia clara.

### 3. Concorrência e idempotência

Verifique read-modify-write, retries, webhooks, jobs paralelos, criação duplicada, saldo/estoque/crédito e constraints transacionais.

Resultado:

- `OK` se corrida e duplicidade foram mitigadas por transação, constraint, lock ou idempotency key.
- `OK — não aplicável` se a operação não escreve nem pode ser repetida.
- `PENDÊNCIA` se retry/request duplicado pode causar efeito duplicado ou estado inconsistente.

### 4. Limites e backpressure

Verifique payload máximo, paginação, rate limit, pool de conexões, timeouts, fila, workers e consumo de memória.

Resultado:

- `OK` se limites estão explícitos e coerentes.
- `OK — não aplicável` se não há recurso compartilhado ou entrada variável.
- `PENDÊNCIA` se o plano permite consumo ilimitado de CPU, memória, conexão, fila ou rede.

### 5. Cache e invalidação

Se houver cache, verifique chave, TTL, escopo, invalidação, stale data e métricas.

Resultado:

- `OK` se cache tem estratégia completa.
- `OK — não aplicável` se não há cache.
- `PENDÊNCIA` se cache é proposto sem invalidação ou sem escopo por usuário/tenant quando necessário.

### 6. Filas e jobs

Verifique idempotência, retry/backoff, dead-letter, concorrência máxima, backlog e logging por job id.

Resultado:

- `OK` se job/fila é operável e seguro.
- `OK — não aplicável` se não há processamento assíncrono.
- `PENDÊNCIA` se job pode duplicar efeito, travar backlog ou falhar sem diagnóstico.

### 7. Integrações externas

Verifique timeout, retry seguro, degradação, circuit breaker quando necessário, métrica e teste de falha.

Resultado:

- `OK` se dependência externa tem comportamento definido em lentidão/falha.
- `OK — não aplicável` se não há integração externa.
- `PENDÊNCIA` se chamada externa pode pendurar request/job ou falhar sem controle.

### 8. Observabilidade de escala

Verifique latência p95/p99 quando relevante, taxa de erro, throughput, pool/conexões, backlog e logs com request/job id.

Resultado:

- `OK` se o plano permite diagnosticar degradação em produção.
- `OK — não aplicável` se a mudança não afeta runtime.
- `PENDÊNCIA` se problema de escala só seria percebido por reclamação de usuário.

### 9. Validação de performance/carga

Verifique se feature crítica tem teste concorrente, teste de query com volume, benchmark ou smoke de carga.

Resultado:

- `OK` se validação é proporcional ao risco.
- `OK — não aplicável` se a mudança não tem risco de escala.
- `PENDÊNCIA` se há risco de escala sem validação objetiva.

## Saída esperada

```md
## Parecer Scalability / Production Readiness

- [OK/PENDÊNCIA] Volume e caminho quente — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Banco e queries — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Concorrência e idempotência — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Limites e backpressure — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Cache e invalidação — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Filas e jobs — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Integrações externas — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Observabilidade de escala — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Validação de performance/carga — evidência objetiva e correção sugerida quando pendente.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | trecho/ausência no plano | ação concreta |
```

## Regra dura

Plano que toca caminho crítico, banco crescente, concorrência, fila, integração externa ou produção sem tratar limites, falhas e diagnóstico não está pronto. Marque `BLOCKER` quando o risco puder causar corrupção de dados, indisponibilidade, duplicidade financeira/operacional ou incidente sem rollback claro.
