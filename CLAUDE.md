# CLAUDE.md — bootstrap-ai

## Project

Lifecycle preset repository for projects with Claude Code.

Each preset is a self-contained package that installs an operational process into a target project:

```txt
/jarvis-plan → implementation → /jarvis-test-flow → /ship
```

Presets are NOT libraries. They are sets of files that live inside the consumer project in `.claude/commands/` and `docs/ai/`.

## Repository Structure

```
bootstrap-ai/
├── CLAUDE.md                    # This file — bootstrap-ai's own contract
├── README.md                    # Public documentation
├── manifest.yaml                # Central configuration: presets, detection, defaults
├── bin/bootstrap-ai                      # Python CLI (556 lines) — detect, diff, apply, validate, create, analyze, select
├── presets/                        # Per-technology presets
│   ├── flutter-app/             # Flutter mobile — based on pacebattle_app@master
│   ├── python-backend/          # FastAPI/Python backend
│   ├── react-web/               # React web frontend
│   ├── node-backend/            # Node/TypeScript backend
│   └── fullstack-web/           # Fullstack monolith (Next.js, Remix, Nuxt, SvelteKit)
├── common/                      # Shared resources across presets
│   └── commands/                # Generic commands (grill, ship, refactor, kickoff, etc.)
├── generators/skill-creator/    # New preset generator
│   ├── prompts/                 # Instructions for creating preset, docs, roles, jarvis-test-flow
│   └── templates/               # Templates with placeholders for generating files
├── bootstrap/                   # Single-file importer
│   ├── import-project-preset.md    # Claude Code skill to import preset
│   └── import-project-preset.sh    # Alternative shell script
└── docs/                        # Diagrams and visual assets
```

## Preset Anatomy

Each preset in `presets/<name>/` contains:

```
presets/<name>/
├── CLAUDE.md                              # Consumer project contract (not this repo)
├── manifest.yaml                          # Metadata: detection, required_files, roles, library_tags
├── plans/.gitkeep
├── .claude/
│   ├── settings.json                      # Hooks: PostToolUse → lint, Stop → jarvis-test-flow
│   └── commands/
│       ├── jarvis-plan.md          # Unified planning (1 LLM pass)
│       ├── jarvis-test-flow.md     # Incremental E2E validation
│       ├── design-phase.md         # Visual design system setup
│       ├── grill.md                # Interactive alignment interview
│       ├── kickoff.md              # Project initialization
│       ├── refactor.md             # Incremental safe refactoring
│       ├── ship.md                 # Final checklist
│       └── product_roles/
│           ├── role-*.md           # Contributors: generate plan sections
│           └── review-*.md         # Contributors: generate domain sections
└── docs/ai/
    ├── ARCHITECTURE.md                    # Structure and layers
    ├── CODING_STANDARDS.md                # Code standards
    ├── TESTING_GUIDE.md                   # Testing standards
    └── <stack-specific guides>            # API, DB, Security, Design, etc.
```

## Development Lifecycle (in the consumer project)

```
/grill                      → interactive interview (standalone, opt-in)
/jarvis-plan                → unified planning (grill integrated conditionally)
(develops)                  → PostToolUse hook runs quick lint on every edit
/jarvis-test-flow           → incremental E2E validation (automatic via Stop hook)
/ship                       → final checklist (manual)
```

## CLI (bin/bootstrap-ai)

Main commands:

```bash
./bin/bootstrap-ai detect /path/to/project              # Detects project stack
./bin/bootstrap-ai analyze /path/to/project             # Detects stack + structural libraries
./bin/bootstrap-ai select /path/to/project              # Selects preset by detected stack
./bin/bootstrap-ai diff auto /path/to/project           # Shows diff without applying
./bin/bootstrap-ai apply auto /path/to/project          # Applies preset to project
./bin/bootstrap-ai apply auto /path/to/project --refresh # Applies with docs refresh
./bin/bootstrap-ai validate <preset-name>                  # Validates preset integrity
./bin/bootstrap-ai create <name> --from "description"     # Creates new preset via skill-creator
./bin/bootstrap-ai install-importer /path/to/project    # Installs single-file importer
```

Write policy:
- Missing file → create
- Identical file → skip
- Different file → create `<file>.kit-new` (never overwrites without `--force`)

## Stack Detection

Each preset has detection rules in `manifest.yaml`:

- `detects.any`: presence of any listed file
- `detects.contains`: required content in a specific file
- `detects.prefer_if`: tiebreaker between conflicting presets (e.g.: node-backend vs react-web both have package.json)

## Structural Libraries

Beyond the main stack, `analyze` detects libraries that define architecture:

- **Flutter**: dio, riverpod, go_router, freezed, drift, firebase
- **React**: tanstack-query, zustand, redux, react-router, zod, react-hook-form
- **Python**: sqlalchemy, alembic, pydantic, celery, fastapi
- **Node**: prisma, drizzle, zod

Structural library not covered by the selected preset → creates a new preset automatically via `skill-creator`.

## Quality Rules for Presets

- `jarvis-plan.md`: minimum 180 lines
- `jarvis-test-flow.md`: minimum 200 lines
- Each `role-*.md`: minimum 80 lines
- Each `docs/ai/*.md`: minimum 100 lines
- `CLAUDE.md`: minimum 80 lines
- No file can be an empty placeholder

## Role Format

Roles are contributors that generate plan sections. Each role MUST have:
- Objective (1 sentence)
- Reference (specific docs/ai it consults)
- Expected input (what it receives from the task/plan)
- Output format (template of the section it generates)
- Hard rule (absolute restriction)

## Hooks (settings.json)

Every preset has 2 hooks:

1. **PostToolUse (Edit|Write|MultiEdit)**: quick lint/typecheck of the stack on every edit
2. **Stop**: if there's a `git diff` in stack files, forces `/jarvis-test-flow` before ending

## Repository Rules

- Do not commit `.env`, `.bootstrap-ai.lock`, `.refresh-reports/` or `*.kit-new`
- Do not use `--force` on existing projects without reviewing the diff
- Do not create a preset without `manifest.yaml`, `settings.json`, `CLAUDE.md`, `jarvis-plan.md` and `jarvis-test-flow.md`
- Keep `common/` as a generic fallback — specific preset always overrides
- Every new preset must pass `./bin/bootstrap-ai validate <name>`
- `skill-creator` templates must have real content, not empty placeholders
- README.md is public documentation for consumers — CLAUDE.md is the repo's internal contract
