# Skill Creator

Gerador de novos kits de projeto por tecnologia.

## Uso

```bash
# Criar kit novo com descrição da stack
../../bin/kit create go-service --from "Go backend com chi router, pgx, goose migrations, PostgreSQL e systemd"

# Criar kit derivado de stack similar
../../bin/kit create fastapi-backend --from "Python FastAPI com SQLAlchemy, Alembic, PostgreSQL, Redis cache e Celery"
```

## O que ele gera

Um diretório `kits/<nome>/` com lifecycle completo:

```
kits/<nome>/
├── CLAUDE.md                              # Contrato principal do projeto
├── manifest.yaml                          # Metadados, roles, required_files, library_tags
├── plans/.gitkeep
├── .claude/
│   ├── settings.json                      # Hooks: ExitPlanMode → jarvis-plan-revisor, Stop → jarvis-test-flow
│   ├── commands/
│   │   ├── carregar-contexto-projeto.md   # Context loader automático
│   │   ├── jarvis-plan-revisor.md         # Revisão multi-role de planos
│   │   ├── plan.md                        # Criação de planos técnicos
│   │   ├── refactor.md                    # Refatoração segura incremental
│   │   ├── ship.md                        # Checklist final de entrega
│   │   ├── jarvis-test-flow.md             # Pipeline de validação E2E
│   │   └── product_roles/
│   │       ├── carregar-referencias.md    # Helper: carrega docs por relevância
│   │       ├── consolidar-parecer.md      # Helper: consolida pareceres
│   │       ├── gerar-relatorio.md         # Helper: gera relatório final
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
/jarvis-plan-revisor → revisa plano contra docs/ai e roles (via hook ExitPlanMode)
(desenvolve)
/jarvis-test-flow  → valida tudo antes de commitar (via hook Stop)
/ship          → checklist final
```

## Estrutura dos prompts

- `prompts/create-new-kit.md` — Instrução principal para gerar o kit completo
- `prompts/derive-docs-ai.md` — Deriva guias `docs/ai/` específicos da stack
- `prompts/derive-roles.md` — Deriva roles de revisão específicos da stack
- `prompts/derive-jarvis-test-flow.md` — Deriva pipeline de teste específico da stack

## Estrutura dos templates

- `templates/CLAUDE.md` — Template do contrato principal
- `templates/settings.json` — Template dos hooks
- `templates/kit-manifest.yaml` — Template do manifest
- `templates/commands/*.md` — Templates dos comandos
- `templates/commands/product_roles/*.md` — Templates dos helpers
- `templates/docs-ai/*.md` — Templates dos guias AI
