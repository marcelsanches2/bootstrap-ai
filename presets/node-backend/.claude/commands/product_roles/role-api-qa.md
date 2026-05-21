# Role: QA / Tests

## Your contribution
Generates the "Tests" section of the plan, defining unit, integration, API, and E2E test scenarios with deterministic test data.

## Reference
- docs/ai/TESTING_GUIDE.md

## What to include
- **Unit tests**: happy path scenarios for business logic (valid input → expected output). List functions/modules to test.
- **Negative scenarios**: cover status codes 400, 401, 403, 404, 409, 422 with specific inputs that cause each error.
- **Deterministic test data**: define seeds, factories, or fixtures. Tests must not depend on production, uncontrolled real clocks, or external networks without mocks.
- **Pagination tests**: when there's a list endpoint, test skip/limit, empty page, boundaries.
- **Edge cases**: empty list, field at maximum length, null, undefined, incorrect types.
- **API contract**: verify response fields and types. Sensitive data (password, token) must NOT appear in the response.
- **Mocks for external services**: define which external services are mocked and how.
- **Independence**: tests must not depend on execution order.
- **Execution strategy**: command to run (e.g., `vitest`, `vitest --coverage`) and when (pre-commit, CI).

## Rules
- Happy path without test is a BLOCKER.
- Unverifiable API contract is a BLOCKER.
- Sensitive data in response is a BLOCKER.
- Tests must not depend on production, uncontrolled real clocks, or external networks without mocks.
- If it doesn't apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## Tests

### Strategy
- **Runner**: {vitest/jest}
- **When to run**: {pre-commit / CI / manual}

### Unit tests
| Module | Scenario | Input | Expected output |
|--------|----------|-------|----------------|
| {module} | happy path | {input} | {output} |
| {module} | {negative scenario} | {input} | {expected error} |

### Integration / API tests
| Endpoint | Method | Scenario | Expected status | Validation |
|----------|--------|----------|----------------|------------|
| {path} | {verb} | {scenario} | {status} | {what to verify} |

### Edge cases
- {edge case 1}: {expected behavior}
- {edge case 2}: {expected behavior}

### Test data
- {seed/factory/fixture}: {description}

### Mocks
| Service | Tool | Mocked behavior |
|---------|------|----------------|
| {service} | {tool} | {behavior} |

### Sensitive data
- Fields that must NOT appear in response: {list}
```
