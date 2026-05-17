# Security Guide

Padrões de segurança para Python backend.

## Autenticação

### JWT com access + refresh token

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

Regras:
- Access token: 15 minutos.
- Refresh token: 7 dias, armazenar hash no banco para revogar.
- Secret: mínimo 256 bits, rotacionável via config.
- Nunca hardcodar secret.

### Password hashing

```python
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)
```

Regras:
- Sempre bcrypt ou argon2.
- Nunca armazenar senha em texto plano.
- Nunca logar senha original.

## Autorização

### RBAC com dependency

```python
from fastapi import Depends, HTTPException

class RoleChecker:
    def __init__(self, allowed_roles: list[str]):
        self.allowed_roles = allowed_roles

    def __call__(self, current_user=Depends(get_current_user)):
        if current_user.role not in self.allowed_roles:
            raise HTTPException(status_code=403, detail="Sem permissão")
        return current_user

# Uso
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
        raise AppError(code="NOT_FOUND", message="Recurso não encontrado", status=404)
    if resource.owner_id != user_id:
        raise AppError(code="FORBIDDEN", message="Sem permissão", status=403)
    return resource
```

## Dados sensíveis (PII)

### O que é PII

- CPF, CNPJ, RG
- Email, telefone, endereço
- Data de nascimento
- Dados bancários, cartão
- IP em alguns contextos

### Regras

- Nunca logar PII.
- Nunca retornar PII em endpoint público.
- Criptografar PII no banco quando possível (pgcrypto).
- Mascaramento em responses parciais: `cpf: "***.***.***-11"`.

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

### Sempre validar com Pydantic

```python
class UserCreate(BaseModel):
    email: EmailStr
    name: str = Field(min_length=2, max_length=255)
    password: str = Field(min_length=8, max_length=128)
```

### Sanitização

```python
import re

def sanitize_filename(filename: str) -> str:
    # Remove path traversal
    name = os.path.basename(filename)
    # Remove chars perigosos
    return re.sub(r'[^a-zA-Z0-9._-]', '', name)
```

- Nunca concatenar input em SQL — sempre parametrizado (SQLAlchemy já faz).
- Nunca concatenar input em command — usar `subprocess` com lista.
- Nunca renderizar input em HTML sem escape (se serving HTML).

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

Aplicar em:
- Login: 5/min
- Reset password: 3/min
- Registro: 10/min
- API geral: 100/min

## Headers de segurança

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
    allow_origins=settings.cors_origins,  # lista explícita
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)
```

Nunca `allow_origins=["*"]` em produção.

## Secrets

- Nunca commitar `.env` — usar `.env.example`.
- Nunca logar secrets.
- Nunca retornar secrets em API.
- Nunca hardcodar em código.
- Usar variáveis de ambiente ou vault.
- Rotacionar secrets periodicamente.

## HTTPS

- Sempre HTTPS em produção.
- Redirect HTTP → HTTPS.
- HSTS header.
- Nunca servir credentials sem HTTPS.

## Regras duras

- Nunca logar senha, token, PII.
- Nunca armazenar senha em texto plano.
- Nunca usar `allow_origins=["*"]` em produção.
- Nunca commitar `.env`.
- Nunca concatenar input em SQL.
- Nunca servir HTTP em produção sem HTTPS.
- Nunca expor stack trace em produção.
- Nunca usar secret fraco ou default.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Não logar dados sensíveis**: Nunca logar senha, token, PII ou Authorization header.
- **Senha sempre hasheada**: Nunca armazenar senha em texto plano; usar bcrypt ou argon2.
- **CORS restrito em produção**: Nunca usar `allow_origins=["*"]` em produção.
- **Não commitar `.env`**: Nunca commitar `.env` real; usar `.env.example`.
- **SQL parametrizado**: Nunca concatenar input em SQL; sempre parametrizado.
- **HTTPS obrigatório em produção**: Nunca servir HTTP em produção sem HTTPS.
- **Sem stack trace em produção**: Nunca expor stack trace em resposta de produção.
- **Secret forte e rotacionável**: Nunca usar secret fraco, default ou hardcodado.
- **Não retornar PII em endpoint público**: Nunca retornar PII em endpoint sem autenticação/autorização.
- **Não logar senha original**: Nunca logar senha original mesmo durante hashing.
- **Não concatenar input em command**: Nunca concatenar input em command do sistema; usar lista.
- **Não servir credentials sem HTTPS**: Nunca enviar credentials em conexão não-HTTPS.
