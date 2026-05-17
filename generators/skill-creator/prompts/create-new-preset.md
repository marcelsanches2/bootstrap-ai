# Skill Creator: Create New Preset

Crie um preset completo para uma nova tecnologia seguindo os padrões do Bootstrap AI.

## Input

O usuário forneceu:
- **Nome do preset**: `{{PRESET_NAME}}`
- **Descrição da stack**: `{{DESCRIPTION}}`

## Referência

Antes de gerar, leia os presets existentes para entender o padrão:

1. `presets/flutter-app/` — preset mobile com design system, QA E2E
2. `presets/python-backend/` — preset backend com API, DB, security, scalability
3. `presets/react-web/` — preset frontend com design system, accessibility, performance
4. `presets/node-backend/` — preset backend com TypeScript, tipagem, migrations

Use o preset mais similar à stack descrita como base primária. Adapte de lá.

## Padrões de nomenclatura (obrigatório)

Siga ESTES padrões — nenhum arquivo pode fugir deles:

### Roles e Reviews

| Tipo | Prefixo | Significado | Exemplos |
|---|---|---|---|
| **Papel** (pessoa que revisa) | `role-` | Uma pessoa com cargo definido | `role-architect.md`, `role-pm.md`, `role-designer.md`, `role-delivery.md` |
| **Papel + stack** (pessoa específica) | `role-<stack>-` | Pessoa com especialidade de stack | `role-flutter-qa.md`, `role-web-qa.md`, `role-api-qa.md` |
| **Domínio** (ótica técnica) | `review-` | Perspectiva de revisão, não cargo | `review-database.md`, `review-api.md`, `review-security.md`, `review-observability.md`, `review-scalability.md`, `review-accessibility.md`, `review-performance.md`, `review-testing.md` |

**Sempre em inglês. Sempre kebab-case.**

### docs/ai

| Tipo | Padrão | Exemplos |
|---|---|---|
| **Guia** (como fazer X) | `<DOMINIO>_GUIDE.md` | `API_GUIDE.md`, `TESTING_GUIDE.md`, `DATABASE_GUIDE.md` |
| **Padrão/Referência** (o que é X) | `<CONCEITO>.md` | `ARCHITECTURE.md`, `CODING_STANDARDS.md`, `DESIGN_SYSTEM.md` |

**Sempre UPPER_SNAKE_CASE. Sem prefixo `AI_`.**

### Separação de responsabilidades

- Cada guide tem UMA responsabilidade — testing só em `TESTING_GUIDE`, nunca em `FEATURE_GUIDE` ou `CODING_STANDARDS`
- Roles são perspectivas de revisão com objetivo + checklist (~47 linhas cada, sem boilerplate repetido)
- review-testing é perspectiva do revisor, não regras de teste

## Estrutura obrigatória

Gere TODOS os arquivos abaixo. Nenhum pode ficar vazio ou placeholder.

### Arquivos raiz

1. **`CLAUDE.md`** — Contexto do projeto para a IA. Deve ter:
   - Nome do projeto com `{{PROJECT_NAME}}`
   - Stack principal (framework, linguagem, ORM, ferramentas)
   - **Tabela de leitura sob demanda** — cada tipo de tarefa mapeia para os docs/ai relevantes (NÃO leia todos automaticamente)
   - Prioridade atual (lista numerada)
   - Regras obrigatórias específicas da stack
   - Processo obrigatório para mudanças não triviais (plan → jarvis-plan → implementar → test-flow → ship)
   - Princípio de decisão

2. **`manifest.yaml`** — Metadata do preset:
   - `name`, `description`
   - `required_files`: todos os arquivos gerados
   - `library_tags`: bibliotecas estruturais da stack que devem forçar este preset
   - `roles`: lista de todos os `role-*.md` e `review-*.md` gerados

3. **`plans/.gitkeep`** — Vazio.

### .claude/settings.json

4. Use o template `templates/settings.json` e adapte:
   - `PostToolUse` (Edit|Write|MultiEdit): comando de lint/typecheck da stack
   - `Stop`: detecta mudanças em arquivos da stack e força /jarvis-test-flow
   - `permissions.deny`: manter padrão (.env, rm -rf, git push --force)

### .claude/commands/ (comandos do lifecycle)

5. **`jarvis-plan.md`** — Use o preset mais similar como base. Deve ter **smart role selection**:
   - Passo de análise do plano → seleção condicional de roles
   - Sempre carrega: architect + PM
   - Condicionais: mapeia condições do plano para roles/reviews relevantes
   - Formato: tabela `| Condição no plano | Role |`
   - Vereditos, regras de bloqueio, formato de relatório, sanar pendências MAJOR
   - ~60-100 linhas


7. **`refactor.md`** — Use o preset mais similar como base. Adapte seções de regras específicas da stack.

8. **`ship.md`** — Copiar de `templates/commands/ship.md` (genérico).

9. **`jarvis-test-flow.md`** — Use o preset mais similar como base. Deve ter:
    - Fluxo completo de testes específico da stack
    - Comandos de execução (ex: `flutter test`, `pytest`, `npm test`)
    - Critérios de aprovação/reprovação
    - Auto-fix quando possível
    - ~150-300 linhas

### .claude/commands/product_roles/ (helpers + roles)

10. **Helpers** (copiar diretamente de qualquer preset existente — são idênticos para toda stack):
    - `carregar-referencias.md`
    - `localizar-plano.md`

11. **Roles genéricas** (copiar de `common/roles/` — são idênticas para toda stack):
    - `role-architect.md`
    - `role-pm.md`
    - `role-delivery.md`

12. **Roles específicas da stack** (criar seguindo o padrão):
    - Frontend: `role-designer.md`
    - Mobile: `role-designer.md`, `role-<stack>-qa.md` (ex: `role-flutter-qa.md`)
    - Web: `role-web-qa.md`
    - Backend: `role-api-qa.md`

13. **Reviews genéricos** (copiar de `common/roles/` quando aplicável):
    - Backend: `review-api.md`, `review-database.md`, `review-security.md`, `review-observability.md`, `review-scalability.md`
    - Frontend: `review-accessibility.md`, `review-performance.md`
    - Todos: `review-testing.md`

    **Cada role/review deve ter:**
    - Objetivo (1 frase)
    - Checklist com critérios marcáveis `[OK/PENDÊNCIA]`
    - Regra dura (1 frase)
    - ~40-50 linhas (SEM boilerplate de Entrada/Método/Saída)

### docs/ai/ (guias AI)

14. Gere todos os guias relevantes para a stack.

    **Mínimo obrigatório (todo preset):**
    - `ARCHITECTURE.md` — estrutura, boundaries, padrões de organização
    - `CODING_STANDARDS.md` — naming, convenções, anti-patterns
    - `TESTING_GUIDE.md` — estratégia, ferramentas, padrões de teste

    **Adicionais por tipo de stack:**
    - Backend: `API_GUIDE.md`, `DATABASE_GUIDE.md`, `SECURITY_GUIDE.md`, `OBSERVABILITY_GUIDE.md`, `SCALABILITY_GUIDE.md`, `DEPLOYMENT_GUIDE.md`
    - Frontend/Mobile: `DESIGN_SYSTEM.md`, `FEATURE_GUIDE.md`
    - Frontend Web: `ACCESSIBILITY_GUIDE.md`, `PERFORMANCE_GUIDE.md`, `DEPLOYMENT_GUIDE.md`

    **Cada guide:**
    - UMA responsabilidade (testing SÓ em TESTING_GUIDE)
    - Genérico o suficiente para qualquer projeto daquela stack
    - Usa `{{PROJECT_NAME}}` onde necessário
    - ~80-150 linhas

## Qualidade mínima

- Nenhum arquivo pode ter apenas título ou "TODO".
- Cada arquivo deve ter conteúdo substancial comparável aos presets existentes.
- Roles/reviews: ~40-50 linhas cada (objetivo + checklist + regra dura).
- Docs AI: ~80-150 linhas cada.
- jarvis-test-flow: ~150-300 linhas.
- jarvis-plan: ~60-100 linhas (com smart role selection).
- CLAUDE.md: ~80-120 linhas.
- Todos os arquivos seguem os padrões de nomenclatura definidos acima.
- Separação de responsabilidades: cada arquivo faz UMA coisa.

## Pós-criação

Após gerar todos os arquivos:

1. Valide que todos os nomes seguem os padrões (role-*, review-*, *_GUIDE.md, UPPER_SNAKE_CASE.md)
2. Valide que não há conteúdo de testing fora de TESTING_GUIDE
3. Valide que jarvis-plan tem smart role selection
4. Valide que CLAUDE.md tem tabela de leitura sob demanda
5. Reporte: arquivos criados, roles, reviews, guides, linhas por arquivo
