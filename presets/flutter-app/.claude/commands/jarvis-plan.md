---
name: jarvis-plan
description: Planejamento unificado — explora codebase, grilla se necessário, gera plano técnico com todas as perspectivas embutidas. Um pass de LLM.
---

# /jarvis-plan

Gere o plano técnico definitivo para a task, com todas as perspectivas embutidas de primeira.

Não execute implementação. Não altere código de produção. Apenas planeje.

## Sequência

---

## 1. Entender a task

Leia o contexto disponível:

- `CLAUDE.md` — contrato do projeto, estrutura, convenções
- `PRODUCT_BRIEF.md` — se existir, termos e entidades do domínio
- A task descrita pelo usuário
- Explore o codebase relevante (modelos, serviços, rotas, testes existentes)

**Se a task for ambígua** — ative o grill (etapa 2).
**Se a task for clara** — pule direto pra etapa 3.

---

## 2. Grill integrado (condicional)

Ative SOMENTE quando a task tiver:

- Feature nova sem especificação clara
- Múltiplas abordagens viáveis com trade-offs reais
- Termos ambíguos que o codebase não resolve
- Decisão de arquitetura irreversível

**Regras do grill:**

- UMA pergunta por vez. Espera resposta antes de continuar.
- Cada pergunta com: recomendação + por quê + alternativa.
- Máximo 7 perguntas. Se precisar de mais, a task é grande demais — sugira quebrar.
- Se a resposta está no codebase, busque ao invés de perguntar.
- Desafie termos vagos, teste edge cases, compare com o que existe.
- Sugira ADR quando: hard to reverse + surprising + real trade-off.

**Quando o grill terminar, gere resumo em tabela:**

```md
| Decisão | Escolha | Razão |
|---------|---------|-------|
| ...     | ...     | ...   |
```

---

## 3. Selecionar contribuidores

Selecione as roles relevantes para a task. Nenhuma é obrigatória.

| Condição na task | Role |
|---|---|
| Escopo, requisitos, critérios de aceite, impacto em produto | `product_roles/role-pm.md` |
| Estrutura, camadas, dependências, decisão arquitetural | `product_roles/role-architect.md` |
| UI, tela, componente visual, layout, design system, token | `product_roles/role-designer.md` |
| Fluxo testável, usecase, regra de negócio, estado | `product_roles/role-flutter-qa.md` |

**Se nenhuma condição se aplica** (ex: task de infra/config simples), gere o plano sem roles.

---

## 4. Gerar plano com contribuições

Para cada role selecionada:

1. Leia o arquivo da role
2. Consulte as referências listadas na role
3. Gere a seção conforme o "Formato de saída" da role
4. Se a role diz "Não se aplica", inclua a seção com justificativa

**Montagem do plano:**

- Respeitar a ordem: PM → Architect → Stack-specific → Domain reviews → QA → Delivery
- Deduplicar: se architect e QA ambos mencionam testes, QA vira dono da seção de testes
- Cada seção com heading claro, sem sobreposição

---

## 5. Regras bloqueantes

Consulte a seção `## Regras bloqueantes` dos guides referenciados pelas roles selecionadas (etapa 3). O plano NÃO pode ser proposto se violar qualquer regra listada como bloqueante nesses guides.

**Regra universal:** o plano deve ter comportamento de produto, não apenas lista de arquivos/classes.

Se alguma regra for violada, corrija o plano antes de apresentar.

---

## 6. Formato final obrigatório

```md
# Plano: {título}

Data: {YYYY-MM-DD}

## Objetivo
{O que resolve, para quem, comportamento esperado}

## Escopo / Fora de escopo
{Incluído} / {Excluído}

## Critérios de aceite
- [ ] {verificável}

## Arquitetura
{Seção do architect}

## {Seções das roles selecionadas}

## Testes
{Seção do QA}

## Plano incremental
1. **Passo N — {título}**: {descrição}. Arquivos: {lista}. Validação: {como verificar}.

## Referências
- `docs/ai/{arquivo}` — {por que}
```

---

## 7. Salvar e aguardar aprovação

1. Salve o plano em `plans/YYYY-MM-DD-{slug}.md`
2. Apresente o plano ao usuário
3. Aguarde aprovação antes de qualquer implementação
4. Se o usuário pedir ajustes, atualize o plano e reapresente

---

## Regras

- Um pass de LLM — sem rascunho seguido de revisão.
- Se a informação estiver ausente, pergunte (grill) antes de assumir.
- Não implemente. Não crie arquivos de produção.
