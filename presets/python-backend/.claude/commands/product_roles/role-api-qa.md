# Role: API QA

## Your contribution
Generates the "Tests" section of the plan, detailing unit, integration, API and E2E test scenarios with deterministic test data.

## Reference
- docs/ai/TESTING_GUIDE.md
- docs/ai/API_GUIDE.md

## What to include
- **Test strategy**: which types of tests apply (unit, integration, API, E2E) and why.
- **Unit tests**: service functions/methods and domain logic. List scenarios with input → expected output.
- **Integration tests**: flows involving database, DI, multiple layers. Use test database (SQLite or test PostgreSQL) with transaction rollback.
- **API tests**: for each endpoint, happy path with complete contract (status code, request body, response body). Verify types and fields.
- **Negative scenarios**: for each endpoint, list error scenarios — 400 (invalid input), 401 (not authenticated), 403 (no permission), 404 (not found), 409 (conflict), 422 (Pydantic validation).
- **Edge cases**: empty list, single item, field at maximum limit, unicode, null in optional field.
- **Pagination**: test first page, last page, beyond total, skip/limit boundaries.
- **Deterministic test data**: factories, fixtures, seeds. No depending on production, real clock or external network.
- **Sensitive data**: verify that password_hash, tokens and PII do NOT appear in test responses.
- **External mocks**: which external services (email, payment gateway, SMS) need to be mocked and how.
- **Independence**: tests do not depend on execution order.

## Rules
- Every endpoint must have a happy path test + at least one negative scenario.
- API contract must be verified (correct fields and types in response).
- Test data must be deterministic (factories/fixtures, not production).
- Tests cannot depend on external network without mock.
- If it does not apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## Tests

### Strategy
| Type | When to use | Tool |
|------|------------|------|
| Unit | Service/domain logic | pytest |
| Integration | Flow with database/DI | pytest + test AsyncSession |
| API | Endpoint contract | pytest + httpx TestClient |
| E2E | Full flow across layers | pytest + TestClient |

### Tests per endpoint

#### POST /api/v1/{resource}
**Happy path:**
- Input: `{example body}`
- Expected: status 201, response with `{expected fields}`

**Negative scenarios:**
| Scenario | Input | Expected status | Detail |
|----------|-------|----------------|--------|
| Invalid input | {body} | 422 | {invalid field} |
| Not authenticated | no header | 401 | — |
| Conflict | {body} | 409 | {reason} |

**Edge cases:**
- {Edge case 1}: {expected result}

#### GET /api/v1/{resource}
**Pagination:**
- skip=0, limit=10 → first page
- skip=100, limit=10 with 50 total → empty list
- skip=-1 → 422

{... repeat for each endpoint}

### Test data
- `{fixture/factory}`: {what it generates}
- `{fixture/factory}`: {what it generates}

### External mocks
| Service | Mock | When |
|---------|------|------|
| {service} | {how to mock} | {which test} |

### Security checks
- Password_hash does not appear in any response
- Token is not exposed in response body
```
