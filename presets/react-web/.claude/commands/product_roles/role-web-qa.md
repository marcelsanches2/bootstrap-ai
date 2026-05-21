# Role: Web QA

## Your contribution
Generates the "Tests" section of the plan, defining unit, component, and E2E tests needed with specific tools (Vitest/Jest, Playwright/Cypress).

## Reference
- docs/ai/TESTING_GUIDE.md

## What to include

- **Unit tests**: pure functions, custom hooks, and utilities. Define what to test and expected behavior. Use Vitest or Jest as per the project.
- **Component tests**: React components with behavior — conditional rendering, interactions, props. Use Testing Library (RTL) to test user-visible behavior, not implementation details.
- **E2E tests**: critical user journeys with Playwright or Cypress. Define the flow, preconditions, and assertions. Every critical flow must have E2E or explicit justification.
- **Deterministic mocks**: APIs mocked in a stable way with MSW or equivalent. Tests must not depend on real network.
- **Negative scenarios**: API error, empty data, permission denied, form validation — beyond the happy path.
- **Build validation**: lint, typecheck, and build as quality gates before/after implementation.

## Rules

- Test user-visible behavior, not internal component details.
- Every critical flow must have E2E — if not, justify.
- Mocks must be deterministic — no dependency on real API or timing.
- Do not ignore negative scenarios — error, empty, and validation are mandatory when relevant.
- Validation scripts (lint, typecheck, build) must be explicit commands.
- If not applicable to the task: write "Does not apply" and explain why.

## Output format

```md
## Tests

### Build validation
- Lint: `{command}`
- Typecheck: `{command}`
- Build: `{command}`

### Unit tests
| File | What it tests | Cases |
|------|--------------|-------|
| {name}.test.ts | {responsibility} | {cases: happy path, edge cases} |

### Component tests
| File | Component | Behaviors tested |
|------|-----------|-----------------|
| {Name}.test.tsx | {Component} | {rendering, interactions, states} |

### E2E tests
| Flow | Precondition | Steps | Assertions |
|------|-------------|-------|------------|
| {flow name} | {initial state} | {user steps} | {what it verifies} |

### Mocks
| API/Resource | Tool | Mocked behavior |
|-------------|------|----------------|
| {endpoint} | {MSW / handler} | {simulated response} |

### Negative scenarios
| Scenario | Where tested | Expected result |
|----------|-------------|----------------|
| API error | {test} | {error UI + retry} |
| empty data | {test} | {empty state} |
| validation | {test} | {error message} |
```
