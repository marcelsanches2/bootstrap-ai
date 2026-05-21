# derive-jarvis-test-flow.md

Generate the `jarvis-test-flow.md` specific to the stack.

## Input

- **Stack**: `{{DESCRIPTION}}`
- **Preset name**: `{{PRESET_NAME}}`
- **Type**: backend / frontend / mobile (infer from description)

## Reference

Read the jarvis-test-flow from existing presets before generating:

- `presets/flutter-app/.claude/commands/jarvis-test-flow.md` (~11k chars, mobile with Figma validation)
- `presets/python-backend/.claude/commands/jarvis-test-flow.md` (~9k chars, backend with pytest/ruff/mypy/alembic)
- `presets/react-web/.claude/commands/jarvis-test-flow.md` (~9.5k chars, frontend with testing-library/MSW/tsc)
- `presets/node-backend/.claude/commands/jarvis-test-flow.md` (~9.6k chars, backend with jest|vitest/tsc/prisma)

## Mandatory structure

The jarvis-test-flow MUST follow this structure (same as existing presets):

```
0. Evaluate task size (LARGE/SMALL)
1. Determine flow_id
2. Inventory test data (fixtures/deterministic mocks)
3. Inventory tests (with cross-ref to jarvis-plan)
4. Execute pipeline (lint → typecheck → test → migration → build → healthcheck)
4a. Diagnosis and correction loop (classify cause, plan, correct, max 3 attempts)
5. Generate report in docs/test_report_{flow_id}.md
6. Finish
7. Commit (only if PASSED, never --no-verify)
8. Push (never force, ask before rebase)
+ Mandatory restrictions
```

## Adaptations by type

### Backend

Pipeline:
- Package manager / dependency install
- Linter (ruff/eslint/revive/etc)
- Typechecker (mypy/pyright/tsc/etc)
- Test runner (pytest/jest/vitest/go test/etc)
- Migration validation (alembic/prisma/goose/typeorm/etc)
- Production build
- Local healthcheck

Diagnosis causes: environment, fixture/data, test, code, migration, API contract, typing

Directories monitored in Stop hook: `src/`, `app/`, `tests/`, `test/`, migrations dir, config files

### Frontend

Pipeline:
- Package manager install
- Linter (eslint/stylelint/etc)
- Typechecker (tsc)
- Test runner (jest/vitest + testing-library)
- E2E tests (Playwright/Cypress, if exists)
- Production build
- Lighthouse/axe audit (if configured)

Diagnosis causes: environment, mock/data, test, code, typing, build, accessibility

Monitored directories: `src/`, `public/`, `package.json`, `tsconfig.json`

### Mobile

Pipeline:
- Dependency install (pub get/pod install/gradle)
- Analyzer (flutter analyze / swiftlint / ktlint)
- Test runner (flutter test / XCTest / instrumentation)
- Integration test on device/simulator
- Production build

Diagnosis causes: environment, mock/data, test, code, design (Figma comparison)

Monitored directories: `lib/`, `integration_test/`, `pubspec.yaml`, etc.

## Minimum quality

- **Quality bar = existing presets** (~9000+ chars). If it's shorter, it's incomplete.
- Pipeline with **real stack commands** (e.g.: `ruff check . --fix`, `flutter test --coverage`, `npx prisma migrate status`) — never generic
- Diagnosis loop with stack-specific causes and concrete correction examples
- Commit/push with the same hard rules as existing presets
- Complete mandatory restrictions
- Include cause classification table with action for each type

## Example of stack-specific content

**BAD:**
```
4. Execute test runner
   If it fails, check the error and fix it.
```

**GOOD:**
```
4. Execute pipeline

```bash
cd $ROOT
# 1. Lint
ruff check . --fix --unsafe-fixes
# 2. Typecheck  
mypy src/ --strict
# 3. Tests
pytest tests/ -x --tb=short --cov=src --cov-report=term-missing
# 4. Migration check
alembic check
alembic upgrade head
# 5. Build
docker build -t $PROJECT_NAME:test .
# 6. Healthcheck
curl -sf http://localhost:8000/health || echo "FAIL"
```
```
