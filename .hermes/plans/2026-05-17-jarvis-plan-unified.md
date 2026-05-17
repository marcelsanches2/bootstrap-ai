# Plano: jarvis-plan — Orquestrador de Planejamento Unificado

## Objetivo

Substituir `/plan` + `/jarvis-plan-revisor` + `/grill` (como passo separado) por um único comando `/jarvis-plan` que gera planos corretos de primeira vez. Roles passam de revisores (checklist) a contribuidores (geram seções do plano).

## Fluxo atual (5-8 passes de LLM)

```
/plan (1 pass) → /jarvis-plan-revisor (1 pass por role + síntese + loop corretivo 1-3x) → approval gate
```

## Fluxo proposto (1 pass)

```
/jarvis-plan → explora codebase → grilla se necessário → gera plano com perspectivas embutidas → user aprova
```

---

## Tarefa 1: Criar `common/commands/jarvis-plan.md`

Novo comando orquestrador. ~150-200 linhas.

### Estrutura do comando

```markdown
# /jarvis-plan

## 1. Entender a task
- Ler CLAUDE.md, PRODUCT_BRIEF.md (se existir)
- Explorar codebase relevante
- Se ambíguo: grillar (mecanismo inline do grill, 1 pergunta por vez, máx 7)

## 2. Selecionar contribuidores
- Analisar tipo de mudança
- Selecionar roles relevantes (mesma smart selection atual)
- Sempre: architect + PM
- Condicional: designer, QA, review-* por domínio

## 3. Carregar referências
- Ler docs/ai/ relevantes por tipo de task (mesma lógica do carregar-referencias)

## 4. Gerar plano
- Cada role contribui sua seção (não revisa — escreve)
- Montagem coerente com deduplicação
- Formato: objetivo, escopo, fora de escopo, arquitetura, plano incremental, testes, riscos, critérios de aceite

## 5. Salvar e aguardar aprovação
- Salvar em plans/YYYY-MM-DD-slug.md
- Aguardar aprovação humana (Plan Mode nativo)
```

### Seções do plano e quem contribui

| Seção | Contribuidor |
|-------|-------------|
| Objetivo, Escopo, Fora de escopo | PM |
| Arquitetura proposta | Architect |
| Plano incremental | Architect (+ stack-specific architect se houver) |
| Schema / Migrations / Queries | review-database |
| Endpoints / Contratos | review-api |
| Segurança e validação | review-security |
| Observabilidade | review-observability |
| Escala e performance backend | review-scalability |
| UI / Componentes / Design | Designer |
| Acessibilidade | review-accessibility |
| Performance frontend | review-performance |
| Testes | role-{stack}-qa |
| Critérios de aceite | PM |
| Riscos | Architect + PM |

### Formato de saída

```markdown
# <Título da task>

## Objetivo
<PM: problema, para quem, comportamento esperado>

## Escopo
<PM: o que está incluído>
## Fora de escopo
<PM: o que NÃO está incluído e por quê>

## Arquitetura proposta
<Architect: camadas, estruturas, dependências, rotas, providers>

### Banco de dados (se aplicável)
<review-database: schema, migration, índices>

### API (se aplicável)
<review-api: endpoints, contratos, status codes>

### Segurança (se aplicável)
<review-security: auth, validação, PII>

## Plano incremental
<Architect: steps ordenados, cada um testável>

## Testes
<role-{stack}-qa: unit, integration, E2E, cenários>

## Riscos
<Architect + PM: o que pode dar errado e mitigação>

## Critérios de aceite
<PM: lista verificável>
```

### Arquivos
- `common/commands/jarvis-plan.md` (novo, ~180 linhas)
- Copiar para `.claude/commands/` de todos os 5 presets

---

## Tarefa 2: Reescrever todos os product roles (revisor → contribuidor)

### O que muda

Cada role passa de:
- **Antes**: checklist OK/PENDÊNCIA que critica um plano pronto
- **Depois**: template gerativo que escreve sua seção do plano

### Trabalho por role

**CADA role precisa ser**:
1. **Lido** — entender que itens do checklist são relevantes pra geração
2. **Mapeado** — quais itens viram instruções de "o que incluir na seção"
3. **Reescrito** — novo formato gerativo mantendo cobertura do checklist original
4. **Validado** — confirmar que nenhum item do checklist antigo foi perdido

### Formato novo dos roles

```markdown
# Role: {Nome}

## Sua contribuição
<1 frase: o que esta role gera no plano>

## O que incluir
- Item 1 (com detalhes do que é um bom output)
- Item 2
- Item 3

## Referência
- docs/ai/{GUIDE}.md
- docs/ai/{OTHER_GUIDE}.md

## Regras
- <restrições específicas da role>
- Se não se aplica à task, escrever "Não se aplica a esta task" e por quê

## Formato de saída
<template markdown da seção que esta role gera>
```

### Checklist de conversão por role

Para CADA role, o processo é:

```
1. Ler role atual (checklist) → listar todos os itens verificados
2. Converter cada item em instrução gerativa:
   - Antes: "Verifique se o plano respeita domain → data → presentation"
   - Depois: "Descreva camadas envolvidas: domain → data → presentation, com responsabilidades de cada uma"
3. Itens que eram "OK — não aplicável" viram: "Se não se aplica, escreva 'Não se aplica' e por quê"
4. Regra dura do checklist vira regra de geração (última seção)
5. Manter referências a docs/ai/ — a role ainda precisa consultar os guias
```

### Roles por preset (com mapping)

**flutter-app** (4 roles):

| Arquivo | Checklist atual | Nova seção gerada |
|---------|----------------|-------------------|
| `role-architect.md` (101 linhas) | 6 itens: camadas, dependências, DTOs, providers, rotas, testabilidade | Arquitetura proposta + Plano incremental |
| `role-pm.md` (87 linhas) | 5 itens: objetivo, fluxo principal, alternativos, estados, critérios | Objetivo + Escopo + Fora de escopo + Critérios de aceite |
| `role-designer.md` (90 linhas) | 6 itens: design system, fidelidade, estados visuais, acessibilidade, responsividade, componentização | UI / Componentes / Design |
| `role-flutter-qa.md` (109 linhas) | 5 itens: testabilidade, caminho feliz, negativos, massa de dados, automação Flutter | Testes (pipeline Flutter) |

**python-backend** (10 roles):

| Arquivo | Nova seção gerada |
|---------|-------------------|
| `role-architect.md` | Arquitetura + Plano incremental |
| `role-backend-architect.md` | Complementa arquitetura com patterns Python |
| `role-pm.md` | Escopo + Critérios |
| `role-delivery.md` | Deploy e entrega |
| `role-api-qa.md` | Testes de API |
| `review-api.md` | Endpoints, contratos, status codes |
| `review-database.md` | Schema, migrations, índices |
| `review-security.md` | Auth, validação, PII |
| `review-observability.md` | Logs, métricas, tracing |
| `review-scalability.md` | Escala, concorrência, filas |

**node-backend** (10 roles): mesmo padrão python-backend com roles específicos (role-node-architect)

**react-web** (8 roles):

| Arquivo | Nova seção gerada |
|---------|-------------------|
| `role-architect.md` | Arquitetura + Plano incremental |
| `role-frontend-architect.md` | Patterns React/componentes |
| `role-pm.md` | Escopo + Critérios |
| `role-delivery.md` | Deploy e entrega |
| `role-designer.md` | UI / Componentes / Design |
| `role-web-qa.md` | Testes (unit + E2E) |
| `review-accessibility.md` | Acessibilidade |
| `review-performance.md` | Performance frontend |

**fullstack-web** (12 roles): merge de react-web + node-backend com roles de ambos

### Contagem total

| Preset | Roles | Estimativa linhas/role |
|--------|-------|----------------------|
| flutter-app | 4 | ~40-50 |
| python-backend | 10 | ~35-45 |
| node-backend | 10 | ~35-45 |
| react-web | 8 | ~35-45 |
| fullstack-web | 12 | ~35-45 |
| **Total** | **44 roles** | |

### Validação pós-conversão

Para cada role convertida:
1. Comparar itens do checklist original vs instruções gerativas — nada pode se perder
2. Verificar que referências a docs/ai/ estão corretas
3. Confirmar que formato de saída produz seção clara pro jarvis-plan montar
4. Checar que regra dura original virou restrição de geração

### Comando: manter `role-` prefix para pessoas, `review-` para domínios

---

## Tarefa 3: Remover `/jarvis-plan-revisor`

### Arquivos a deletar (todos os 5 presets + common se existir)

- `presets/*/. claude/commands/jarvis-plan-revisor.md` (5 arquivos)

### Helpers a deletar (todos os 5 presets + common)

- `presets/*/.claude/commands/product_roles/consolidar-parecer.md` (não tem parecer pra consolidar)
- `presets/*/.claude/commands/product_roles/gerar-relatorio.md` (não tem relatório de revisão)
- `common/commands/product_roles/consolidar-parecer.md`
- `common/commands/product_roles/gerar-relatorio.md`

### Helpers a manter

- `localizar-plano.md` — `/jarvis-test-flow` precisa achar o plano
- `carregar-referencias.md` — simplificado, jarvis-plan usa a mesma lógica

---

## Tarefa 4: Remover `/plan` como comando separado

`/plan` é substituído por `/jarvis-plan`. 

### Arquivos a deletar
- `common/commands/plan.md`
- `presets/*/.claude/commands/plan.md` (5 arquivos)

**Nota**: O `/plan` nativo do Claude Code (que entra em Plan Mode) continua funcionando — ele é built-in, não nosso comando. Nosso `/jarvis-plan` usa Plan Mode nativo por baixo.

---

## Tarefa 5: Integrar `/grill` no jarvis-plan

### Mudança no `/grill`
- `common/commands/grill.md` **continua existindo** como standalone
- `/jarvis-plan` embute a mecânica do grill (explorar codebase, perguntar quando ambíguo)

### Arquivos: sem mudança no grill.md

---

## Tarefa 6: Atualizar `settings.json` — remover hook ExitPlanMode

### Hoje (todos os presets)
```json
{
  "matcher": "ExitPlanMode",
  "hooks": [{
    "type": "command",
    "command": "... echo '/jarvis-plan-revisor' ..."
  }]
}
```

### Depois
Remover o bloco `ExitPlanMode` inteiro. O jarvis-plan já gera o plano certo — não precisa de revisão automática pós-aprovação.

### Hooks finais
- `PostToolUse (Edit|Write|MultiEdit)` → lint (mantém)
- `Stop` → jarvis-test-flow (mantém)
- `ExitPlanMode` → **removido**

---

## Tarefa 7: Atualizar manifests

### Remover de required_files (todos os 5 manifests)
- `-.claude/commands/plan.md`
- `-.claude/commands/jarvis-plan-revisor.md`
- `-.claude/commands/product_roles/consolidar-parecer.md`
- `-.claude/commands/product_roles/gerar-relatorio.md`

### Adicionar em required_files (todos os 5 manifests)
- `-.claude/commands/jarvis-plan.md`

---

## Tarefa 8: Atualizar CLAUDE.md raiz do repo

### Lifecycle atualizado
```
/grill (standalone, opt-in) → entrevista sem plano
/jarvis-plan → explora, grilla se necessário, gera plano com perspectivas → user aprova
(desenvolve) → hook PostToolUse roda lint
/jarvis-test-flow → pipeline completo (hook Stop)
/jarvis-revisor → auditoria global (sob demanda)
/jarvis-full-test → regressão completa (sob demanda)
/ship → checklist final
```

### Anatomia atualizada
Remover `jarvis-plan-revisor` e `plan` da lista. Adicionar `jarvis-plan`.

---

## Tarefa 9: Atualizar `/jarvis-test-flow`

O test-flow referencia o plano via `localizar-plano.md`. Sem mudança no mecanismo, mas o formato do plano muda (seções novas). Verificar se o test-flow ainda consegue extrair o que precisa.

**Ação**: revisar `jarvis-test-flow.md` em cada preset para garantir que as referências ao formato do plano (se houver) refletem o novo formato. Provavelmente sem mudança — o test-flow lê o plano como texto.

---

## Tarefa 10: Atualizar `/jarvis-revisor`

O revisor global é independente — audita o projeto inteiro, não planos. **Sem mudança**.

Verificar se referencia `/jarvis-plan-revisor` em algum lugar. Se sim, remover a referência.

---

## Tarefa 11: Limpar patterns

### Avaliar
- `common/commands/patterns/approval-gate.md` — usado pelo revisor. **Deletar**.
- `common/commands/patterns/loop-corretivo.md` — usado pelo revisor. **Deletar**.
- Cópias nos presets: **deletar**.

---

## Ordem de execução

```
 1. Reescrever todos os product roles (Tarefa 2) — TRABALHO PRINCIPAL
    - 44 roles em 5 presets (ler → mapear → reescrever → validar)
    - Preferencialmente por preset: flutter-app primeiro (source of truth),
      depois python-backend, node-backend, react-web, fullstack-web
 2. Criar common/commands/jarvis-plan.md (Tarefa 1)
 3. Copiar jarvis-plan.md para todos os presets
 4. Atualizar settings.json (remover ExitPlanMode) em todos os presets (Tarefa 6)
 5. Atualizar manifests (remover plan/revisor/helpers, adicionar jarvis-plan) (Tarefa 7)
 6. Deletar jarvis-plan-revisor.md de todos os presets (Tarefa 3)
 7. Deletar plan.md de common/ e todos os presets (Tarefa 4)
 8. Deletar consolidar-parecer.md e gerar-relatorio.md (Tarefa 3)
 9. Deletar patterns (approval-gate, loop-corretivo) (Tarefa 11)
10. Atualizar CLAUDE.md raiz (Tarefa 8)
11. Revisar jarvis-test-flow (Tarefa 9)
12. Revisar jarvis-revisor (Tarefa 10)
13. Validar todos os 5 presets
14. Grep de sanidade (referências a comandos removidos)
15. Commit e push
```

---

## Arquivos afetados (resumo)

| Ação | Arquivo | Qtd |
|------|---------|-----|
| **Criar** | `common/commands/jarvis-plan.md` | 1 |
| **Criar** | `presets/*/.claude/commands/jarvis-plan.md` | 5 |
| **Reescrever** | `presets/*/.claude/commands/product_roles/role-*.md` | ~30 roles |
| **Reescrever** | `presets/*/.claude/commands/product_roles/review-*.md` | ~15 reviews |
| **Deletar** | `common/commands/plan.md` | 1 |
| **Deletar** | `presets/*/.claude/commands/plan.md` | 5 |
| **Deletar** | `presets/*/.claude/commands/jarvis-plan-revisor.md` | 5 |
| **Deletar** | `common/commands/product_roles/consolidar-parecer.md` | 1 |
| **Deletar** | `presets/*/.claude/commands/product_roles/consolidar-parecer.md` | 5 |
| **Deletar** | `common/commands/product_roles/gerar-relatorio.md` | 1 |
| **Deletar** | `presets/*/.claude/commands/product_roles/gerar-relatorio.md` | 5 |
| **Deletar** | `common/commands/patterns/approval-gate.md` | 1 |
| **Deletar** | `presets/*/.claude/commands/patterns/approval-gate.md` | 5 |
| **Deletar** | `common/commands/patterns/loop-corretivo.md` | 1 |
| **Deletar** | `presets/*/.claude/commands/patterns/loop-corretivo.md` | 5 |
| **Editar** | `presets/*/. claude/settings.json` | 5 |
| **Editar** | `presets/*/manifest.yaml` | 5 |
| **Editar** | `CLAUDE.md` (raiz) | 1 |

**Total**: ~85 operações de arquivo

---

## Economia estimada

| Métrica | Antes | Depois |
|---------|-------|--------|
| Passes de LLM antes de codar | 5-8 | 1 |
| Tokens por plano | ~15-25k | ~5-8k |
| Tempo até aprovação | 5-15 min | 1-3 min |
| Arquivos por preset | 17-22 | 12-15 |
| Helpers de revisão | 4 (localizar, carregar, consolidar, gerar) | 2 (localizar, carregar) |

---

## Riscos

1. **Qualidade do plano com 1 pass** — se o LLM não carregar contexto suficiente, o plano pode ser raso. Mitigação: jarvis-plan carrega docs/ai/ por relevância ANTES de gerar.
2. **Roles contribuidores sobram** — roles que não se aplicam à task vão gerar "Não se aplica". Isso é OK, mas o jarvis-plan deve pular roles irrelevantes (smart selection).
3. **Hooks do settings.json** — remover ExitPlanMode muda comportamento existente. Projetos que já usam bootstrap-ai vão precisar re-aplicar o preset.
