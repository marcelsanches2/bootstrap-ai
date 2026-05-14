# Plano: Ideias do Context-Engineering para bootstrap-ai

**Fonte:** [davidkimai/Context-Engineering](https://github.com/davidkimai/Context-Engineering) (8.9k stars)
**Branch:** `feature/context-eng-imports`
**Base:** `feature/kickoff-design-phase`

---

## Análise por Item

### 1. 🟡 Protocolo de Debug Estruturado (`bug.diagnose`)

**Deles:** Protocolo com fases (reproduce → isolate → analyze → hypothesize), schemas JSON para troubleshooting, ferramentas de log parser, timeline builder, RCA mapper.

**O que temos:** Nada. O `refactor.md` cobre refatoração, mas debug é tratado como "pensar e consertar" sem método.

**Gap real:** Quando o Claude Code debuga, ele improvisa. Não segue método. Um protocolo estruturado força disciplina.

**O que eu faria:**
- Novo command `common/commands/debug.md`
- Fases: reproduzir → isolar → hipótese → testar hipótese → corrigir → verificar
- Output formatado com severidade, evidência e correção concreta
- Schema JSON de troubleshooting (opcional, pra projetos que querem log estruturado)

**Esforço:** Médio (2h)
**Valor:** Alto — debug é o uso mais comum de IA em projeto existente

---

### 2. 🟡 Agentes Especializados como Templates (`triage.agent`, `research.agent`, `diligence.agent`)

**Deles:** Templates de system prompts com meta, instructions, context_schema, workflow em YAML, tools, recursion loop, examples. Formato padronizado e auditável.

**O que temos:** `role-*.md` com checklists plano. Funcional mas sem estrutura de workflow fásico, sem schema, sem recursion/revision loop.

**Gap real:** Nossos roles são "checklists de revisão". Os deles são "agentes com workflow fásico". A diferença é:
- Nosso: `[OK] Auth em endpoints protegidos` → linear, sem volta
- Deles: `intake → timeline → prioritize → investigate → evidence → root_cause → mitigate → audit` → com loop de revisão

**O que eu faria:**
- Evoluir o formato dos `role-*.md` para incluir workflow fásico
- Não copiar o formato acadêmico deles (meta/schema/recursion é overkill)
- Pegar a ideia de: cada role tem fases explícitas, output esperado por fase, e loop de revisão
- Aplicar primeiro no `role-security.md` como piloto

**Esforço:** Médio (3h pra reformular os roles existentes)
**Valor:** Médio — melhora qualidade da revisão, mas nossos roles já funcionam

---

### 3. 🟢 Workflow Explore-Plan-Code-Commit

**Deles:** Protocolo `/workflow.explore_plan_code_commit` com 4 fases explícitas: explore (ler código), plan (planejar), implement (codar), finalize (commit/PR).

**O que temos:** `plan.md` + `jarvis-plan-revisor.md` + `ship.md` que já cobre isso, mas de forma fragmentada. O CLAUDE.md de cada preset já define o processo em 6 passos.

**Gap real:** Minimo. Nosso fluxo já é mais completo (6 passos vs 4 deles). O que falta é garantir que o Claude Code sempre siga o processo, não pule etapas.

**O que eu faria:**
- Nada novo. Nosso processo já cobre.
- Se quiser: adicionar "nunca pule o plan" como regra explícita no CLAUDE.md

**Esforço:** Baixo (30 min)
**Valor:** Baixo

---

### 4. 🟢 Self-Reflection Protocol (`self.identify_gaps`, `self.improve_solution`)

**Deles:** Protocolos de auto-avaliação: identificar gaps de conhecimento, avaliar solução contra critérios, melhorar iterativamente.

**O que temos:** `jarvis-plan-revisor.md` já faz revisão com BLOCKER/MAJOR/MINOR. O loop de melhoria é implícito.

**Gap real:** Nosso revisor avalia o plano, mas não avalia a si mesmo. Não tem "o que eu não sei sobre este problema?".

**O que eu faria:**
- Adicionar um bloco "gaps identificados" no `jarvis-plan-revisor.md`
- Pergunta: "Que informação este plano assume mas não declara?"
- Sem criar command novo

**Esforço:** Baixo (30 min)
**Valor:** Médio — força honestidade intelectual na revisão

---

### 5. 🔴 Neural Field Theory, Attractor Dynamics, Symbolic Mechanisms

**Deles:** 4+ módulos de teoria (field theory, attractor dynamics, symbolic residue, quantum semantics). Frameworks de "contexto como campo energético".

**O que temos:** Nada relacionado.

**Gap real:** Nenhum. Isso é acadêmico/experimental. Não tem aplicação prática em kits de desenvolvimento.

**O que eu faria:** Nada.

---

## Recomendação Final

| # | Item | Ação | Prioridade | Esforço |
|---|---|---|---|---|
| 1 | **debug.md** (protocolo de debug) | Criar novo command | 🔴 Alta | 2h |
| 2 | **role-security evolution** (workflow fásico) | Evoluir format do role | 🟡 Média | 3h |
| 3 | **jarvis-plan-revisor gaps** (self-reflection) | Patch no revisor | 🟡 Média | 30min |
| 4 | Explore-Plan-Code-Commit | Ignorar (já temos) | — | — |
| 5 | Neural fields / attractor dynamics | Ignorar (acadêmico) | — | — |

### Ordem de execução sugerida

1. `debug.md` — valor imediato, todo projeto precisa
2. `jarvis-plan-revisor` patch — rápido, melhora qualidade de toda revisão
3. `role-security` evolution — piloto do novo formato, se fizer sentido expande pros demais

---

## Detalhes de implementação

### `debug.md` — estrutura proposta

```markdown
# /debug

Protocolo estruturado de diagnóstico e correção de bugs.

## Quando usar
- Bug reportado (erro em produção, teste falhando, comportamento inesperado)
- Performance degradada sem causa óbvia
- Erro intermitente

## Fases obrigatórias

### Fase 1: Reproduzir
- Comando/ação exata que causa o problema
- Ambiente (dev/prod/staging)
- Frequência (sempre/às vezes/específico)
- Se não consegue reproduzir → declarar e investigar com logs

### Fase 2: Isolar
- Reduzir ao menor caso possível
- Que componentes estão envolvidos
- Que mudanças recentes tocaram isso (git log/blame)
- É frontend? backend? infra? integração?

### Fase 3: Hipóteses
- Listar 1-3 causas possíveis ordenadas por probabilidade
- Para cada: o que confirma, o que descarta

### Fase 4: Testar hipóteses
- Escolher a mais provável
- Investigar com logs, breakpoints, testes
- Se confirmou → Fase 5
- Se descartou → próxima hipótese

### Fase 5: Corrigir
- Mudança mínima que resolve
- Não refatorar junto
- Teste que prova o fix
- Teste que evita regressão

### Fase 6: Verificar
- Bug original não acontece mais
- Não quebrou nada novo
- Se em produção: monitorar logs/métricas pós-deploy

## Output formatado
[cada fase com template markdown]
```

### `jarvis-plan-revisor` — patch proposto

Adicionar após a seção de severidade:

```markdown
## Verificação de gaps

Após revisar todos os pontos, responda:

1. **Suposições não declaradas**: Que informação este plano assume como verdade mas não explicita?
2. **Conhecimento faltando**: Que contexto externo (docs, APIs, specs) o plano precisa mas não referenciou?
3. **Riscos invisíveis**: Que cenário de falha este plano não considera?

Formato:
- GAP [MAJOR/MINOR]: <descrição> → <ação para resolver>
```
