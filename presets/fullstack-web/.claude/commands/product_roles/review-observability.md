# review-observability

## Objetivo
Validar logging, métricas, healthcheck e rastreabilidade.

## Fonte de referência
- docs/ai/OBSERVABILITY_GUIDE.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Eventos de negócio logados com pino structured logging\n- [ ] Erros logados com contexto (orderId, userId)\n- [ ] Nenhum dado sensível nos logs\n- [ ] Request ID propagado (X-Request-ID)\n- [ ] Latência monitorada em endpoints novos\n- [ ] Healthcheck atualizado com novas dependências\n- [ ] Métricas de negócio quando aplicável\n- [ ] External calls com timeout e log de falha\n- [ ] Graceful shutdown tratado

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção.

### Severidade
- BLOCKER: Dado sensível em log, healthcheck faltando com dependência nova.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style.

## Saída em Markdown

```md
### review-observability
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta. Correção: ação.
```

## Regra dura
Plano que viola BLOCKER não está pronto.
