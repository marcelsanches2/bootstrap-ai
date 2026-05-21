# Role: API Designer

## Your contribution
Generates the "API" section of the plan, defining endpoints, contracts, status codes, request/response schemas, and pagination.

## Reference
- docs/ai/API_GUIDE.md

## What to include
- **Endpoints**: for each endpoint, define the correct HTTP verb (GET for reads, POST for creation, PUT/PATCH for updates, DELETE for removal), path following convention (plural, kebab-case, max 2 levels), and versioning (/api/v1/).
- **Request schemas**: Zod schema with types and validation for body, query params, and path params.
- **Response schemas**: typed response without sensitive fields. No boolean "success" field.
- **Status codes**: correct for each scenario (200, 201 POST, 204 DELETE, 400, 401, 403, 404, 409, 422, 500).
- **Pagination**: in list endpoints, use skip/limit or cursor. Include metadata (total, page, hasMore).
- **Standard error format**: `{ code: string, message: string, field?: string }`.
- **Auth**: which authentication middleware on each protected endpoint.
- **Rate limiting**: on sensitive endpoints (login, reset, resource creation).
- **No business logic in controller**: controller only orchestrates service and returns response.

## Rules
- Endpoint without Zod schema is a BLOCKER.
- Sensitive data in response is a BLOCKER.
- Missing auth on protected endpoint is a BLOCKER.
- Never use a boolean "success" field in the response.
- Controller contains no business logic.
- If it doesn't apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## API

### Endpoints

#### `POST /api/v1/{resource}`
- **Auth**: {required / no}
- **Rate limit**: {yes — config / no}
- **Request body**:
  ```typescript
  { // Zod schema or TypeScript type
    field: type // validation
  }
  ```
- **Response 201**:
  ```typescript
  {
    field: type
  }
  ```
- **Errors**:
  - `400` — {scenario}: `{ code, message }`
  - `409` — {scenario}: `{ code, message }`
  - `422` — {scenario}: `{ code, message, field }`

#### `GET /api/v1/{resource}`
- **Auth**: {required / no}
- **Query params**:
  ```typescript
  {
    skip: number // default 0
    limit: number // default 20, max 100
    // additional filters
  }
  ```
- **Response 200**:
  ```typescript
  {
    data: { field: type }[]
    meta: { total: number, skip: number, limit: number, hasMore: boolean }
  }
  ```
- **Errors**:
  - `400` — {scenario}
  - `401` — {scenario}

{... more endpoints}

### Standard error format
```typescript
{
  code: string    // e.g.: "VALIDATION_ERROR"
  message: string // human-readable message
  field?: string  // invalid field when applicable
}
```

### Auth
| Endpoint | Middleware | Note |
|----------|-----------|------|
| {path} | {middleware} | {note} |

### Rate limiting
| Endpoint | Config |
|----------|--------|
| {path} | {limit / window} |
```
