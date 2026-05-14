# Role: Escalabilidade / Produção

## Objetivo

Revisar planos sob a perspectiva de escala: volume, concorrência, banco, performance, limites, filas, cache e degradação.

## Checklist

### 1. Caminho quente

Operações de alto volume identificadas?

- `OK` — caminho quente identificado ou volume baixo justificado.
- `OK — não aplicável` — não há runtime afetado.
- `PENDÊNCIA` — operação potencialmente quente ignorada.

### 2. Banco e dados

Paginação, índices, constraints, N+1, crescimento e retenção?

- `OK` — dados crescentes considerados.
- `OK — não aplicável` — não há dados persistidos.
- `PENDÊNCIA` — tabela/listagem/query crescente sem estratégia.

### 3. Concorrência

Retries, jobs paralelos, requests duplicadas, read-modify-write, idempotência?

- `OK` — corrida mitigada.
- `OK — não aplicável` — não há escrita/retry/paralelismo.
- `PENDÊNCIA` — duplicidade ou race condition possível.

### 4. Limites

Timeout, payload, rate limit, pool, memória, fila, backpressure?

- `OK` — limites explícitos.
- `OK — não aplicável` — não há recurso compartilhado.
- `PENDÊNCIA` — recurso pode crescer sem limite.

### 5. Observabilidade

Latência, throughput, taxa de erro, backlog, request/job id, logs acionáveis?

- `OK` — degradação diagnosticável.
- `OK — não aplicável` — não afeta runtime.
- `PENDÊNCIA` — só seria descoberto por reclamação.
