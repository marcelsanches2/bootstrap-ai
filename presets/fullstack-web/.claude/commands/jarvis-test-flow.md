---
description: Validates a fullstack E2E flow ensuring deterministic test data, component tests, API integration, contract verification, migration and updated report.
---

# /jarvis-test-flow

Validates an end-to-end flow of the fullstack app {{PROJECT_NAME}} (React frontend + Node.js backend in the same repository). Optional argument: `flow_id` (e.g.: `user_auth`, `product_list`, `checkout_flow`, `webhook_handler`).

The pipeline covers both layers — frontend (component, a11y, UI) and backend (API, DB, contract) — in a single unified execution.

---

## Guard: greenfield

- Before starting step 0, verify that the project has relevant source code:
  - Check for files in `src/`, `app/`, `test/`, `prisma/`.
  - If the project was just initialized and **has no source code files**, **stop at step 0** and report:
    ```
    GREENFIELD — project without source code. Pipeline not applicable.
    Commit infrastructure and run test-flow after the first feature.
    ```
  - This guard prevents running the pipeline on empty projects where every command would fail due to lack of context.

---

## Mandatory sequence

### 0. Assess task size

- Inspect `git diff --stat HEAD` and the nature of the touched files.
- **Monitored directories/files**: `src/`, `public/`, `test/`, `prisma/`, `migrations/`, `package.json`, `tsconfig.json`, `*.config.*`.
- **LARGE** (run full pipeline, steps 1-8):
  - New page/route (frontend or backend).
  - New feature component.
  - New API endpoint.
  - New entity/model.
  - Migration change.
  - New API integration (frontend consuming new endpoint or backend integrating external service).
  - Global state change.
  - Design system change.
  - Complex form.
  - Schema/interface change affecting frontend-backend contract.
  - New service/usecase.
  - Business logic change.
  - Change affecting end-to-end user flow.
- **SMALL** (skip to step 7):
  - Typo.
  - Isolated CSS adjustment.
  - Log adjustment.
  - Formatting.
  - Comment.
  - Fine config tuning without behavior change.
  - Refactor without observable behavior change.
  - Copy/text adjustment.
  - Type adjustment without logic change.
- **In doubt**: ask the user before classifying (one sentence: "task X — small or large?"). **Do not guess.**
- Report the classification in one line before proceeding (e.g.: `task: SMALL — just button color adjustment`).

---

### 1. Determine the `flow_id`

- If passed as argument, use it directly.
- If not, infer from `git diff --name-only HEAD` (which page/feature/module was touched).
- **Path mapping**:
  - Frontend:
    - `src/features/<X>/` → `<X>_*` flow
    - `src/app/<X>/` → `<X>_*` flow
    - `app/<X>/` (Next.js App Router) → `<X>_*` flow
  - Backend:
    - `src/routes/<X>.ts` → `<X>_*` flow
    - `src/server/routes/<X>.ts` → `<X>_*` flow
    - `src/<module>/` → `<module>_*` flow
- **If ambiguous** (touching frontend AND backend of different modules, or multiple modules), ask the user before proceeding. Do not assume.
- The `flow_id` will be used to:
  - Locate test data/fixtures.
  - Locate tests.
  - Name the report (`docs/test_report_{flow_id}.md`).
  - Compose the commit message.

---

### 2. Inventory test data (deterministic mocks + fixtures)

- Locate all test data that covers the `flow_id` — **union of frontend and backend**:
  - **Frontend (mock API)**:
    - `src/mocks/*.ts` — MSW handlers or jest.mock
    - `src/__mocks__/*.ts` — manual mocks
    - `msw/handlers/*.ts` or `src/mocks/handlers/*.ts` — organized MSW handlers
  - **Backend (test DB / fixtures)**:
    - `test/fixtures/*.ts` — static data for tests
    - `test/factories/*.ts` — entity factories
    - `prisma/seed.ts` — database seed
    - `src/seed/*.ts` — alternative seeds
    - `test/**/helpers/*.ts` — setup/teardown helpers
- **Cross-validation**:
  - Cross-reference expected data with test assertions in `src/` and `test/`.
  - Ensure that mocked data on the frontend is consistent with the actual backend contract (schema, types, fields).
- **If test data is missing**:
  - Create deterministic mock/handler/fixture following `docs/ai/TESTING_GUIDE.md` and `docs/ai/ARCHITECTURE.md`.
  - No randomness (use fixed, predictable values).
  - No real network calls.
  - No `setTimeout` in tests.
- **Mandatory guarantees**:
  - **Frontend** tests use API mocks (MSW, jest.mock, etc.) and **never** call the real backend.
  - **Backend** tests use a test database (SQLite in-memory, test database, or ephemeral container) and **never** the production/development database.
  - Environment variables overridden for test environment: `NODE_ENV=test`, `DATABASE_URL=test_*`, etc.

---

### 3. Inventory tests

- Find tests that cover the `flow_id` — **union of frontend and backend**:
  - **Frontend**: `src/**/{flow_id}*.test.{ts,tsx}`
    - Must cover: happy path, loading states, error states, empty states, form validation, navigation, accessibility (a11y).
  - **Backend**: `test/**/{flow_id}*.test.ts` or `test/**/{module}*.test.ts`
    - Must cover: happy path, error scenarios, input validation, correct status codes.
- **Check for previous review**:
  - Check if there is a review report (`plans/*_review.md`, `docs/review_*.md` or similar) generated by `/jarvis-plan` for the same flow.
  - If it exists, extract the **Suggested E2E Scenarios** from the corresponding section and consider them as **minimum coverage requirements** in addition to the test-flow's own scenarios.
  - If not, proceed normally.
- **If no test exists**:
  - Create following `docs/ai/TESTING_GUIDE.md` with the configured runner (jest, vitest).
  - Frontend: use Testing Library + deterministic mocks. Cover rendering, interaction, UI states.
  - Backend: use supertest or equivalent + deterministic fixtures. Cover endpoints, validation, errors.
- **Final validation**:
  - Confirm the test covers the critical steps of the flow.
  - Confirm it uses the deterministic data from the inventoried test data.
  - Confirm it does not depend on external state (network, clock, execution order).

---

### 4. Execute the pipeline (fullstack)

- **Detect package manager** by lockfile:
  - `pnpm-lock.yaml` → pnpm
  - `yarn.lock` → yarn
  - `bun.lockb` → bun
  - Otherwise → npm
- **Detect available scripts** in `package.json`.
- **Execute in the following order** (each step depends on the previous):

  | # | Command | Condition | Does failure block? |
  |---|---------|-----------|---------------------|
  | 1 | `[pkg-manager] install` | If there were dependency changes in `package.json` | Yes |
  | 2 | `[pkg-manager] run lint` | If `lint` script exists | Yes — blocks if it introduces new errors |
  | 3 | `npx tsc --noEmit` or `run typecheck` | Always (or if `typecheck` script exists) | Yes — blocks if it introduces new type errors |
  | 4 | `npx vitest run` or `[pkg-manager] test` | Always (unit + component tests) | Yes — blocks if broken |
  | 5 | `npx vitest run --config vitest.config.integration.ts` | If integration config exists, or filter by suite | Yes — blocks if broken |
  | 6 | `npx playwright test` or `run test:e2e` | If E2E tests exist (Playwright/Cypress) | Yes — blocks if broken |
  | 7 | `npx prisma validate && npx prisma migrate status` | If `prisma/` directory exists | Yes — blocks if migration diverges |
  | 8 | `[pkg-manager] run build` | Always (production build) | Yes — blocks if broken |
  | 9 | `curl -sf http://localhost:3000/api/health` or documented script | If server is running | No — reports warning |

- **Execution rules**:
  - If any command fails, enter the **diagnostic loop (step 4a)** before proceeding.
  - Do not mask, silence warnings, or remove assertions.
  - Do not skip intermediate steps even if they "seem simple."
  - Record the result of each command in the report (step 5).

---

### 4a. Diagnostic and correction loop

Triggered when something in step 4 or the pre-commit hook in step 7 fails.

#### Diagnosis

- Carefully read the **complete error output**.
- Classify the cause into one of the categories:

  | Category | Description | Examples |
  |-----------|-------------|----------|
  | `environment` | Broken local infrastructure | Wrong Node version, corrupted `node_modules`, missing dependency, corrupted cache, browser/Playwright not installed, broken Docker |
  | `mock/data` | Inconsistent test data | Missing deterministic data, divergence between mock/seed and assertion, MSW handler doesn't cover endpoint, outdated mock vs real contract, misconfigured factory, fixture with side effect |
  | `test` | Test structure issue | Invalid assertion, broken selector (removed `data-testid`), `act()` warning, async without `waitFor`, mock in wrong place, timeout, order-dependent test, incomplete teardown/cleanup, outdated snapshot |
  | `code` | Real application regression | Component not rendering, hook with wrong dependency, inconsistent state, missing prop, broken contract, unhandled exception, wrong logic, unexpected return |
  | `typing` | TypeScript type error | `any` where it shouldn't be, `@ts-ignore` hiding bug, outdated interface vs implementation, unsafe type assertion (`as`) |
  | `build` | Production build failure | Unresolved import, chunk error, missing env variable, circular dependency, broken CSS module |
  | `accessibility` | a11y violation | Insufficient contrast, missing label on input, incorrect aria attribute, focus lost in modal/dialog |
  | `migration` | Schema/ORM issue | Divergent schema between models and database, violated constraint, incompatible existing data, missing or out-of-order migration |
  | `contract` | Frontend↔backend inconsistency | Payload diverging between test and implementation, wrong status code, missing field in response, inconsistent input validation |

#### Planning

- Write **1-3 sentences** describing:
  - (a) What the hypothetical root cause is.
  - (b) What the proposed minimal fix is.
  - (c) Which file will be touched.
- **Do not start editing without this.** If you cannot formulate a hypothesis, escalate immediately.

#### Correction

- Apply **only the planned minimal fix**.
- No additional refactoring, no "cleaning up while at it", no cosmetic changes.

#### Re-run

- Run the failed command(s) again, in the same order as step 4.
- If it passes, record in the report and proceed.

#### Limits and escalation

- **Limit of 3 attempts per root cause**.
  - If the same cause reappears on the 3rd cycle → stop and escalate.
  - If the fix requires changes outside the scope of the original task (refactoring global state, creating new page/endpoint) → stop and escalate.
- **Criteria for stopping and escalating immediately** (without waiting for 3 attempts):
  - The fix would require modifying `docs/ai/*` or another file prohibited by the restrictions.
  - The fix would require creating a page/component/endpoint/service/model outside the `flow_id` scope.
  - The error indicates an infrastructure problem (broken build tool, database won't start, dependency won't install).
  - Previous attempts diverge (cause changes each run → sign of shallow diagnosis).
- **When escalating**, report: observed cause, what was attempted, next hypothesis.

#### Record

- Record **all** causes and attempted corrections in the "Issues found / corrections" table of the report (step 5), **even if PASSED**.
- This ensures traceability: even if it passed, what was corrected is documented.

---

### 5. Generate report

- Write or update `docs/test_report_{flow_id}.md` with the sections:

  ```
  # Test Report: {flow_id}

  ## Meta
  - **Date**: <timestamp>
  - **Branch**: <git branch>
  - **Classification**: LARGE / SMALL
  - **Strategy**: <approach description>
  - **Package manager**: <detected>

  ## Detected tools
  | Tool | Detected? | Version |
  |------|----------|---------|
  | Linter     |           |        |
  | Typechecker|           |        |
  | Test runner|           |        |
  | E2E runner |           |        |
  | ORM        |           |        |
  | Build tool |           |        |

  ## Test data created/validated
  | Type | File | Status | Data used |
  |------|------|--------|-----------|
  | Mock API (frontend) | ... | ... | ... |
  | Fixture (backend)   | ... | ... | ... |
  | Seed DB             | ... | ... | ... |

  ## Commands executed
  | # | Command | Result | Time |
  |---|---------|--------|------|
  | 1 | npm install | ✅ PASS | 12s |
  | 2 | npm run lint | ✅ PASS | 3s |
  | ... | ... | ... | ... |

  ## Validated flow
  | Step | Validation | Result |
  |------|------------|--------|
  | Install | Dependencies installed | ✅ |
  | Lint    | No new errors | ✅ |
  | Typecheck | No type errors | ✅ |
  | Unit/Component | Tests pass | ✅ |
  | Integration | Tests pass | ✅ |
  | E2E | Tests pass | ✅ |
  | Migration | Schema valid | ✅ |
  | Build | Production build ok | ✅ |
  | Healthcheck | Server responds | ⚠️ |

  ## Issues found / corrections
  | Cause | Correction | Attempt | Result |
  |-------|-----------|---------|--------|
  | (empty if no issues) | | | |

  ## Final status
  **PASSED** / **PARTIALLY PASSED** / **FAILED**

  ## Files created/modified
  - `src/features/...`
  - `test/...`

  ## How to run again
  ```bash
  npm install && npm run lint && npx tsc --noEmit && npm test && npm run build
  ```
  ```

- The report must be **complete and honest**. Do not omit intermediate failures.

---

### 6. Finish

- Report **a one-line summary** in the format:
  ```
  ✅ test-flow({flow_id}): PASSED — 9 steps, 2 corrections — docs/test_report_{flow_id}.md
  ```
  or
  ```
  ⚠️ test-flow({flow_id}): PARTIALLY PASSED — healthcheck failed — docs/test_report_{flow_id}.md
  ```
  or
  ```
  ❌ test-flow({flow_id}): FAILED — build broke after 3 attempts — docs/test_report_{flow_id}.md
  ```
- Include report path for quick reference.

---

### 7. Commit

- **Stage files**:
  ```
  git add src/ public/ test/ prisma/ migrations/ docs/ package.json tsconfig.json [pnpm-lock.yaml|yarn.lock|bun.lockb|package-lock.json]
  ```
- **If nothing was staged** (`git diff --cached --quiet`): **skip the commit**.
- **Commit message** (according to classification):
  - **SMALL**: `chore: <short description>` (e.g.: `chore: adjust button color in header`).
  - **LARGE + PASSED**: `feat|fix|refactor: <description> + test {flow_id}` according to the nature of the change.
  - **LARGE + PARTIALLY PASSED / FAILED**: **DO NOT commit**. Report and return for correction.
- **Pre-commit hooks**:
  - The commit may trigger pre-commit hooks (lint, typecheck, test).
  - If it breaks, **DO NOT use `--no-verify`** — enter the diagnostic loop (step 4a), fix, and try the commit again.
  - The same attempt limits and escalation rules from step 4a apply.

---

### 8. Push

- **Pre-condition**: only execute if step 7 actually created a new commit.
  - If it was skipped (nothing staged) or blocked (LARGE + failure): **DO NOT push**.
- **Check upstream**:
  - If `git rev-parse --abbrev-ref --symbolic-full-name @{u}` fails: `git push -u origin HEAD`.
  - Otherwise: `git push`.
- **Force rules**:
  - **NEVER** use `--force` or `--force-with-lease` here.
  - Force push only with explicit user request and **never** on `master`/`main`.
- **If push fails due to divergence** (`non-fast-forward`):
  - **Stop, report and ask** before any rebase/merge.
  - Do not assume a resolution strategy.

---

## Reference priority

When resolving conflicting guidance between documents, follow this hierarchy:

1. `CLAUDE.md` — main project contract
2. `docs/ai/ARCHITECTURE.md` — structure and layers
3. `docs/ai/CODING_STANDARDS.md` — code standards
4. `docs/ai/FEATURE_GUIDE.md` — feature guide
5. `docs/ai/API_GUIDE.md` — API contracts
6. `docs/ai/DESIGN_SYSTEM.md` — design system
7. `docs/ai/TESTING_GUIDE.md` — testing standards

In case of conflict, the highest priority document prevails.

---

## Mandatory restrictions

- **Do not** create feature/page/component/endpoint outside the `flow_id` scope.
- **Do not** modify files in `docs/ai/`.
- **Do not** hardcode credentials, API keys, or secrets.
- **Do not** skip steps within a full execution (1-6) even if they "seem simple." The only legitimate skip is via step 0 (classified SMALL), which goes directly to step 7.
- **Do not** remove assertions or mask tests just to pass.
- **Do not** approve a broken build.
- If the flow requires an unavailable real backend, record the divergence and propose a deterministic mock/handler.
- If the flow requires an unavailable external service, record the divergence and propose a deterministic mock/stub.
- Respect the priority hierarchy of reference documents.
