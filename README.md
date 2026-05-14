<div align="center">

<img src="banner.png" alt="Bootstrap AI" width="100%" />

# Bootstrap AI

**Ship AI-powered projects with structure, not chaos.**

[![GitHub stars](https://img.shields.io/github/stars/marcelsanches2/bootstrap-ai?style=social)](https://github.com/marcelsanches2/bootstrap-ai/stargazers)
[![License](https://img.shields.io/github/license/marcelsanches2/bootstrap-ai?color=blue)](./LICENSE)
[![Presets](https://img.shields.io/badge/presets-4-blueviolet)](./kits)
[![CLI](https://img.shields.io/badge/cli-bootstrap--ai-orange)](./bin/bootstrap-ai)

*A CLI + preset system that turns empty folders into production-ready projects — and brings structure to existing ones. Designed for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and [Hermes Agent](https://hermes-agent.nousresearch.com).*

</div>

---

## What is it?

Bootstrap AI gives your AI coding assistant a project-specific brain. Instead of starting every session from scratch, you apply a **preset** — a curated set of commands, configurations, documentation scaffolds, and hooks — that tells your AI assistant exactly how your project is structured, what conventions to follow, and which workflows to enforce.

**Presets are built in [Claude Code](https://docs.anthropic.com/en/docs/claude-code) format** — they install into `.claude/commands/` and `.claude/settings.json`.


---

## Setup

Install the `/import-project-preset` command into your project:

```bash
# Clone Bootstrap AI (one-time)
git clone https://github.com/marcelsanches2/bootstrap-ai.git /tmp/bootstrap-ai
cd /tmp/bootstrap-ai

# Install the importer into your project
./bin/bootstrap-ai install-importer /path/to/your/project
```

This creates `.claude/commands/import-project-preset.md` in your project. Then run:

```
/import-project-preset
```

The command detects your stack, selects the best matching preset, and applies it with a safe write policy — no files overwritten.

---

## How the importer works

<img src="docs/flow-diagram.png" alt="Import Project Preset Flow" width="100%" />

When you run `/import-project-preset`, the system:

1. **Detects** your stack by scanning for signature files (`pubspec.yaml`, `package.json`, `pyproject.toml`, etc.)
2. **Analyzes** structural libraries (Riverpod, TanStack Query, Prisma, SQLAlchemy, etc.)
3. **Branches** based on folder state:
   - **Empty folder** → redirects to `/kickoff` (7 questions → product brief → stack selection → `/design-phase` → preset apply)
   - **Has code** → auto-selects matching preset → shows diff preview → applies with safe write policy
4. **Result** — your project is scaffolded and ready for the development lifecycle

---

## Quick Start — New Project

Starting from an empty folder? Bootstrap AI runs you through a full greenfield flow: define your product, pick a stack, generate a design system, and apply the right preset.

```bash
mkdir my-project && cd my-project
git init
```

Then, inside Claude Code or Hermes Agent, run:

```
/import-project-preset
```

Bootstrap AI detects an empty folder and redirects you to `/kickoff`, which walks through:

1. **7 questions** about your product → generates `PRODUCT_BRIEF.md`
2. **Stack selection** → choose from supported presets
3. **`/design-phase`** → extract from a Figma Make link or generate an AI design system
4. **Preset apply** → your project is scaffolded and ready

Now you're in the lifecycle loop:

```
/plan → /jarvis-plan-revisor → implement → /jarvis-test-flow → /ship
```

---

## Quick Start — Existing Project

Already have a codebase? Bootstrap AI detects your stack and applies a preset non-destructively.

```
/import-project-preset
```

That's it. The CLI:

1. **Detects** your stack via `manifest.yaml` rules
2. **Analyzes** structural libraries (Riverpod, TanStack Query, Prisma, etc.)
3. **Selects** the best matching preset
4. **Applies** files using a safe write policy (see below)

No files are overwritten. If a file differs from the preset, a `.kit-new` copy is created for you to review.

---

## Presets

| Preset | Stack | Description |
|--------|-------|-------------|
| `flutter-app` | Flutter / Dart | Mobile app with state management, routing, and testing conventions |
| `react-web` | React / TypeScript / Vite | Frontend SPA with component architecture and design system integration |
| `node-backend` | Node / TypeScript / Express | REST API backend with middleware patterns, validation, and error handling |
| `python-backend` | Python / FastAPI | Async API backend with dependency injection, schemas, and testing |

Each preset installs:

```
CLAUDE.md                      # Project context & AI instructions
.claude/settings.json          # Claude Code configuration
.claude/commands/*             # Slash commands for workflows
docs/ai/*                      # AI workflow documentation
plans/.gitkeep                 # Plan tracking directory
.bootstrap-ai.lock             # Applied preset lockfile
```

Template variables like `{{PROJECT_NAME}}` are substituted automatically during apply.

---

## Commands & Skills

### Lifecycle Workflow

The core development loop — run these in sequence:

| Command | Purpose |
|---------|---------|
| `/plan` | Generate an implementation plan for the current task |
| `/jarvis-plan-revisor` | Review and improve the plan before implementation |
| *(implement)* | Code against the plan using normal Claude Code editing |
| `/jarvis-test-flow` | Run the full test suite and fix failures |
| `/ship` | Finalize: review, commit, and push |

### Manual Commands

| Command | Purpose |
|---------|---------|
| `/jarvis-revisor` | Review code quality and suggest improvements |
| `/jarvis-full-test` | Run comprehensive test suite outside the lifecycle |
| `/refactor` | Structured refactoring workflow |
| `/import-project-preset` | Detect stack and apply or create a preset |
| `/kickoff` | Greenfield flow: 7 questions → product brief → stack selection |
| `/design-phase` | Design system generation (Figma import or AI-generated) |

### Hooks (Automatic)

Hooks run at specific points during your AI session without manual invocation:

| Hook | Trigger | Behavior |
|------|---------|----------|
| `PostToolUse` | After any tool call | Runs linting checks |
| `ExitPlanMode` | When leaving plan mode | Auto-triggers `/jarvis-plan-revisor` |
| `Stop` | When the agent stops | Auto-triggers `/jarvis-test-flow` |

---

## CLI Reference

The `bin/bootstrap-ai` CLI provides direct access to all operations:

```bash
# Detect the project's stack
bin/bootstrap-ai detect

# Analyze structural libraries and patterns
bin/bootstrap-ai analyze

# Select the best matching preset
bin/bootstrap-ai select

# Preview changes without applying
bin/bootstrap-ai diff

# Apply a preset to the current project
bin/bootstrap-ai apply

# Validate an applied preset
bin/bootstrap-ai validate

# Create a new preset from a description
bin/bootstrap-ai create <name> --from "description"

# Install the /import-project-preset command globally
bin/bootstrap-ai install-importer
```

### Creating Custom Presets

Build your own preset from scratch using the skill-creator:

```bash
bin/bootstrap-ai create my-preset --from "A SvelteKit app with Tailwind CSS and Drizzle ORM"
```

This generates a new preset directory with all required files, ready to customize and apply.

---

## How It Works

### Stack Detection

Each preset ships a `manifest.yaml` with detection rules:

```yaml
detects:
  any: ["pubspec.yaml"]           # Any of these files → match
  contains:
    pubspec.yaml: "flutter"       # File must contain this string
  prefer_if: ["lib/main.dart"]   # Boost confidence if these exist
```

The CLI scores each preset against your project and selects the best match.

### Structural Library Detection

The `analyze` command goes deeper — it detects libraries and patterns that affect project structure:

- **Flutter**: Riverpod, BLoC, GetX
- **React**: TanStack Query, Zustand, React Router
- **Node**: Prisma, TypeORM, Mongoose
- **Python**: SQLAlchemy, Alembic, Pydantic

This analysis feeds into which commands and conventions the preset enables.

### Write Policy

When applying a preset, Bootstrap AI never overwrites your work:

| Condition | Action |
|-----------|--------|
| File missing | Create it |
| File identical to preset | Skip (no-op) |
| File differs from preset | Create `.kit-new` copy for review |

This makes it safe to re-apply presets or update to newer versions.

---

## Contributing

Contributions are welcome. To add a new preset or improve an existing one:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-preset`)
3. Build your preset using `bin/bootstrap-ai create <name> --from "description"` or manually
4. Test with `bin/bootstrap-ai validate`
5. Open a pull request

Please ensure presets include:
- A complete `manifest.yaml` with detection rules
- All required files (`CLAUDE.md`, `.claude/settings.json`, commands, docs)
- Template variables where appropriate (`{{PROJECT_NAME}}`)

---

## License

This project is licensed under the [AGPLv3 License](./LICENSE).

---

<div align="center">

**[⬆ Star this repo](https://github.com/marcelsanches2/bootstrap-ai/stargazers)** if you find it useful.

Built for the AI-assisted development workflow. Not a framework — a foundation.

</div>
