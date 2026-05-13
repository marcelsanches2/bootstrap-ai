# Skill Creator: Create New Project Kit

Crie um kit completo para uma nova tecnologia.

## Input

O usuário forneceu:
- **Nome do kit**: `{{KIT_NAME}}`
- **Descrição da stack**: `{{DESCRIPTION}}`

## Referência

Antes de gerar, leia os kits existentes para entender o padrão:

1. `kits/flutter-app/` — kit mobile com Figma comparison, design system, E2E
2. `kits/python-backend/` — kit backend com API, DB, security, scalability
3. `kits/react-web/` — kit frontend com design system, accessibility, performance
4. `kits/node-backend/` — kit backend com TypeScript, tipagem, migrations

Use o kit mais similar à stack descrita como base primária. Adapte de lá.

## Estrutura obrigatória

Gere TODOS os arquivos abaixo. Nenhum pode ficar vazio ou placeholder.

### Arquivos raiz

1. **`CLAUDE.md`** — Use o template `templates/CLAUDE.md` e preencha:
   - Nome do projeto com `{{PROJECT_NAME}}`
   - Stack principal (framework, linguagem, ORM, ferramentas)
   - Tabela de leitura sob demanda com os docs/ai gerados
   - Prioridade atual
   - Regras obrigatórias específicas da stack
   - Processo (antes/depois de alterar)
   - Princípio de decisão

2. **`manifest.yaml`** — Use o template `templates/kit-manifest.yaml` e preencha:
   - `name`, `description`
   - `required_files`: todos os arquivos gerados
   - `library_tags`: bibliotecas estruturais da stack que devem forçar este kit
   - `roles`: lista de todos os role-*.md gerados

3. **`plans/.gitkeep`** — Vazio.

### .claude/settings.json

4. Use o template `templates/settings.json` e adapte:
   - `PostToolUse` (Edit|Write|MultiEdit): comando de lint/typecheck da stack
   - `PostToolUse` (ExitPlanMode): trigger do jarvis-revisor
   - `Stop`: detecta mudanças em arquivos da stack e força /test-flow
   - `permissions.deny`: manter padrão (.env, rm -rf, git push --force)

### .claude/commands/ (comandos do lifecycle)

5. **`carregar-contexto-projeto.md`** — Copiar de `templates/commands/carregar-contexto-projeto.md` (genérico, não muda por stack).

6. **`jarvis-revisor.md`** — Use o kit mais similar como base. Adapte:
   - Lista de docs/ai a carregar
   - Lista de roles a executar
   - Regras de bloqueio específicas da stack
   - Formato do relatório com pareceres adequados

7. **`plan.md`** — Copiar de `templates/commands/plan.md` (genérico).

8. **`refactor.md`** — Use o kit mais similar como base. Adapte:
   - Seção "Regras específicas <stack>" com validações específicas

9. **`ship.md`** — Copiar de `templates/commands/ship.md` (genérico).

10. **`test-flow.md`** — Use `prompts/derive-test-flow.md` para gerar. Deve ter o mesmo nível de detalhe dos kits existentes (~9000+ chars).

### .claude/commands/product_roles/ (helpers + roles)

11. **Helpers** (copiar diretamente dos templates, são idênticos para toda stack):
    - `carregar-referencias.md`
    - `consolidar-parecer.md`
    - `gerar-relatorio.md`
    - `localizar-plano.md`

12. **Roles** (usar `prompts/derive-roles.md` para gerar):
    - Pelo menos: arquiteto, PM, QA, delivery
    - Se for backend: API, DB, security, observability, scalability
    - Se for frontend: designer, accessibility, performance
    - Se for mobile: designer, QA-E2E específico

    Cada role DEVE ter:
    - Objetivo
    - Fonte de referência (docs/ai específicos)
    - Entrada esperada
    - Método
    - Checklist obrigatório (itens marcáveis [OK/PENDÊNCIA])
    - Resultado esperado por item
    - Saída em Markdown
    - Regra dura
    - Classificação forçada: OK / OK — não aplicável / PENDÊNCIA (com severidade, evidência, correção concreta)

### docs/ai/ (guias AI)

13. Use `prompts/derive-docs-ai.md` para gerar TODOS os guias. Mínimo obrigatório:
    - `ARCHITECTURE.md`
    - `CODING_STANDARDS.md`
    - `TESTING_GUIDE.md`
    
    Adicionais por tipo:
    - Backend: `API_GUIDE.md`, `DATABASE_GUIDE.md`, `SECURITY_GUIDE.md`, `OBSERVABILITY_GUIDE.md`, `SCALABILITY_GUIDE.md`, `DEPLOYMENT_GUIDE.md`
    - Frontend: `DESIGN_SYSTEM.md`, `ACCESSIBILITY_GUIDE.md`, `PERFORMANCE_GUIDE.md`, `DEPLOYMENT_GUIDE.md`
    - Mobile: `DESIGN_SYSTEM.md`, `FEATURE_GUIDE.md`

## Qualidade mínima

- Nenhum arquivo pode ter apenas título ou "TODO".
- Cada arquivo deve ter conteúdo substancial comparável aos kits existentes.
- Roles devem ter pelo menos 80 linhas cada.
- Docs AI devem ter pelo menos 100 linhas cada.
- test-flow deve ter pelo menos 200 linhas.
- jarvis-revisor deve ter pelo menos 200 linhas.
- CLAUDE.md deve ter pelo menos 80 linhas.
