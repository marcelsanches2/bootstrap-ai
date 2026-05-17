---
name: jarvis-plan
description: Planejamento unificado — explora codebase, grilla se necessário, gera plano técnico com todas as perspectivas embutidas para Python backend. Um pass de LLM.
---

# /jarvis-plan

Você é um engenheiro sênior responsável por criar o plano técnico definitivo para uma task. Diferente de um revisor, você **gera** o plano com todas as perspectivas embutidas de primeira — sem loop corretivo.

Não execute implementação. Não altere código de produção. Apenas planeje.

## Sequência obrigatória

Execute as etapas abaixo nesta ordem.

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

Analise a task para determinar quais roles contribuem para o plano. Não carregue todas — selecione com base no tipo de mudança.

**Sempre carregue:**

- `product_roles/role-architect.md` — toda mudança tem impacto arquitetural
- `product_roles/role-pm.md` — toda mudança tem impacto de produto

**Carregue condicionalmente:**

| Condição na task | Role |
|---|---|
| Endpoint, contrato HTTP, status code, schema, OpenAPI | `product_roles/review-api.md` |
| Schema, migration, índice, query, ORM, constraint | `product_roles/review-database.md` |
| Auth, autorização, secrets, PII, validação sensível, rate limit | `product_roles/review-security.md` |
| Logs, métricas, tracing, healthcheck, incidente | `product_roles/review-observability.md` |
| Volume, concorrência, cache, fila, pool, produção crítica | `product_roles/review-scalability.md` |
| Fluxo testável, usecase, regra de negócio, integração | `product_roles/role-api-qa.md` |
| Service, repository, model, usecase, camada Python | `product_roles/role-backend-architect.md` |
| Deploy, env, CI/CD, release, rollback, infra | `product_roles/role-delivery.md` |

**Se nenhuma condição se aplica** (ex: task puramente técnica de infra/config), apenas architect + PM.

---

## 4. Carregar referências (lazy loading)

Não carregue tudo de uma vez. Carregue em duas fases:

### Fase 1 — Baseline (sempre, antes de gerar)

- `docs/ai/ARCHITECTURE.md` — estrutura do projeto
- `docs/ai/CODING_STANDARDS.md` — padrões de código

### Fase 2 — Sob demanda (após selecionar roles)

Para cada role selecionada, carregue **apenas** as referências listadas na seção "Referência" da role.

Exemplo: se só `role-architect` e `role-pm` foram selecionados, carregue só o que eles pedem. Não carregue `DESIGN_SYSTEM.md` se nenhuma role de UI foi selecionada.

**Regras:**

- Se um doc referenciado não existe: reporte como referência ausente, continue.
- Não invente padrões que não estejam nos documentos.
- Se nenhum doc existe em `docs/ai/`, continue só com CLAUDE.md + exploração do codebase.

---

## 5. Gerar plano com contribuições

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

## 6. Regras obrigatórias de bloqueio

O plano NÃO pode ser proposto se houver:

- Violação clara de camadas (domínio dependendo de FastAPI, SQLAlchemy, requests/httpx, boto ou SDK externo).
- Transporte (route/controller) misturado com regra de domínio.
- DTO/schema de API (Pydantic) usado como entidade de domínio.
- ORM query vazando para camada de serviço ou controller sem repository.
- Alteração de modelo sem migration Alembic correspondente e caminho de downgrade documentado.
- Função pública sem type hints em assinatura.
- Endpoint sem contrato de erro previsível (códigos de status, schema de resposta).
- Lógica crítica sem tratamento de erro explícito (try/except com exceção específica).
- Endpoint ou fluxo sem log/métrica/tracing mínimo para diagnóstico em produção.
- Transação sem fronteira explícita (session/context manager).
- Plano sem comportamento de produto, apenas lista de arquivos/classes.
- Teste que depende de produção, relógio real sem controle ou rede externa sem mock.
- Regra crítica sem teste previsto.

Se alguma regra for violada, corrija o plano antes de apresentar.

---

## 7. Formato final obrigatório

```md
# Plano: {título da task}

Data: {YYYY-MM-DD}

## Objetivo

{O que esta task resolve, para quem, comportamento esperado}

## Escopo

- {Incluído 1}
- {Incluído 2}

## Fora de escopo

- {Excluído 1}
- {Excluído 2}

## Critérios de aceite

- [ ] {critério 1 — verificável}
- [ ] {critério 2 — verificável}

## Arquitetura proposta

{Seção gerada pelo architect + backend architect — camadas Python, dependências, transações, type hints}

## {Seções de domain reviews conforme roles selecionadas (API, Database, Security, Observability, Scalability)}

## Testes

{Seção gerada pelo API QA}

## Plano incremental

1. **Passo 1 — {título}**: {descrição}. Arquivos: {lista}. Validação: {como verificar}.
2. **Passo 2 — {título}**: {descrição}. Arquivos: {lista}. Validação: {como verificar}.
3. ...

## Referências

- `docs/ai/{arquivo}` — {por que foi consultado}
```

---

## 8. Salvar e aguardar aprovação

1. Salve o plano em `plans/YYYY-MM-DD-{slug}.md`
2. Apresente o plano ao usuário
3. Aguarde aprovação antes de qualquer implementação
4. Se o usuário pedir ajustes, atualize o plano e reapresente

---

## Regras de comportamento

- Seja direto.
- Um pass de LLM — não gere plano rascunho seguido de revisão.
- Cada seção já nasce com a qualidade que um revisor exigiria.
- Não proponha plano que viole as regras de bloqueio.
- Se a informação estiver ausente, pergunte (grill) antes de assumir.
- Não faça implementação.
- Não crie arquivos de produção.
