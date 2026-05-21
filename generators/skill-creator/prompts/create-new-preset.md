# Skill Creator: Create New Preset

Create a complete preset for a new technology following Bootstrap AI standards.

## Input

The user provided:
- **Preset name**: `{{PRESET_NAME}}`
- **Stack description**: `{{DESCRIPTION}}`

## Reference

Before generating, read existing presets to understand the pattern:

1. `presets/flutter-app/` — mobile preset with design system, QA E2E
2. `presets/python-backend/` — backend preset with API, DB, security, scalability
3. `presets/react-web/` — frontend preset with design system, accessibility, performance
4. `presets/node-backend/` — backend preset with TypeScript, typing, migrations

Use the most similar preset to the described stack as the primary base. Adapt from there.

## Naming conventions (mandatory)

Follow THESE conventions — no file can deviate from them:

### Roles and Reviews

| Type | Prefix | Meaning | Examples |
|---|---|---|---|
| **Role** (person who reviews) | `role-` | A person with a defined position | `role-architect.md`, `role-pm.md`, `role-designer.md`, `role-delivery.md` |
| **Role + stack** (specific person) | `role-<stack>-` | Person with stack expertise | `role-flutter-qa.md`, `role-web-qa.md`, `role-api-qa.md` |
| **Domain** (technical perspective) | `review-` | Review perspective, not a position | `review-database.md`, `review-api.md`, `review-security.md`, `review-observability.md`, `review-scalability.md`, `review-accessibility.md`, `review-performance.md`, `review-testing.md` |

**Always in English. Always kebab-case.**

### docs/ai

| Type | Pattern | Examples |
|---|---|---|
| **Guide** (how to do X) | `<DOMAIN>_GUIDE.md` | `API_GUIDE.md`, `TESTING_GUIDE.md`, `DATABASE_GUIDE.md` |
| **Standard/Reference** (what is X) | `<CONCEPT>.md` | `ARCHITECTURE.md`, `CODING_STANDARDS.md`, `DESIGN_SYSTEM.md` |

**Always UPPER_SNAKE_CASE. No `AI_` prefix.**

### Separation of concerns

- Each guide has ONE responsibility — testing only in `TESTING_GUIDE`, never in `FEATURE_GUIDE` or `CODING_STANDARDS`
- Roles are review perspectives with objective + checklist (~47 lines each, no repeated boilerplate)
- review-testing is the reviewer's perspective, not test rules

## Mandatory structure

Generate ALL files below. None can be empty or placeholder.

### Root files

1. **`CLAUDE.md`** — Project context for AI. Must have:
   - Project name with `{{PROJECT_NAME}}`
   - Main stack (framework, language, ORM, tools)
   - **On-demand reading table** — each task type maps to relevant docs/ai (do NOT read all automatically)
   - Current priority (numbered list)
   - Stack-specific mandatory rules
   - Mandatory process for non-trivial changes (plan → jarvis-plan → implement → test-flow → ship)
   - Decision principle

2. **`manifest.yaml`** — Preset metadata:
   - `name`, `description`
   - `required_files`: all generated files
   - `library_tags`: stack structural libraries that should force this preset
   - `roles`: list of all generated `role-*.md` and `review-*.md`

3. **`plans/.gitkeep`** — Empty.

### .claude/settings.json

4. Use the `templates/settings.json` template and adapt:
   - `PostToolUse` (Edit|Write|MultiEdit): stack lint/typecheck command
   - `Stop`: detects changes in stack files and forces /jarvis-test-flow
   - `permissions.deny`: keep default (.env, rm -rf, git push --force)

### .claude/commands/ (lifecycle commands)

5. **`jarvis-plan.md`** — Use the most similar preset as base. Must have **smart role selection**:
   - Plan analysis step → conditional role selection
   - Always loads: architect + PM
   - Conditionals: maps plan conditions to relevant roles/reviews
   - Format: `| Plan condition | Role |` table
   - Verdicts, blocking rules, report format, resolve MAJOR items
   - ~60-100 lines


7. **`refactor.md`** — Use the most similar preset as base. Adapt stack-specific rule sections.

8. **`ship.md`** — Copy from `templates/commands/ship.md` (generic).

9. **`jarvis-test-flow.md`** — Use the most similar preset as base. Must have:
    - Stack-specific complete test flow
    - Execution commands (e.g.: `flutter test`, `pytest`, `npm test`)
    - Pass/fail criteria
    - Auto-fix when possible
    - ~150-300 lines

### .claude/commands/product_roles/ (helpers + roles)

10. **Helpers** (copy directly from any existing preset — they are identical across all stacks):
    - `carregar-referencias.md`
    - `localizar-plano.md`

11. **Generic roles** (copy from most similar preset — they are identical across all stacks):
    - `role-architect.md`
    - `role-pm.md`
    - `role-delivery.md`

12. **Stack-specific roles** (create following the pattern):
    - Frontend: `role-designer.md`
    - Mobile: `role-designer.md`, `role-<stack>-qa.md` (e.g.: `role-flutter-qa.md`)
    - Web: `role-web-qa.md`
    - Backend: `role-api-qa.md`

13. **Generic reviews** (copy from most similar preset when applicable):
    - Backend: `review-api.md`, `review-database.md`, `review-security.md`, `review-observability.md`, `review-scalability.md`
    - Frontend: `review-accessibility.md`, `review-performance.md`
    - All: `review-testing.md`

    **Each role/review must have:**
    - Objective (1 sentence)
    - Checklist with checkable criteria `[OK/PENDING]`
    - Hard rule (1 sentence)
    - ~40-50 lines (NO Input/Method/Output boilerplate)

### docs/ai/ (AI guides)

14. Generate all guides relevant to the stack.

    **Mandatory minimum (all presets):**
    - `ARCHITECTURE.md` — structure, boundaries, organization patterns
    - `CODING_STANDARDS.md` — naming, conventions, anti-patterns
    - `TESTING_GUIDE.md` — strategy, tools, testing patterns

    **Additional by stack type:**
    - Backend: `API_GUIDE.md`, `DATABASE_GUIDE.md`, `SECURITY_GUIDE.md`, `OBSERVABILITY_GUIDE.md`, `SCALABILITY_GUIDE.md`, `DEPLOYMENT_GUIDE.md`
    - Frontend/Mobile: `DESIGN_SYSTEM.md`, `FEATURE_GUIDE.md`
    - Frontend Web: `ACCESSIBILITY_GUIDE.md`, `PERFORMANCE_GUIDE.md`, `DEPLOYMENT_GUIDE.md`

    **Each guide:**
    - ONE responsibility (testing ONLY in TESTING_GUIDE)
    - Generic enough for any project of that stack
    - Uses `{{PROJECT_NAME}}` where needed
    - ~80-150 lines

## Minimum quality

- No file can have only a title or "TODO".
- Each file must have substantial content comparable to existing presets.
- Roles/reviews: ~40-50 lines each (objective + checklist + hard rule).
- Docs AI: ~80-150 lines each.
- jarvis-test-flow: ~150-300 lines.
- jarvis-plan: ~60-100 lines (with smart role selection).
- CLAUDE.md: ~80-120 lines.
- All files follow the naming conventions defined above.
- Separation of concerns: each file does ONE thing.

## Post-creation

After generating all files:

1. Validate that all names follow the conventions (role-*, review-*, *_GUIDE.md, UPPER_SNAKE_CASE.md)
2. Validate that there is no testing content outside TESTING_GUIDE
3. Validate that jarvis-plan has smart role selection
4. Validate that CLAUDE.md has on-demand reading table
5. Report: files created, roles, reviews, guides, lines per file
