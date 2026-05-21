<div align="center">

<img src="banner.png" alt="Bootstrap AI" width="100%" />

# Bootstrap AI

**Ship AI-powered projects with structure, not chaos.**

[![GitHub stars](https://img.shields.io/github/stars/marcelsanches2/bootstrap-ai?style=social)](https://github.com/marcelsanches2/bootstrap-ai/stargazers)
[![License: AGPLv3](https://img.shields.io/badge/license-AGPLv3-blue)](./LICENSE)
[![Presets](https://img.shields.io/badge/presets-5-blueviolet)](./presets)
[![CLI](https://img.shields.io/badge/cli-bootstrap--ai-orange)](./bin/bootstrap-ai)

*A CLI + preset system that turns empty folders into production-ready projects — and brings structure to existing ones. Built for [Claude Code](https://docs.anthropic.com/en/docs/claude-code)*

</div>

---

## What is it?

Bootstrap AI gives your AI assistant a project-specific brain. Instead of starting every session from scratch, you apply a **preset** — a curated set of commands, configurations, documentation, and hooks — that tells your assistant exactly how the project is structured, which conventions to follow, and which workflows to enforce.

**Presets are in [Claude Code](https://docs.anthropic.com/en/docs/claude-code) format** — they install into `.claude/commands/` and `.claude/settings.json`.

---

## Getting Started

```bash
# Clone Bootstrap AI (once)
git clone https://github.com/marcelsanches2/bootstrap-ai.git /tmp/bootstrap-ai
cd /tmp/bootstrap-ai

# Install the importer into your project
./bin/bootstrap-ai install-importer /path/to/your/project
```

Then, inside Claude Code:

```
/import-project-preset
```

**That's it.** The system detects your stack and applies the correct preset automatically.

| Situation | What happens |
|----------|---------------|
| **Empty folder** | Redirects to `/kickoff` — 7 questions → product brief → stack selection → design system → preset applied |
| **Existing project** | Detects stack + libs → selects preset → applies with safe write policy → customizes guides with project libs |

After applying, you enter the development cycle:

```
/jarvis-plan → implement → /jarvis-test-flow → /ship
```

> **💡 Existing project?** After importing, run `/refactor` to align the actual code with the preset standards.

---

## How the Importer Works

<img src="docs/flow-diagram.png" alt="Import Project Preset Flow" width="100%" />

When you run `/import-project-preset`, the system:

1. **Detects** your stack by scanning signature files (`pubspec.yaml`, `package.json`, `pyproject.toml`, etc.)
2. **Routes** based on folder state:
   - **Empty folder** → redirects to `/kickoff` (7 questions → product brief → stack selection → `/design-phase` → apply preset)
   - **Has code** → analyzes structural libs → auto-selects preset → applies with safe write policy
3. **Syncs Design System** — if the project already has color, typography, or spacing tokens, `DESIGN_SYSTEM.md` is rewritten with the project's real visual identity
4. **Customizes guides with detected libraries** — ARCHITECTURE.md, CODING_STANDARDS.md, DATABASE_GUIDE.md etc. are enriched with patterns specific to the libraries the project actually uses

---

## Presets

| Preset | Stack | Description |
|--------|-------|-------------|
| `flutter-app` | Flutter / Dart | Mobile app with state management, routing, and testing conventions |
| `react-web` | React / TypeScript / Vite | SPA frontend with component architecture and design system integration |
| `node-backend` | Node / TypeScript / Express | REST API backend with middleware, validation, and error handling patterns |
| `python-backend` | Python / FastAPI | Async API backend with dependency injection, schemas, and tests |
| `fullstack-web` | Next.js / Remix / Nuxt / SvelteKit | Fullstack monolith with SSR, API routes, and integrated frontend |

Each preset installs:

```
CLAUDE.md                      # Project context & AI instructions
.claude/settings.json          # Claude Code configuration
.claude/commands/*             # Slash commands for workflows
docs/ai/*                      # AI workflow documentation
plans/.gitkeep                 # Plan tracking directory
.bootstrap-ai.lock             # Applied preset lockfile
```

Template variables like `{{PROJECT_NAME}}` are automatically substituted during apply.

---

## Commands & Skills

### Lifecycle Workflow

The main development loop — run in sequence:

| Command | Purpose |
|---------|---------|
| `/jarvis-plan` | Generates an implementation plan for the current task |
| *(implement)* | Code following the plan using normal Claude Code editing |
| `/jarvis-test-flow` | Runs the full test suite and fixes failures |
| `/ship` | Finalizes: reviews, commits, and pushes |

### Manual Commands

| Command | Purpose |
|---------|---------|
| `/jarvis-revisor` | Global project audit — reviews quality and suggests improvements |
| `/jarvis-full-test` | Full regression — runs test suite outside the lifecycle |
| `/refactor` | Structured refactoring workflow |
| `/import-project-preset` | Detects stack and applies or creates a preset |
| `/kickoff` | Greenfield flow: 7 questions → product brief → stack selection |
| `/design-phase` | Design system generation (import from Figma or AI-generated) |

### Hooks (Automatic)

Hooks run at specific points during your AI session without manual invocation:

| Hook | Trigger | Behavior |
|------|---------|----------|
| `PostToolUse` | After any tool call | Runs lint checks |
| `Stop` | When the agent stops | Auto-triggers `/jarvis-test-flow` |

---

## CLI Reference

The `bin/bootstrap-ai` CLI gives direct access to all operations:

```bash
# Detect the project stack
bin/bootstrap-ai detect

# Analyze structural libraries and patterns
bin/bootstrap-ai analyze

# Select the most suitable preset
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

Create your own preset from scratch using the skill-creator:

```bash
bin/bootstrap-ai create my-preset --from "SvelteKit app with Tailwind CSS and Drizzle ORM"
```

This generates a new preset directory with all required files, ready to customize and apply.

---

## How It Works

### Stack Detection

Each preset includes a `manifest.yaml` with detection rules:

```yaml
detects:
  any: ["pubspec.yaml"]           # Any of these files → match
  contains:
    pubspec.yaml: "flutter"       # File must contain this string
  prefer_if: ["lib/main.dart"]   # Confidence boost if they exist
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
|----------|--------|
| File doesn't exist | Create |
| File is identical to preset | Skip (no-op) |
| File differs from preset | Create `.kit-new` copy for review |

This makes it safe to reapply presets or update to newer versions.

---

## Contributing

Contributions are welcome. To add a new preset or improve an existing one:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-preset`)
3. Build your preset using `bin/bootstrap-ai create <name> --from "description"` or manually
4. Test with `bin/bootstrap-ai validate`
5. Open a pull request

Make sure presets include:
- A complete `manifest.yaml` with detection rules
- All required files (`CLAUDE.md`, `.claude/settings.json`, commands, docs)
- Template variables where appropriate (`{{PROJECT_NAME}}`)

---

## License

This project is licensed under the [AGPLv3 License](./LICENSE).

---

<div align="center">

**[⬆ Star this repo](https://github.com/marcelsanches2/bootstrap-ai/stargazers)** if you found it useful.

Built for the AI-assisted development workflow. Not a framework — a foundation.

</div>
