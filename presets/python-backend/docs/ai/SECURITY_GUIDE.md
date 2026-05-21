# Security Guide

Security standards for Python backend.

## Authentication

### JWT with access + refresh token

```python
from datetime import datetime, timedelta, timezone
import jwt

def create_access_token(user_id: int, secret: str) -> str:
    payload = {
        "sub": str(user_id),
        "exp": datetime.now(timezone.utc) + timedelta(minutes=15),
        "type": "access",
    }
    return jwt.encode(payload, secret, algorithm="HS256")

def create_refresh_token(user_id: int, secret: str) -> str:
    payload = {
        "sub": str(user_id),
        "exp": datetime.now(timezone.utc) + timedelta(days=7),
        "type": "refresh",
    }
    return jwt.encode(payload, secret, algorithm="HS256")
```

Rules:
- Access token: 15 minutes.
- Refresh token: 7 days, store hash in database for revocation.
- Secret: minimum 256 bits, rotatable via config.
- Never hardcode secret.

### Password hashing

```python
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)
```

Rules:
- Always bcrypt or argon2.
- Never store password in plain text.
- Never log the original password.

## Authorization

### RBAC with dependency

```python
from fastapi import Depends, HTTPException

class RoleChecker:
    def __init__(self, allowed_roles: list[str]):
        self.allowed_roles = allowed_roles

    def __call__(self, current_user=Depends(get_current_user)):
        if current_user.role not in self.allowed_roles:
            raise HTTPException(status_code=403, detail="No permission")
        return current_user

# Usage
@router.delete("/users/{user_id}", status_code=204)
async def delete_user(
    user_id: int,
    current_user=Depends(RoleChecker(["admin"])),
    db: AsyncSession = Depends(get_db),
):
    ...
```

### Ownership check

```python
async def get_resource_or_403(resource_id: int, user_id: int, db: AsyncSession):
    result = await db.execute(select(Resource).where(Resource.id == resource_id))
    resource = result.scalar_one_or_none()
    if not resource:
        raise AppError(code="NOT_FOUND", message="Resource not found", status=404)
    if resource.owner_id != user_id:
        raise AppError(code="FORBIDDEN", message="No permission", status=403)
    return resource
```

## Sensitive data (PII)

### What is PII

- SSN, tax ID, ID card numbers
- Email, phone, address
- Date of birth
- Banking data, credit card
- IP in some contexts

### Rules

- Never log PII.
- Never return PII on a public endpoint.
- Encrypt PII in the database when possible (pgcrypto).
- Masking in partial responses: `ssn: "***.**.***-11"`.

```python
from cryptography.fernet import Fernet

def encrypt_pii(data: str, key: bytes) -> str:
    f = Fernet(key)
    return f.encrypt(data.encode()).decode()

def decrypt_pii(token: str, key: bytes) -> str:
    f = Fernet(key)
    return f.decrypt(token.encode()).decode()
```

## Input validation

### Always validate with Pydantic

```python
class UserCreate(BaseModel):
    email: EmailStr
    name: str = Field(min_length=2, max_length=255)
    password: str = Field(min_length=8, max_length=128)
```

### Sanitization

```python
import re

def sanitize_filename(filename: str) -> str:
    # Remove path traversal
    name = os.path.basename(filename)
    # Remove dangerous chars
    return re.sub(r'[^a-zA-Z0-9._-]', '', name)
```

- Never concatenate input in SQL — always parameterized (SQLAlchemy already does this).
- Never concatenate input in command — use `subprocess` with list.
- Never render input in HTML without escaping (if serving HTML).

## Rate limiting

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@router.post("/login")
@limiter.limit("5/minute")
async def login(request: Request, payload: LoginRequest):
    ...
```

Apply to:
- Login: 5/min
- Reset password: 3/min
- Registration: 10/min
- General API: 100/min

## Security headers

```python
from starlette.middleware.base import BaseHTTPMiddleware

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Content-Security-Policy"] = "default-src 'self'"
        return response
```

## CORS

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,  # explicit list
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)
```

Never `allow_origins=["*"]` in production.

## Secrets

- Never commit `.env` — use `.env.example`.
- Never log secrets.
- Never return secrets in API.
- Never hardcode in source code.
- Use environment variables or vault.
- Rotate secrets periodically.

## HTTPS

- Always HTTPS in production.
- Redirect HTTP → HTTPS.
- HSTS header.
- Never serve credentials without HTTPS.

## Hard rules

- Never log password, token, PII.
- Never store password in plain text.
- Never use `allow_origins=["*"]` in production.
- Never commit `.env`.
- Never concatenate input in SQL.
- Never serve HTTP in production without HTTPS.
- Never expose stack trace in production.
- Never use weak or default secret.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Do not log sensitive data**: Never log password, token, PII or Authorization header.
- **Password always hashed**: Never store password in plain text; use bcrypt or argon2.
- **Restricted CORS in production**: Never use `allow_origins=["*"]` in production.
- **Do not commit `.env`**: Never commit real `.env`; use `.env.example`.
- **Parameterized SQL**: Never concatenate input in SQL; always parameterized.
- **HTTPS mandatory in production**: Never serve HTTP in production without HTTPS.
- **No stack trace in production**: Never expose stack trace in production responses.
- **Strong and rotatable secret**: Never use weak, default or hardcoded secret.
- **Do not return PII on public endpoint**: Never return PII on endpoint without authentication/authorization.
- **Do not log original password**: Never log the original password even during hashing.
- **Do not concatenate input in command**: Never concatenate input in system command; use list.
- **Do not serve credentials without HTTPS**: Never send credentials over non-HTTPS connection.
