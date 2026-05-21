# Skill Creator

Generator of new project presets by technology.

## Usage

```bash
# Create new preset with stack description
../../bin/bootstrap-ai create go-service --from "Go backend with chi router, pgx, goose migrations, PostgreSQL and systemd"

# Create preset derived from similar stack
../../bin/bootstrap-ai create fastapi-backend --from "Python FastAPI with SQLAlchemy, Alembic, PostgreSQL, Redis cache and Celery"
```

## What it generates

A `presets/<name>/` directory with the full lifecycle:

```
presets/<name>/
├── CLAUDE.md                              # Main project contract
├── manifest.yaml                          # Metadata, roles, required_files, library_tags
├── plans/.gitkeep
├── .claude/
│   ├── settings.json                      # Hooks: PostToolUse → lint, Stop → jarvis-test-flow
│   └── commands/
│       ├── jarvis-plan.md                 # Unified planning (1 LLM pass)
│       ├── jarvis-test-flow.md            # E2E validation pipeline
│       ├── grill.md                       # Interactive interview
│       ├── ship.md                        # Final delivery checklist
│       ├── refactor.md                    # Incremental safe refactoring
│       ├── kickoff.md                     # Greenfield: 7 questions → brief → stack
│       ├── design-phase.md                # Design system generation
│       └── product_roles/
│           ├── role-architect.md          # Plan contributors (generative)
│           ├── role-pm.md
│           ├── review-*.md                # Perspective reviews
│           └── role-<stack-specific>.md   # Stack-specific roles
└── docs/ai/
    ├── ARCHITECTURE.md                    # Architecture and folder structure
    ├── CODING_STANDARDS.md                # Code standards
    ├── TESTING_GUIDE.md                   # Testing standards
    └── <stack-specific guides>            # API, DB, Security, etc.
```

## Development lifecycle

```
/jarvis-plan   → unified planning (grill integrated, smart role selection)
(develops)     → PostToolUse hook runs lint on every edit
/jarvis-test-flow → validates everything (via Stop hook)
/ship          → final checklist
```

## Prompt structure

- `prompts/create-new-preset.md` — Main instruction for generating the complete preset
- `prompts/derive-docs-ai.md` — Derives stack-specific `docs/ai/` guides
- `prompts/derive-roles.md` — Derives stack-specific contributor roles
- `prompts/derive-test-flow.md` — Derives stack-specific test pipeline

## Template structure

- `templates/CLAUDE.md` — Main contract template
- `templates/settings.json` — Hooks template
- `templates/preset-manifest.yaml` — Manifest template
- `templates/commands/*.md` — Command templates (jarvis-plan, test-flow, grill, etc.)
- `templates/docs-ai/*.md` — AI guide templates
