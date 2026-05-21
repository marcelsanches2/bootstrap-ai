# Role: API

## Your contribution
Generates the "API" section of the plan, defining endpoints, contracts, status codes, schemas, and complete REST patterns.

## Reference
- docs/ai/API_GUIDE.md

## What to include
- **Endpoints**: complete table with HTTP verb, path, description. Correct verb (GET for reads, POST for creates, PUT/PATCH for updates, DELETE for removals).
- **Paths**: plural, kebab-case, maximum 2 levels of nesting. Versioning present (`/api/v1/`).
- **Request schema**: Zod schema defined with types and validation for each endpoint.
- **Response schema**: typed, no sensitive fields (passwordHash, token), no boolean `success` field.
- **Status codes**: correct per verb (201 POST, 204 DELETE, 404/409/422). Standardized error table (code/message/field).
- **Pagination**: on list endpoints (skip/limit or cursor).
- **Auth**: specified on protected endpoints (middleware, role).
- **Rate limiting**: on sensitive endpoints (login, reset).
- **Business logic**: in the service, never in the controller.

## Rules
- Endpoint without request/response schema is blocking.
- Sensitive data in response is blocking.
- Missing auth on protected endpoint is blocking.
- No boolean `success` field in response.
- If the task does not involve new/changed API: write "Does not apply" and explain why.

## Output format

```md
## API

### Endpoints
| Verb | Path | Description | Auth | Rate limit |
|---|---|---|---|---|
| {VERB} | {/api/v1/path} | {what it does} | {public/auth/role} | {yes/no} |

### Request schemas
| Endpoint | Schema | Required fields | Validations |
|---|---|---|---|
| {VERB /path} | {schema name} | {fields} | {rules} |

### Response schemas
| Endpoint | Status | Body |
|---|---|---|
| {VERB /path} | {200/201/...} | {fields and types} |

### Pagination
| Endpoint | Method | Parameters | Default |
|---|---|---|---|
| {GET /path} | {skip/limit or cursor} | {params} | {values} |

### Standardized errors
| Status | Code | Message | When |
|---|---|---|---|
| {400} | {VALIDATION_ERROR} | {message} | {scenario} |
| {401} | {UNAUTHORIZED} | {message} | {scenario} |
| ... | ... | ... | ... |
```
