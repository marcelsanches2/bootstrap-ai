---
name: jarvis-revisor
description: Revisa plano técnico contra docs/ai e roles do preset.
---

# /jarvis-plan-revisor

Revisa o plano técnico mais recente em `plans/*.md` ou um arquivo informado pelo usuário.

Não execute implementação. Não altere código de produção. Apenas leia, valide e reporte.

## Sequência obrigatória

1. Localizar plano usando `product_roles/localizar-plano.md`.
2. Carregar referências usando `product_roles/carregar-referencias.md` (só as relevantes ao tipo de mudança).
3. Selecionar roles por tipo de impacto (ver abaixo).
4. Rodar as roles selecionadas (cada uma produz parecer independente).
5. Consolidar parecer usando `product_roles/consolidar-parecer.md`.
6. Gerar relatório usando `product_roles/gerar-relatorio.md`.
7. Se houver BLOCKER, pare.
8. Se houver MAJOR e zero BLOCKER, pergunte ao usuário como sanar cada uma.
9. Somente com zero BLOCKER e zero MAJOR pendente, append o relatório ao plano original.

## Seleção de roles por impacto

Antes de chamar revisores, analise o plano para determinar quais roles são necessárias.

**Sempre chame:**

- `product_roles/role-architect.md` — toda mudança tem impacto arquitetural
- `product_roles/role-pm.md` — toda mudança tem impacto de produto

**Chame condicionalmente:**

| Condição no plano | Role |
|---|---|
| UI, tela, componente visual, layout, design system, token, cor, tipografia | `product_roles/role-designer.md` |
| Acessibilidade, teclado, foco, semântica, ARIA, screen reader | `product_roles/review-accessibility.md` |
| Bundle, renderização, imagens, Web Vitals, lazy loading, memo | `product_roles/review-performance.md` |
| Fluxo testável, integração, estado, data fetching, regra de negócio | `product_roles/role-web-qa.md` |
| Deploy, env, build, cache, CI/CD, release, rollback | `product_roles/role-delivery.md` |

**Se nenhuma condição se aplica** (ex: plano puramente interno de refator), apenas architect + PM.

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
