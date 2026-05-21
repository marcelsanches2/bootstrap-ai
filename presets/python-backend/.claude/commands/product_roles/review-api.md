# Role: API Designer

## Your contribution
Generates the "API" section of the plan, defining endpoints, HTTP contracts, status codes, schemas, pagination and OpenAPI documentation.

## Reference
- docs/ai/API_GUIDE.md
- docs/ai/ARCHITECTURE.md

## What to include
- **Endpoints**: for each endpoint, define HTTP verb, path, description and whether it is public or protected.
- **Versioning**: all paths under `/api/v1/`.
- **Paths**: plural, kebab-case, maximum 2 levels of nesting.
- **Request schemas**: Pydantic with explicit types, validation (ranges, sizes, regex) and examples (`model_config = ConfigDict(json_schema_extra=...)`).
- **Response schemas**: no sensitive fields. Separated from SQLAlchemy models.
- **Status codes**: document each possible status code per endpoint (201 for POST, 204 for DELETE, 404/409/422 when applicable). Do not use boolean field `"success"` — the status code already indicates it.
- **Pagination**: on list endpoints, define query params skip (default 0) and limit (default 20, max 100) with paginated response.
- **Filters and sorting**: when applicable, document filter and sort query params.
- **Error format**: standardized — `ErrorDetail` with `code`, `message`, `field` (when validation).
- **Authentication/authorization**: specify for each endpoint — public, authenticated (`Depends(get_current_user)`), specific role.
- **Rate limiting**: on sensitive endpoints (login, reset password, registration), specify limits.
- **Sensitive data**: no `password_hash`, internal token or PII in response.

## Rules
- Every endpoint needs a defined request AND response schema.
- No sensitive data in response (password_hash, internal token).
- Protected endpoints must specify auth.
- Errors follow standardized `ErrorDetail` format.
- No `"success"` field in response — use status code.
- No business logic in router.
- If it does not apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## API

### Endpoints

#### POST /api/v1/{resource}
- **Description**: {what it does}
- **Auth**: {public / authenticated / specific role}
- **Rate limit**: {when applicable}

**Request body:**
```json
{
  "field1": "example_value",
  "field2": 42
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "field1": "value",
  "created_at": "2025-01-01T00:00:00Z"
}
```

**Errors:**
| Status | Code | When |
|--------|------|------|
| 400 | INVALID_INPUT | {condition} |
| 401 | UNAUTHORIZED | No token |
| 409 | CONFLICT | {condition} |
| 422 | VALIDATION_ERROR | Invalid field |

#### GET /api/v1/{resource}
- **Description**: {what it does}
- **Auth**: {public / authenticated}
- **Pagination**: skip=0, limit=20 (max 100)
- **Filters**: {when applicable}
- **Sorting**: {when applicable}

**Response 200:**
```json
{
  "items": [...],
  "total": 42,
  "skip": 0,
  "limit": 20
}
```

{... repeat for each endpoint}

### Pydantic Schemas
{List schemas with fields, types, validation and examples}

### Standardized error format
```json
{
  "code": "ERROR_CODE",
  "message": "Readable description",
  "field": "field_with_error"  // optional, only for 422
}
```
```
