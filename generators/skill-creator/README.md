# Skill Creator

Gerador de novos presets de projeto por tecnologia.

## Uso

```bash
# Criar preset novo com descrição da stack
../../bin/bootstrap-ai create go-service --from "Go backend com chi router, pgx, goose migrations, PostgreSQL e systemd"

# Criar preset derivado de stack similar
../../bin/bootstrap-ai create fastapi-backend --from "Python FastAPI com SQLAlchemy, Alembic, PostgreSQL, Redis cache e Celery"
```

## O que ele gera

Um diretório `presets/<nome>/` com lifecycle completo:

```
presets/<nome>/
├── CLAUDE.md                              # Contrato principal do projeto
├── manifest.yaml                          # Metadados, roles, required_files, library_tags
├── plans/.gitkeep
├── .claude/
│   ├── settings.json                      # Hooks: PostToolUse → lint, Stop → jarvis-test-flow
│   ├── commands/
│   │   ├── jarvis-plan.md                 # Planejamento unificado (1 pass de LLM)
│   │   ├── refactor.md                    # Refatoração segura incremental
│   │   ├── ship.md                        # Checklist final de entrega
│   │   ├── jarvis-test-flow.md            # Pipeline de validação E2E
│   │   └── product_roles/
│   │       ├── carregar-referencias.md    # Helper: carrega docs por relevância
│   │       ├── localizar-plano.md         # Helper: localiza plano em plans/
│   │       ├── role-<stack-specific>.md   # Roles derivados da stack
│   │       └── ...
│   └── scripts/                           # Scripts auxiliares (se aplicável)
└── docs/ai/
    ├── ARCHITECTURE.md                    # Arquitetura e estrutura de pastas
    ├── CODING_STANDARDS.md                # Padrões de código
    ├── TESTING_GUIDE.md                   # Padrões de teste
    └── <stack-specific guides>            # API, DB, Security, etc.
```

## Lifecycle de desenvolvimento

```
/plan          → cria plano técnico
/jarvis-plan   → planejamento unificado (com smart role selection)
(desenvolve)
/jarvis-test-flow  → valida tudo antes de commitar (via hook Stop)
/ship          → checklist final
```

## Estrutura dos prompts

- `prompts/create-new-preset.md` — Instrução principal para gerar o preset completo
- `prompts/derive-docs-ai.md` — Deriva guias `docs/ai/` específicos da stack
- `prompts/derive-roles.md` — Deriva roles de revisão específicos da stack
- `prompts/derive-test-flow.md` — Deriva pipeline de teste específico da stack

## Estrutura dos templates

- `templates/CLAUDE.md` — Template do contrato principal
- `templates/settings.json` — Template dos hooks
- `templates/preset-manifest.yaml` — Template do manifest
- `templates/commands/*.md` — Templates dos comandos
- `templates/commands/product_roles/*.md` — Templates dos helpers
- `templates/docs-ai/*.md` — Templates dos guias AI
