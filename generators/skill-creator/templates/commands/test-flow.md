---
description: Valida um fluxo E2E garantindo massa deterministica, testes e relatorio atualizado.
---

# /test-flow

Valida um fluxo end-to-end do {{PROJECT_NAME}}. Argumento opcional: `flow_id`.

## Geração

Este arquivo deve ser gerado usando `prompts/derive-test-flow.md` com base na stack específica.

## Estrutura obrigatória (a preencher)

```
0. Avaliar tamanho da task (GRANDE/PEQUENA)
1. Determinar flow_id
2. Inventariar massa (fixtures/mocks deterministicos)
3. Inventariar teste (com cross-ref ao jarvis-revisor)
4. Executar pipeline (lint → typecheck → test → migration → build → healthcheck)
4a. Loop de diagnóstico e correcao (max 3 tentativas)
5. Gerar relatório em docs/test_report_{flow_id}.md
6. Encerrar
7. Commit (so se PASSOU, nunca --no-verify)
8. Push (nunca force, pergunta antes de rebase)
+ Restrições obrigatórias
```

## Mínimo esperado

- 200+ linhas (~9000+ chars)
- Pipeline com comandos reais da stack
- Loop de diagnóstico com causas específicas
- Commit/push com regras duras
