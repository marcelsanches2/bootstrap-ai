# Role: Escalabilidade / Produção

## Objetivo

Revisar qualquer plano técnico sob a perspectiva de escala em produção: volume, concorrência, banco, performance, limites, filas, cache, observabilidade e degradação.

Este papel é genérico. Kits backend devem preferir `product_roles/role-scalability.md`, que é mais específico.

## Entrada esperada

- plano localizado em `plans/`
- referências carregadas do kit
- endpoints/jobs/tabelas/queries/componentes citados
- expectativa de uso ou risco quando o plano trouxer essa informação

## Checklist obrigatório

### 1. Caminho quente

Verifique se operações de alto volume foram identificadas.

Resultado:

- `OK` se caminho quente foi identificado ou volume baixo foi justificado.
- `OK — não aplicável` se não há runtime afetado.
- `PENDÊNCIA` se operação potencialmente quente foi ignorada.

### 2. Banco e dados

Verifique paginação, índices, constraints, N+1, crescimento de tabela e retenção.

Resultado:

- `OK` se dados crescentes foram considerados.
- `OK — não aplicável` se não há banco/dados persistidos.
- `PENDÊNCIA` se tabela/listagem/query crescente não tem estratégia.

### 3. Concorrência

Verifique retries, jobs paralelos, requests duplicadas, read-modify-write e idempotência.

Resultado:

- `OK` se corrida foi mitigada.
- `OK — não aplicável` se não há escrita/retry/paralelismo.
- `PENDÊNCIA` se duplicidade ou race condition é possível.

### 4. Limites

Verifique timeout, payload, rate limit, pool, memória, fila e backpressure.

Resultado:

- `OK` se limites são explícitos.
- `OK — não aplicável` se não há recurso compartilhado.
- `PENDÊNCIA` se recurso pode crescer sem limite.

### 5. Observabilidade

Verifique latência, throughput, taxa de erro, backlog, request id/job id e logs acionáveis.

Resultado:

- `OK` se degradação seria diagnosticável.
- `OK — não aplicável` se não afeta runtime.
- `PENDÊNCIA` se só seria descoberto por reclamação.

## Saída esperada

```md
## Parecer Escalabilidade / Produção

- [OK/PENDÊNCIA] Caminho quente — evidência objetiva e correção sugerida.
- [OK/PENDÊNCIA] Banco e dados — evidência objetiva e correção sugerida.
- [OK/PENDÊNCIA] Concorrência — evidência objetiva e correção sugerida.
- [OK/PENDÊNCIA] Limites — evidência objetiva e correção sugerida.
- [OK/PENDÊNCIA] Observabilidade — evidência objetiva e correção sugerida.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | trecho/ausência no plano | ação concreta |
```

## Regra dura

Se o plano toca produção, banco crescente, concorrência, filas, cache ou integração externa e não fala de limites/falhas/diagnóstico, marque `PENDÊNCIA`.
