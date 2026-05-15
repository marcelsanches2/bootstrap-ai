# review-observability

## Objetivo
Validar que o plano inclui logging estruturado, métricas, healthcheck e rastreabilidade suficientes para operar em produção.

## Fonte de referência
- `docs/ai/OBSERVABILITY_GUIDE.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar se cada fluxo novo ou alterado tem logging, métricas e healthcheck adequados.

## Checklist obrigatório

- [ ] Eventos de negócio logados com structured logging (structlog)
- [ ] Erros logados com contexto (order_id, user_id, etc.)
- [ ] Nenhum dado sensível nos logs (senha, token, PII)
- [ ] Request ID propagado em todas as chamadas (X-Request-ID)
- [ ] Latência monitorada em endpoints novos (P50, P95, P99)
- [ ] Healthcheck atualizado se nova dependência adicionada (Redis, fila, serviço externo)
- [ ] Métricas de negócio quando aplicável (orders/min, signups/min)
- [ ] Alertas configurados para thresholds críticos (5xx rate, latência, pool)
- [ ] External calls com timeout e log de falha
- [ ] Graceful shutdown tratado para conexões e workers

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + impacto operacional + correção.

### Severidade
- BLOCKER: dado sensível em log, healthcheck faltando com dependência nova.
- MAJOR: evento de negócio sem log, external call sem timeout.
- MINOR: métrica de negócio ausente.

## Saída em Markdown

```md
### review-observability

- [OK] Logging — service usa structlog com user_id e order_id. ✓
- [PENDÊNCIA MAJOR] External call sem timeout — gateway de pagamento.
  Correção: adicionar timeout=30 no httpx.AsyncClient e logar falhas.
...
```

## Regra dura
Plano que adiciona dependência sem healthcheck, ou loga dados sensíveis, ou faz external call sem timeout, não está pronto.
