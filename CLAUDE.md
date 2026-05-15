# CLAUDE.md — bootstrap-ai

## Projeto

Repositório de presets de lifecycle para projetos com Claude Code.

Cada preset é um pacote autocontido que instala processo operacional em um projeto alvo:

```txt
/plan → /jarvis-plan-revisor → implementação → /jarvis-test-flow → /ship
```

Os presets NÃO são bibliotecas. São conjuntos de arquivos que vivem dentro do projeto consumidor em `.claude/commands/` e `docs/ai/`.

## Estrutura do repositório

```
bootstrap-ai/
├── CLAUDE.md                    # Este arquivo — contrato do próprio bootstrap-ai
├── README.md                    # Documentação pública
├── manifest.yaml                # Configuração central: presets, detecção, defaults
├── bin/bootstrap-ai                      # CLI Python (556 linhas) — detect, diff, apply, validate, create, analyze, select
├── presets/                        # Presets por tecnologia
│   ├── flutter-app/             # Mobile Flutter — baseado no pacebattle_app@master
│   ├── python-backend/          # FastAPI/Python backend
│   ├── react-web/               # React web frontend
│   └── node-backend/            # Node/TypeScript backend
├── common/                      # Recursos compartilhados entre presets
│   ├── commands/                # Comandos genéricos (jarvis-plan-revisor, jarvis-revisor, plan, ship, refactor)
│   ├── docs.ai/                 # Docs AI genéricos (OPERATING_MODEL, CODING_STANDARDS, etc.)
│   └── roles/                   # Roles genéricos (arquiteto, designer, pm, test, security, etc.)
├── generators/skill-creator/    # Gerador de novos presets
│   ├── prompts/                 # Instruções para criação de preset, docs, roles, jarvis-test-flow
│   └── templates/               # Templates com placeholders para gerar arquivos
├── bootstrap/                   # Importer de arquivo único
│   ├── import-project-preset.md    # Skill Claude Code para importar preset
│   └── import-project-preset.sh    # Script shell alternativo
└── refreshers/                  # Configs de refresh por stack (yaml)
```

## Anatomia de um preset

Cada preset em `presets/<nome>/` contém:

```
presets/<nome>/
├── CLAUDE.md                              # Contrato do projeto consumidor (não deste repo)
├── manifest.yaml                          # Metadados: detecção, required_files, roles, library_tags
├── plans/.gitkeep
├── .claude/
│   ├── settings.json                      # Hooks: ExitPlanMode → jarvis-plan-revisor, Stop → jarvis-test-flow
│   └── commands/
│       ├── jarvis-plan-revisor.md              # Revisão multi-role de planos (~200+ linhas)
│       ├── jarvis-test-flow.md                   # Pipeline de validação E2E (~200+ linhas)
│       ├── jarvis-revisor.md                     # Auditoria global do projeto (manual)
│       ├── jarvis-full-test.md                   # Regressão completa (manual)
│       ├── plan.md                        # Criação de planos técnicos
│       ├── refactor.md                    # Refatoração segura incremental
│       ├── ship.md                        # Checklist final
│       ├── carregar-contexto-projeto.md   # Context loader automático
│       └── product_roles/
│           ├── carregar-referencias.md    # Helper: carrega docs por relevância
│           ├── consolidar-parecer.md      # Helper: consolida pareceres com severidade
│           ├── gerar-relatorio.md         # Helper: gera relatório final
│           ├── localizar-plano.md         # Helper: localiza plano em plans/
│           └── role-<stack-specific>.md   # Roles de revisão específicos (~80+ linhas cada)
└── docs/ai/
    ├── ARCHITECTURE.md                    # Estrutura e camadas
    ├── CODING_STANDARDS.md                # Padrões de código
    ├── TESTING_GUIDE.md                   # Padrões de teste
    └── <stack-specific guides>            # API, DB, Security, Design, etc.
```

## Lifecycle de desenvolvimento (no projeto consumidor)

```
/plan             → cria plano em plans/YYYY-MM-DD-slug.md
/jarvis-plan-revisor → revisa plano contra docs/ai e roles (hook ExitPlanMode dispara automaticamente)
(desenvolve)      → hook PostToolUse roda lint rápido a cada edição
/jarvis-test-flow  → pipeline completo antes de commitar (hook Stop dispara se houver diff)
/jarvis-revisor    → auditoria global do projeto (manual, sob demanda)
/jarvis-full-test  → regressão completa do projeto (manual, sob demanda)
/ship             → checklist final
```

## CLI (bin/bootstrap-ai)

Comandos principais:

```bash
./bin/bootstrap-ai detect /path/do/projeto              # Detecta stack do projeto
./bin/bootstrap-ai analyze /path/do/projeto             # Detecta stack + bibliotecas estruturais
./bin/bootstrap-ai select /path/do/projeto              # Seleciona preset por stack detectada
./bin/bootstrap-ai diff auto /path/do/projeto           # Mostra diff sem aplicar
./bin/bootstrap-ai apply auto /path/do/projeto          # Aplica preset no projeto
./bin/bootstrap-ai apply auto /path/do/projeto --refresh # Aplica com refresh dos docs
./bin/bootstrap-ai validate <preset-name>                  # Valida integridade de um preset
./bin/bootstrap-ai create <nome> --from "descrição"     # Cria novo preset via skill-creator
./bin/bootstrap-ai install-importer /path/do/projeto    # Instala importer de arquivo único
```

Política de escrita:
- Arquivo ausente → cria
- Arquivo igual → ignora
- Arquivo diferente → cria `<arquivo>.kit-new` (nunca sobrescreve sem `--force`)

## Detecção de stack

Cada preset tem regras de detecção no `manifest.yaml`:

- `detects.any`: presença de qualquer arquivo listado
- `detects.contains`: conteúdo obrigatório em arquivo específico
- `detects.prefer_if`: desempate entre presets conflitantes (ex: node-backend vs react-web ambos têm package.json)

## Bibliotecas estruturais

Além da stack principal, o `analyze` detecta bibliotecas que definem arquitetura:

- **Flutter**: dio, riverpod, go_router, freezed, drift, firebase
- **React**: tanstack-query, zustand, redux, react-router, zod, react-hook-form
- **Python**: sqlalchemy, alembic, pydantic, celery, fastapi
- **Node**: prisma, drizzle, zod

Biblioteca estrutural não coberta pelo preset selecionado → cria preset novo automaticamente via `skill-creator`.

## Regras de qualidade para presets

- `jarvis-plan-revisor.md`: mínimo 200 linhas
- `jarvis-test-flow.md`: mínimo 200 linhas
- `jarvis-revisor.md`: mínimo 100 linhas
- `jarvis-full-test.md`: mínimo 100 linhas
- Cada `role-*.md`: mínimo 80 linhas
- Cada `docs/ai/*.md`: mínimo 100 linhas
- `CLAUDE.md`: mínimo 80 linhas
- Nenhum arquivo pode ser placeholder vazio

## Formato dos roles

Cada role DEVE ter:
- Objetivo (1 frase)
- Fonte de referência (docs/ai específicos)
- Entrada esperada
- Método
- Checklist obrigatório (itens marcáveis)
- Resultado esperado por item (OK / OK — não aplicável / PENDÊNCIA com severidade + evidência + correção)
- Saída em Markdown
- Regra dura

## Hooks (settings.json)

Todo preset tem 3 hooks:

1. **PostToolUse (Edit|Write|MultiEdit)**: lint/typecheck rápido da stack
2. **ExitPlanMode**: dispara `/jarvis-plan-revisor` automaticamente quando plano é aceito
3. **Stop**: se houver `git diff` em arquivos da stack, força `/jarvis-test-flow` antes de encerrar

## Regras deste repositório

- Não commitar `.env`, `.bootstrap-ai.lock`, `.refresh-reports/` ou `*.kit-new`
- Não usar `--force` em projetos existentes sem revisar diff
- Não criar preset sem `manifest.yaml`, `settings.json`, `CLAUDE.md`, `jarvis-plan-revisor.md`, `jarvis-test-flow.md`, `jarvis-revisor.md` e `jarvis-full-test.md`
- Manter `common/` como fallback genérico — preset específico sempre sobrepõe
- Todo preset novo deve passar em `./bin/bootstrap-ai validate <nome>`
- Templates do `skill-creator` devem ter conteúdo real, não placeholder vazio
- README.md é documentação pública para consumidores — CLAUDE.md é contrato interno do repo
