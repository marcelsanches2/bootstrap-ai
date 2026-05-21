# Role: Web QA

## Your contribution
Generates the "Frontend tests" section of the plan, defining unit/component, E2E, mocks, and negative scenario tests for the frontend.

## Reference
- docs/ai/TESTING_GUIDE.md

## What to include
- **Unit/component**: functions, hooks, and components with behavior — each relevant logic/UI has a test. Describe test file, what it tests, and tool (Vitest/Jest/RTL).
- **E2E**: critical journeys covered with Playwright/Cypress. Flow that cannot depend on manual testing.
- **Deterministic mocks**: API mocked in a stable way (MSW, handler, fixture). Test never depends on real network.
- **Negative scenarios**: error, empty, permission, and validation tested. Not just happy path.
- **Build/typecheck/lint**: planned validation scripts with commands listed.

## Rules
- Critical journey without E2E (and without justification) is blocking.
- Test depending on real network is blocking.
- Only happy path tested is a pending item.
- If the task has no testable frontend UI/logic: write "Does not apply" and explain why.

## Output format

```md
## Tests — Frontend

### Unit/component
| File | Tests | Tool |
|---|---|---|
| {path} | {behavior} | {vitest/jest/RTL} |

### E2E
| Journey | File | Criticality |
|---|---|---|
| {flow description} | {path} | {critical/high/medium} |

### Mocks
| API/data | Strategy | File |
|---|---|---|
| {endpoint/data} | {MSW/fixture/handler} | {path} |

### Negative scenarios
| Scenario | Test | File |
|---|---|---|
| {error/empty/permission} | {what it verifies} | {path} |

### Build validation
- [ ] `typecheck` — {command}
- [ ] `lint` — {command}
- [ ] `build` — {command}
```
