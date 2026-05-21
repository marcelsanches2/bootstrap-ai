# /refactor

Plans and conducts a safe refactoring in an existing project.

Use when this preset is applied to an ongoing project and the goal is to align the code with the lifecycle, architecture, `docs/ai/` docs, roles, and preset standards.

## Main rule

Do not start refactoring code. First inventory, generate plan, run review, and only then execute incrementally.

## Mandatory sequence

### 0. Classify scope

Classify the refactoring:

- `SMALL`: isolated module/feature, no public contract change.
- `MEDIUM`: multiple files/features, but no central architecture change.
- `LARGE`: architecture, folders, DI, router, database, public API, build/deploy, or cross-cutting change.

If `LARGE`, do not execute everything at once. Break it into small phases.

### 1. Load context

Mandatory reading:

- `CLAUDE.md`
- `docs/ai/ARCHITECTURE.md`
- `docs/ai/CODING_STANDARDS.md`
- `docs/ai/FEATURE_GUIDE.md`
- `docs/ai/TESTING_GUIDE.md`
- other stack-specific guides, if they exist

Also list:

- main directory structure
- available test/build commands
- main dependencies
- entry points
- configuration files

### 2. Technical inventory

Create an objective inventory:

- current project patterns
- divergences against `docs/ai/`
- visible technical debt
- duplications
- layer/boundary violations
- dead code or empty files
- missing or fragile tests
- security/observability/deploy risks, if applicable

Do not confuse opinion with rule. If a rule is not in the docs, mark it as a recommendation.

### 3. Generate refactoring plan

Create file at:

```txt
plans/YYYY-MM-DD-refactor-<slug>.md
```

Mandatory format:

```md
# Refactoring Plan: <title>

## Objective
## Context loaded
## Current state
## Issues found
## Out of scope
## Strategy
## Incremental phases
## Likely files
## Tests per phase
## Risks
## Rollback
## Acceptance criteria
```

Each phase should be small enough to validate with `/jarvis-test-flow`.

### 4. Run multi-role review

Run `/jarvis-plan` to generate a plan with embedded perspectives.

- If there is a BLOCKER: stop.
- If there is a MAJOR: resolve with the user before executing.
- Only implement after the plan is approved.

### 4b. Approval Gate

After review is approved (zero BLOCKERS, zero MAJORs), present:

- Refactoring plan summary
- Number of phases
- Main risk
- Likely files

Ask: **"Approve refactoring execution? (yes/no)"**

Only execute after explicit confirmation.

### 5. Execute incrementally

For each approved phase:

1. apply minimal change
2. run specific validation
3. run `/jarvis-test-flow` when the phase alters behavior, architecture, tests, build, or contract
4. record result in the plan or report
5. stop if the root cause requires expanding scope

### 6. Final report

Create or update:

```txt
docs/refactor_report_<slug>.md
```

Contents:

- plan used
- phases executed
- files changed
- commands executed
- issues found
- decisions made
- remaining items
- recommended next step

## Hard rules

- No big-bang refactoring.
- Do not mix refactoring with new features.
- Do not change behavior without a test or explicit justification.
- Do not delete code without confirming usage/references.
- Do not touch `.env` or secrets.
- Do not use `--no-verify`.
- Do not force push.
- If the project already has a divergent pattern from the docs, record the conflict before changing.
