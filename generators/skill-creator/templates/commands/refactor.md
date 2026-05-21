# /refactor

Plans and conducts a safe refactoring in an existing project.

Use when this preset has been applied to an in-progress project and the goal is to align the code with the lifecycle, architecture, `docs/ai/` docs, roles, and preset standards.

## Main Rule

Do not start refactoring code. First inventory, generate a plan, run a review, and only then execute incrementally.

## Mandatory Sequence

### 0. Classify scope

- `SMALL`: isolated module, no public contract change.
- `MEDIUM`: multiple files/features, no central architecture change.
- `LARGE`: architecture, folders, DI, database, public API, or cross-cutting change.

If it's `LARGE`, break it into small phases.

### 1. Load context

Mandatory reads:

- `CLAUDE.md`
- `docs/ai/ARCHITECTURE.md`
- `docs/ai/CODING_STANDARDS.md`
- `docs/ai/TESTING_GUIDE.md`
- other stack guides

### 2. Technical inventory

- Current project patterns
- Divergences against `docs/ai/`
- Technical debt
- Duplications
- Layer violations
- Dead code
- Missing tests

### 3. Generate refactoring plan

Save to `plans/YYYY-MM-DD-refactor-<slug>.md`:

```md
# Refactoring Plan: <title>
## Objective / Context / Current state / Problems / Out of scope
## Strategy / Incremental phases / Files / Tests / Risks / Rollback / Criteria
```

### 4. Run `/jarvis-plan` on the plan.

### 5. Execute incrementally per phase.

### 6. Final report in `docs/refactor_report_<slug>.md`.

## Hard Rules

- No big-bang refactoring.
- Do not mix refactoring with new features.
- Do not change behavior without a test.
- Do not delete code without confirming usage.
- Do not touch `.env` or secrets.
- Do not use `--no-verify`.
- Do not force push.

## Stack-specific rules {{STACK}}

{{STACK_SPECIFIC_RULES}}
