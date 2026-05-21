# API Guide

REST conventions for FastAPI APIs.

## Versioning

Version prefix in URL:

```
/api/v1/users
/api/v2/users
```

In FastAPI:

```python
app = FastAPI()
v1_router = APIRouter(prefix="/api/v1")
app.include_router(v1_router)
```

When creating v2: keep v1 working until complete migration. breaking change = new version.

## Routes

### Endpoint convention

```
GET    /api/v1/users          # List
GET    /api/v1/users/:id      # Find by ID
POST   /api/v1/users          # Create
PUT    /api/v1/users/:id      # Update (complete)
PATCH  /api/v1/users/:id      # Update (partial)
DELETE /api/v1/users/:id      # Remove
```

### Naming

- Resources in plural: `/users`, `/orders`, `/products`
- Kebab-case for compounds: `/user-profiles`, `/order-items`
- Do not use verbs: `/createUser` ❌, `/users` with POST ✓
- Do not use deeply nested resources (max 2 levels): `/users/:id/orders` ✓, `/users/:id/orders/:id/items` ❌

## Request

### Mandatory headers

```
Content-Type: application/json
Authorization: Bearer ***    # when authenticated
```

### Pagination

Standard query params:

```
GET /api/v1/users?skip=0&limit=20&sort=created_at&order=desc
```

Response:

```python
class PaginatedResponse(BaseModel, Generic[T]):
    items: list[T]
    total: int
    skip: int
    limit: int

    @property
    def has_next(self) -> bool:
        return (self.skip + self.limit) < self.total
```

Limits: `limit` minimum 1, maximum 100, default 20. Reject outside range.

### Filters

Query params for simple filters:

```
GET /api/v1/users?status=active&role=admin&created_after=2024-01-01
```

For complex filters, use POST with body:

```
POST /api/v1/users/search
{
  "filters": {"status": "active", "role": "admin"},
  "sort": {"field": "created_at", "order": "desc"},
  "pagination": {"skip": 0, "limit": 20}
}
```

## Response

### Status codes

| Code | When to use |
|---|---|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No content (DELETE) |
| 400 | Input validation failed |
| 401 | Not authenticated |
| 403 | Authenticated but no permission |
| 404 | Resource not found |
| 409 | Conflict (duplicate, invalid state) |
| 422 | Unprocessable entity (Pydantic validation) |
| 429 | Rate limit exceeded |
| 500 | Unexpected internal error |

### Error format

Consistent across the entire API:

```python
class ErrorDetail(BaseModel):
    code: str           # "VALIDATION_ERROR", "NOT_FOUND", "CONFLICT"
    message: str        # Human-readable message
    field: str | None = None  # Field that caused the error, if applicable

class ErrorResponse(BaseModel):
    error: ErrorDetail
```

Response:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email already registered",
    "field": "email"
  }
}
```

### Global error handler

```python
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exception_handlers import http_exception_handler

class AppError(Exception):
    def __init__(self, code: str, message: str, status: int, field: str | None = None):
        self.code = code
        self.message = message
        self.status = status
        self.field = field

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    return JSONResponse(
        status_code=exc.status,
        content={"error": {"code": exc.code, "message": exc.message, "field": exc.field}},
    )
```

In services, raise `AppError`:

```python
raise AppError(code="NOT_FOUND", message="User not found", status=404)
raise AppError(code="CONFLICT", message="Email already registered", status=409, field="email")
```

## Input validation

Always with Pydantic:

```python
from pydantic import BaseModel, EmailStr, field_validator, model_validator
from datetime import date
from typing import Optional

class OrderCreate(BaseModel):
    customer_id: int
    items: list[OrderItemCreate]
    delivery_date: date
    notes: str | None = None

    @field_validator("items")
    @classmethod
    def items_not_empty(cls, v):
        if not v:
            raise ValueError("Order must have at least 1 item")
        return v

    @model_validator(mode="after")
    def delivery_date_is_future(self):
        if self.delivery_date <= date.today():
            raise ValueError("Delivery date must be in the future")
        return self
```

Do not validate in the router with `if/else`. Leave it in the schema.

## Serialization

### Do not expose internal fields

```python
# ❌ Never return password_hash, internal_id, etc.
class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    # password_hash intentionally omitted

    model_config = {"from_attributes": True}
```

### Dates in ISO 8601

```python
created_at: datetime  # serializes as "2024-01-15T10:30:00Z"
```

### Enums as string

```python
class UserRole(str, Enum):
    admin = "admin"
    user = "user"
```

## Rate limiting

Use `slowapi` or custom middleware:

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@router.post("/login")
@limiter.limit("5/minute")
async def login(request: Request, payload: LoginRequest):
    ...
```

## Automatic documentation

FastAPI generates OpenAPI/Swagger automatically at `/docs` and `/redoc`.

Customize:

```python
app = FastAPI(
    title="API Name",
    version="1.0.0",
    description="API description",
    docs_url="/docs",
    redoc_url="/redoc",
)
```

Add examples in schemas:

```python
class UserCreate(BaseModel):
    name: str = Field(..., description="Full name", examples=["John Doe"])
    email: EmailStr = Field(..., description="Valid email", examples=["john@email.com"])
```

## CORS

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

In production: `allow_origins` with explicit list, never `["*"]`.

## Hard rules

- Do not use status code 200 for everything — use the correct code.
- Do not return `{"success": true}` — use status code + schema.
- Do not expose sensitive fields in response (password_hash, internal tokens).
- Do not validate input in router with if/else — use Pydantic.
- Do not hardcode URLs — use path params and named routes.
- Do not create endpoint without request and response schema.
- Do not use `str` for dates — use `datetime` or `date`.
- Do not return error trace in production.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Correct status code**: Do not use status code 200 for everything; use the correct HTTP code.
- **Consistent error schema**: Do not return `{"success": true}`; use status code + ErrorResponse.
- **Do not expose sensitive fields**: Never return password_hash, internal tokens or sensitive fields.
- **Validation in schema**: Do not validate input in router with `if/else`; use Pydantic.
- **No hardcoded URLs**: Do not hardcode URLs; use path params and named routes.
- **Endpoint with schema**: Do not create endpoint without request and response schema.
- **Correct types for dates**: Do not use `str` for dates; use `datetime` or `date`.
- **No trace in production**: Do not return error stack trace in production.
- **Restricted CORS in production**: `allow_origins` with explicit list in production, never `["*"]`.
- **Pagination with limits**: `limit` minimum 1, maximum 100, default 20; reject outside range.
