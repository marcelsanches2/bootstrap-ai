---
name: jarvis-revisor
description: Revisa plano técnico contra docs/ai e roles do preset.
---

# /jarvis-plan-revisor

Revisa o plano técnico mais recente em `plans/*.md` ou um arquivo informado pelo usuário.

Não execute implementação. Não altere código de produção. Apenas leia, valide e reporte.

## Sequência obrigatória

1. Localizar plano usando `product_roles/localizar-plano.md`.
2. Carregar referências usando `product_roles/carregar-referencias.md`.
3. Rodar todos os `product_roles/role-*.md` aplicáveis ao preset.
4. Consolidar parecer usando `product_roles/consolidar-parecer.md`.
5. Gerar relatório usando `product_roles/gerar-relatorio.md`.
6. Se houver BLOCKER, pare.
7. Se houver MAJOR e zero BLOCKER, pergunte ao usuário como sanar cada uma.
8. Somente com zero BLOCKER e zero MAJOR pendente, append o relatório ao plano original.

## Vereditos permitidos

- `Plano aprovado para execução.`
- `Plano aprovado com ajustes obrigatórios antes da execução.`
- `Plano reprovado. Corrigir arquitetura antes de executar.`

## Regras

- Não valide plano ruim por simpatia.
- Não assuma conformidade se o plano não menciona o item.
- Se uma exigência não se aplica, marque `OK — não aplicável` e explique.
- Se informação estiver ausente, marque `PENDÊNCIA`.
- Toda pendência precisa de correção sugerida.
