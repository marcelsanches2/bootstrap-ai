---
name: import-project-preset
description: Imports the correct bootstrap-ai into the current project non-destructively.
---

# /import-project-preset

Imports the correct preset from the `marcelsanches2/bootstrap-ai` repository into the current project.

This file is designed to be copied on its own to a new/existing project at:

```txt
.claude/commands/import-project-preset.md
```

Then run in Claude Code:

```txt
/import-project-preset
```

## Objective

1. Find the root of the current project.
2. Ensure the `bootstrap-ai` repo exists locally.
3. Update the `bootstrap-ai` repo.
4. Analyze the project's actual stack.
5. Validate whether any preset covers all detected core technologies.
6. If coverage is missing, create a new preset specific to the project's scenario.
7. Show a diff of what will be imported.
8. Apply the preset in non-destructive mode.
9. Verify that core files were installed.

## Hard Rules

- Never overwrite existing files silently.
- Do not use `--force`.
- If there is a conflict, accept `.kit-new` creation.
- Do not commit automatically.
- Do not modify production code.
- Do not run `/refactor` automatically; only explain that it is the optional next step.

## Mandatory Procedure

### 0. Find the bootstrap-ai local directory — EXECUTE FIRST

**Before ANY other step**, read the last line of this file. It contains an HTML comment with the absolute path of the bootstrap-ai repo from which this importer was installed:

```
<!-- BOOTSTRAP_AI_SOURCE: /absolute/path/to/bootstrap-ai -->
```

**Immediate action:**

1. Read the content of the last line of this file
2. Extract the path after `BOOTSTRAP_AI_SOURCE: `
3. Verify the directory exists and has an executable `bin/bootstrap-ai`:

```bash
BOOTSTRAP_AI_DIR=$(grep -oP 'BOOTSTRAP_AI_SOURCE: \K[^\s>-]+' "$(dirname "$0")/import-project-preset.md" 2>/dev/null || echo "")
if [ -z "$BOOTSTRAP_AI_DIR" ]; then
  # Fallback: the file we are currently executing
  BOOTSTRAP_AI_DIR=$(grep -oP 'BOOTSTRAP_AI_SOURCE: \K[^\s>-]+' "$0" 2>/dev/null || echo "")
fi
if [ -n "$BOOTSTRAP_AI_DIR" ] && [ -x "$BOOTSTRAP_AI_DIR/bin/bootstrap-ai" ]; then
  echo "✅ Local bootstrap-ai found: $BOOTSTRAP_AI_DIR"
  echo "   Skipping workspace search — using local directory."
else
  echo "❌ Embedded source invalid or missing. Proceeding with search."
  BOOTSTRAP_AI_DIR=""
fi
```

**If `BOOTSTRAP_AI_DIR` was set:** skip straight to step 3 (update). The repo already exists locally — **DO NOT search workspaces, DO NOT clone from GitHub.**

**If `BOOTSTRAP_AI_DIR` is empty:** continue to step 2.

### 1. Resolve project root and detect state

Run:

```bash
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
printf 'Project root: %s\n' "$ROOT"
```

**Detect if it's an empty folder (new project):**

```bash
# Count relevant files (excluding .git and hidden)
FILE_COUNT=$(find "$ROOT" -maxdepth 1 -type f ! -name '.*' | wc -l)
DIR_COUNT=$(find "$ROOT" -maxdepth 1 -type d ! -name '.*' ! -name "$(basename "$ROOT")" | wc -l)
HAS_STACK=false
for f in pubspec.yaml package.json pyproject.toml requirements.txt go.mod Gemfile Cargo.toml pom.xml build.gradle; do
  if [ -f "$ROOT/$f" ]; then HAS_STACK=true; break; fi
done

if [ "$FILE_COUNT" -eq 0 ] && [ "$DIR_COUNT" -eq 0 ] && [ "$HAS_STACK" = false ]; then
  printf 'Empty folder detected. This is a new project.\n'
  printf 'Redirecting to /kickoff (full onboarding).\n\n'
  printf 'Load the /kickoff command from the preset and execute it.\n'
  printf '/kickoff will:\n'
  printf '  1. Collect requirements (7 questions)\n'
  printf '  2. Generate PRODUCT_BRIEF.md\n'
  printf '  3. Decide the stack\n'
  printf '  4. Offer design phase (if frontend)\n'
  printf '  5. Apply the correct preset\n\n'
  printf 'After /kickoff completes, this command will already have been executed.\n'
  # STOP HERE — do not continue the steps below
  return
fi
```

If the folder is **not** empty, continue normally to step 2.

### 2. Locate or clone `bootstrap-ai`

Search in this order (test both names `bootstrap-ai` and `bootstrap-ai`):

```bash
# 1. Explicit environment variable
$BOOTSTRAP_AI_PATH

# 2. User's common workspace (where they likely cloned)
$HOME/.openclaw/workspace/bootstrap-ai
$HOME/workspace/bootstrap-ai
$HOME/workspace/bootstrap-ai
$HOME/code/bootstrap-ai
$HOME/code/bootstrap-ai
$HOME/projects/bootstrap-ai
$HOME/projects/bootstrap-ai
$HOME/dev/bootstrap-ai
$HOME/dev/bootstrap-ai
$HOME/work/bootstrap-ai
$HOME/work/bootstrap-ai
$HOME/repos/bootstrap-ai
$HOME/repos/bootstrap-ai
$HOME/development/bootstrap-ai
$HOME/development/bootstrap-ai
$HOME/sources/bootstrap-ai
$HOME/sources/bootstrap-ai
$HOME/src/bootstrap-ai
$HOME/src/bootstrap-ai

# 3. Default locations
$HOME/.local/share/bootstrap-ai
$HOME/.local/share/bootstrap-ai
$HOME/bootstrap-ai
$HOME/bootstrap-ai
```

Use this search function:

```bash
find_bootstrap_ai() {
  # Accepted names
  local names=("bootstrap-ai" "bootstrap-ai")

  # 1. Environment variable
  if [ -n "${BOOTSTRAP_AI_PATH:-}" ] && [ -x "${BOOTSTRAP_AI_PATH}/bin/bootstrap-ai" ]; then
    printf '%s\n' "$BOOTSTRAP_AI_PATH"
    return 0
  fi

  # 2. Search common user workspaces
  local workspace_dirs=(
    "$HOME/.openclaw/workspace"
    "$HOME/workspace"
    "$HOME/code"
    "$HOME/projects"
    "$HOME/dev"
    "$HOME/work"
    "$HOME/repos"
    "$HOME/development"
    "$HOME/sources"
    "$HOME/src"
  )

  for ws in "${workspace_dirs[@]}"; do
    for name in "${names[@]}"; do
      if [ -x "$ws/$name/bin/bootstrap-ai" ]; then
        printf '%s\n' "$ws/$name"
        return 0
      fi
    done
    # Search one level deeper
    if [ -d "$ws" ]; then
      local found
      for name in "${names[@]}"; do
        found=$(find "$ws" -maxdepth 2 -path "*/$name/bin/bootstrap-ai" -executable -print -quit 2>/dev/null | sed 's|/bin/bootstrap-ai$||')
        if [ -n "$found" ]; then
          printf '%s\n' "$found"
          return 0
        fi
      done
    fi
  done

  # 3. Default locations
  for name in "${names[@]}"; do
    for d in "$HOME/.local/share/$name" "$HOME/$name"; do
      if [ -x "$d/bin/bootstrap-ai" ]; then
        printf '%s\n' "$d"
        return 0
      fi
    done
  done

  return 1
}
```

If not found in any location, clone:

```bash
# Determine user's preferred workspace
WORKSPACE_DIR=""
for d in "$HOME/workspace" "$HOME/code" "$HOME/projects" "$HOME/dev" "$HOME/work" "$HOME/repos"; do
  if [ -d "$d" ]; then
    WORKSPACE_DIR="$d"
    break
  fi
done

# Fallback to workspace
if [ -z "$WORKSPACE_DIR" ]; then
  WORKSPACE_DIR="$HOME/workspace"
  mkdir -p "$WORKSPACE_DIR"
fi

printf 'Cloning bootstrap-ai to %s\n' "$WORKSPACE_DIR/bootstrap-ai"
if command -v gh >/dev/null 2>&1; then
  gh repo clone marcelsanches2/bootstrap-ai "$WORKSPACE_DIR/bootstrap-ai"
else
  git clone https://github.com/marcelsanches2/bootstrap-ai.git "$WORKSPACE_DIR/bootstrap-ai"
fi
```

### 3. Update `bootstrap-ai`

```bash
cd "$BOOTSTRAP_AI_DIR"
git pull --ff-only
```

If `git pull --ff-only` fails, stop and report. Do not auto merge/rebase.

### 4. Analyze stack and coverage

Before importing anything, run:

```bash
"$BOOTSTRAP_AI_DIR/bin/bootstrap-ai" analyze "$ROOT"
```

This detects core technologies and structural libraries from the project's actual files: `pubspec.yaml`, `pyproject.toml`, `requirements.txt`, `package.json`, `go.mod`, `Gemfile`, framework configs, dependencies, and database signals. Examples: `dio`, `riverpod`, `go_router`, `sqlalchemy`, `alembic`, `prisma`, `tanstack-query`, `sidekiq`, `chi`, `pgx`.

### 5. Select or create specific preset

```bash
KIT="$( $BOOTSTRAP_AI_DIR/bin/bootstrap-ai select "$ROOT" --create-missing --print-preset )"
printf 'Selected preset: %s\n' "$KIT"
```

Rule:

- If an existing preset covers the stack and structural libraries → use that preset
- If the stack or structural library is not covered → create new preset via `generators/skill-creator/prompts/create-new-preset.md`
- Examples that create a new preset: Rails, Go, Python+React in the same repo, React+Node API in the same repo, hybrid stack without coverage

When creating a new preset, strictly follow the naming conventions:
- **Roles** (people): `role-<discipline>.md` or `role-<stack>-<discipline>.md`
- **Reviews** (technical perspectives): `review-<domain>.md`
- **Docs**: `UPPER_SNAKE_CASE.md` — guides with `_GUIDE`, references without suffix
- **Separation of concerns**: each file does ONE thing

### 6. Show diff

```bash
"$BOOTSTRAP_AI_DIR/bin/bootstrap-ai" diff "$KIT" "$ROOT"
```

Explain that:

- `Would create` = files that will be created
- `Would skip identical` = already identical
- `Would conflict` = will be created as `.kit-new`

### 7. Apply preset with placeholder substitution

Detect the project name before applying:

```bash
# Detect project name
PROJECT_NAME=""
if [ -f "$ROOT/package.json" ]; then
  PROJECT_NAME=$(python3 -c "import json; print(json.load(open('$ROOT/package.json')).get('name',''))" 2>/dev/null)
elif [ -f "$ROOT/pubspec.yaml" ]; then
  PROJECT_NAME=$(grep -m1 '^name:' "$ROOT/pubspec.yaml" | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'")
elif [ -f "$ROOT/pyproject.toml" ]; then
  PROJECT_NAME=$(grep -m1 '^name[[:space:]]*=' "$ROOT/pyproject.toml" | sed 's/^name[[:space:]]*=[[:space:]]*//' | tr -d '"' | tr -d "'")
fi
PROJECT_NAME="${PROJECT_NAME:-$(basename "$ROOT")}"
printf 'Project name: %s\n' "$PROJECT_NAME"

"$BOOTSTRAP_AI_DIR/bin/bootstrap-ai" apply "$KIT" "$ROOT" --refresh --project-name "$PROJECT_NAME"
```

This replaces `{{PROJECT_NAME}}` in all `.md`, `.yaml`, `.yml`, `.txt`, `.json`, `.toml` files from the preset with the actual project name.

Do not use `--force`.

### 8. Verify import

Check that these exist:

```txt
$ROOT/CLAUDE.md
$ROOT/.claude/commands/jarvis-plan.md
$ROOT/.claude/commands/refactor.md
$ROOT/.claude/commands/jarvis-test-flow.md
$ROOT/docs/ai/
$ROOT/plans/
$ROOT/.bootstrap-ai.lock
```

Run:

```bash
test -f "$ROOT/.claude/commands/refactor.md" && echo "refactor OK"
test -f "$ROOT/.bootstrap-ai.lock" && echo "lock OK"
```

### 8.5. Sync Design System with the project

**Objective:** If the project already has visual tokens (colors, typography, spacing), rewrite `docs/ai/DESIGN_SYSTEM.md` to reflect the project's real identity instead of the generic template.

**When to run:** Whenever the preset applies a `DESIGN_SYSTEM.md`. Do not run for backends (node-backend, python-backend) since they have no UI.

#### 8.5.1. Detect existing tokens by stack

Scan the files below in the project root. If you find real values, extract them.

**Flutter** — look in:

```
lib/app/theme/app_colors.dart
lib/app/theme/app_theme.dart
lib/app/theme/app_text_styles.dart
lib/app/theme/app_spacing.dart
pubspec.yaml (google_fonts dependency)
```

Extract:

- **Colors:** `Color(0xFF...)` values, `ColorScheme(…)` with `primary`, `secondary`, `surface`, `error`, `onPrimary`, etc.
- **Typography:** fonts via `GoogleFonts.*`, `TextStyle(fontFamily: ...)`
- **Spacing:** numeric constants in spacing/radius classes

**React/Web** — look in:

```
tailwind.config.ts / tailwind.config.js
src/theme/colors.ts / src/styles/theme.ts
src/theme/typography.ts
src/styles/tokens.ts
src/app/globals.css (CSS custom properties: --color-*, --font-*, --space-*)
```

Extract:

- **Colors:** values from `theme.colors` in Tailwind, or `var(--color-*)` in CSS
- **Typography:** `theme.fontFamily`, Google Fonts imports, CSS `font-family`
- **Spacing:** `theme.spacing`, `theme.borderRadius`

**Other stacks:** skip this step.

#### 8.5.2. Decision based on scan result

| Result | Action |
|---|---|
| **Found complete tokens** (colors + typography + spacing) | Rewrite `docs/ai/DESIGN_SYSTEM.md` replacing generic sections with the project's real values. Keep the document structure (sections, rules, components), only swap the values. Add note: "Tokens synced from existing design system in `[source_file]`". |
| **Found partial** (e.g.: has colors but no typography) | Rewrite only the sections where values were found. Leave generic where nothing was found. Add note indicating what was synced and what is still template. |
| **Found nothing** | Keep the generic `DESIGN_SYSTEM.md` from the preset. Ask the user: "Your project doesn't have a defined design system. Would you like to customize colors and typography now? (y/n)". If yes, run `/design-phase` in "extract" mode. |

#### 8.5.3. Rewrite format

When rewriting, keep:

- The same section structure as the original template
- The same semantic token names (primary, secondary, surface, etc.)
- The rules and best practices from the template
- The language (en or pt-BR) of the original template

Only replace:

- Hex/RGB color values with real values
- Font names with real fonts
- Spacing/radius values with real values
- Code examples that reference specific colors/fonts

#### 8.5.4. Output example

```txt
🎨 Design System synced:
   Colors: 12 tokens extracted from lib/app/theme/app_colors.dart
   Typography: 3 fonts from GoogleFonts (Inter, Saira, Tourney)
   Spacing: 6 tokens from app_spacing.dart
   File rewritten: docs/ai/DESIGN_SYSTEM.md
```

Or:

```txt
🎨 Design System: no tokens found in the project.
   Generic template kept in docs/ai/DESIGN_SYSTEM.md.
   To customize, run /design-phase.
```

### 8.6. Customize guides with detected libraries

**Objective:** The structural libraries detected in step 4 (analyze) should be reflected in the applied guides. A generic preset talks about "state management" without saying which — if the project uses Riverpod, the guides should mention Riverpod specifically.

**When to run:** Always, both for existing projects and new projects (after /kickoff defines the stack). Works across ALL presets.

#### 8.6.1. Data source

Use the libs detected by `bin/bootstrap-ai analyze` in step 4. The analyze returns a list of structural libraries found in the project.

For new projects (via /kickoff), use the libs that /kickoff defined when selecting/initializing the stack.

#### 8.6.2. Library → guide → customization mapping

For each detected lib, identify which guides should be customized and what to inject:

**State Management:**

| Detected lib | Affected guides | What to customize |
|---|---|---|
| Riverpod | ARCHITECTURE, CODING_STANDARDS | DI pattern: `Provider`, `Notifier`, `AsyncNotifier`, `ref.read/watch`. Provider naming: `*Provider`, `*Notifier`. AsyncValue handling. |
| BLoC | ARCHITECTURE, CODING_STANDARDS | Pattern: `Bloc`, `Event`, `State`, `BlocBuilder`. Naming: `*Bloc`, `*Event`, `*State`. |
| GetX | ARCHITECTURE, CODING_STANDARDS | Pattern: `GetxController`, `obx`, `Get.find()`. |
| Zustand | ARCHITECTURE, CODING_STANDARDS | Store creation: `create()`, actions, selectors. |
| Redux | ARCHITECTURE, CODING_STANDARDS | Pattern: actions, reducers, selectors, middleware. |

**Data Fetching:**

| Detected lib | Affected guides | What to customize |
|---|---|---|
| TanStack Query | FEATURE_GUIDE, ARCHITECTURE | Query keys, `useQuery`, `useMutation`, cache invalidation, optimistic updates, stale time. |
| Dio | ARCHITECTURE, CODING_STANDARDS | Interceptors, error handling, retry, base URL config, auth headers. |
| httpx | ARCHITECTURE, CODING_STANDARDS | Client config, interceptors, error handling. |

**ORM / Database:**

| Detected lib | Affected guides | What to customize |
|---|---|---|
| Prisma | DATABASE_GUIDE, ARCHITECTURE | Schema.prisma, migrations (`prisma migrate`), query patterns, transactions. |
| Drizzle | DATABASE_GUIDE, ARCHITECTURE | Schema definition, migrations, query builder patterns. |
| SQLAlchemy | DATABASE_GUIDE, ARCHITECTURE | Models, sessions, Alembic migrations, query patterns, relationships. |
| TypeORM | DATABASE_GUIDE, ARCHITECTURE | Entities, migrations, repositories, query builder. |
| Mongoose | DATABASE_GUIDE, ARCHITECTURE | Schemas, models, middleware hooks, queries. |

**Validation:**

| Detected lib | Affected guides | What to customize |
|---|---|---|
| Zod | CODING_STANDARDS, API_GUIDE | Schema definitions, `.parse()`, `.safeParse()`, error formatting. |
| Pydantic | CODING_STANDARDS, API_GUIDE | BaseModel, validators, schema generation, error handling. |
| class-validator | CODING_STANDARDS, API_GUIDE | Decorators, validation pipes, error responses. |

**Routing:**

| Detected lib | Affected guides | What to customize |
|---|---|---|
| GoRouter | ARCHITECTURE | Route structure, guards, deep linking, redirect logic, shell routes. |
| React Router | ARCHITECTURE | Route config, loaders, nested routes, params. |

**Testing:**

| Detected lib | Affected guides | What to customize |
|---|---|---|
| Vitest | TESTING_GUIDE | Config, `describe/it/expect`, mocks, coverage. |
| Jest | TESTING_GUIDE | Config, `describe/it/expect`, mocks, coverage. |
| pytest | TESTING_GUIDE | Fixtures, conftest, markers, parametrize, coverage. |
| Playwright | TESTING_GUIDE | E2E: page objects, selectors, assertions, test config. |
| Cypress | TESTING_GUIDE | E2E: cy commands, custom commands, assertions. |

#### 8.6.3. Customization process

For each detected lib that has a mapping above:

1. **Identify** the guides affected by the lib
2. **Locate** the relevant generic section in the guide (e.g.: "State Management" in ARCHITECTURE.md)
3. **Inject** lib-specific patterns right after the generic section, with format:

```md
### Detected library: {LIB_NAME}

{Lib-specific patterns — naming conventions, usage, anti-patterns}

*Detected in: {file_where_found}*
```

4. If the guide has no section on the topic (e.g.: ARCHITECTURE.md doesn't mention "validation"), **add** a new section at the end.
5. **Do not remove** existing generic content — only supplement with lib specifics.

#### 8.6.4. Output example

```txt
📚 Guides customized with detected libs:
   ARCHITECTURE.md + Riverpod (DI pattern, providers, AsyncValue)
   ARCHITECTURE.md + GoRouter (routing structure, guards)
   CODING_STANDARDS.md + Riverpod (naming conventions, anti-patterns)
   CODING_STANDARDS.md + Dio (error handling, interceptors)
   DATABASE_GUIDE.md + Prisma (schema, migrations, queries)
   TESTING_GUIDE.md + Vitest (config, mocks, coverage)
   6 files updated with 6 libraries.
```

Or:

```txt
📚 Guides: no additional structural libraries detected.
   Generic templates kept.
```

#### 8.6.5. New projects (via /kickoff)

When the flow comes from `/kickoff`, the libs were already defined during stack selection. Apply this step with the libs that /kickoff configured in the project (read from `pubspec.yaml`, `package.json`, `pyproject.toml` or `requirements.txt` after initialization).

### 9. Final report

Report:

```txt
Preset applied: <preset>
Bootstrap AI used: <path>
Project name: <project name>
Files created: <n>
.kit-new conflicts: <n>
Design System: synced / generic template
Detected libs: <list>
Customized guides: <n> files with <n> libs
Suggested next step:
  - Existing project: /refactor (aligns real code with preset standards)
  - New project: /plan (starts the development cycle)
```

## Next steps

New project:

```txt
/plan
```

Existing project:

```txt
/refactor
```