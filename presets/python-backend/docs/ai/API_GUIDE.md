# API Guide

Convenções REST para APIs FastAPI.

## Versionamento

Prefixo de versão na URL:

```
/api/v1/users
/api/v2/users
```

No FastAPI:

```python
app = FastAPI()
v1_router = APIRouter(prefix="/api/v1")
app.include_router(v1_router)
```

Quando criar v2: mantenha v1 funcionando até migração completa. breaking change = versão nova.

## Rotas

### Convenção de endpoints

```
GET    /api/v1/users          # Listar
GET    /api/v1/users/:id      # Buscar por ID
POST   /api/v1/users          # Criar
PUT    /api/v1/users/:id      # Atualizar (completo)
PATCH  /api/v1/users/:id      # Atualizar (parcial)
DELETE /api/v1/users/:id      # Remover
```

### Nomenclatura

- Recursos no plural: `/users`, `/orders`, `/products`
- Kebab-case para compostos: `/user-profiles`, `/order-items`
- Não usar verbos: `/createUser` ❌, `/users` com POST ✓
- Não usar nested resources profundas (máx 2 níveis): `/users/:id/orders` ✓, `/users/:id/orders/:id/items` ❌

## Request

### Headers obrigatórios

```
Content-Type: application/json
Authorization: Bearer <token>    # quando autenticado
```

### Paginação

Query params padrão:

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

Limites: `limit` mínimo 1, máximo 100, default 20. Rejeitar fora do range.

### Filtros

Query params para filtros simples:

```
GET /api/v1/users?status=active&role=admin&created_after=2024-01-01
```

Para filtros complexos, use POST com body:

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

| Código | Quando usar |
|---|---|
| 200 | Sucesso (GET, PUT, PATCH) |
| 201 | Criado (POST) |
| 204 | Sem conteúdo (DELETE) |
| 400 | Validação de input falhou |
| 401 | Não autenticado |
| 403 | Autenticado mas sem permissão |
| 404 | Recurso não encontrado |
| 409 | Conflito (duplicado, estado inválido) |
| 422 | Unprocessable entity (Pydantic validation) |
| 429 | Rate limit excedido |
| 500 | Erro interno inesperado |

### Formato de erro

Consistente em toda a API:

```python
class ErrorDetail(BaseModel):
    code: str           # "VALIDATION_ERROR", "NOT_FOUND", "CONFLICT"
    message: str        # Mensagem humana
    field: str | None = None  # Campo que causou o erro, se aplicável

class ErrorResponse(BaseModel):
    error: ErrorDetail
```

Response:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email já cadastrado",
    "field": "email"
  }
}
```

### Error handler global

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

Nos services, levante `AppError`:

```python
raise AppError(code="NOT_FOUND", message="Usuário não encontrado", status=404)
raise AppError(code="CONFLICT", message="Email já cadastrado", status=409, field="email")
```

## Validação de input

Sempre com Pydantic:

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
            raise ValueError("Pedido deve ter pelo menos 1 item")
        return v

    @model_validator(mode="after")
    def delivery_date_is_future(self):
        if self.delivery_date <= date.today():
            raise ValueError("Data de entrega deve ser futura")
        return self
```

Não validar no router com `if/else`. Deixe no schema.

## Serialização

### Não expor campos internos

```python
# ❌ Nunca retornar password_hash, internal_id, etc.
class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    # password_hash intencionalmente omitido

    model_config = {"from_attributes": True}
```

### Datas em ISO 8601

```python
created_at: datetime  # serializa como "2024-01-15T10:30:00Z"
```

### Enums como string

```python
class UserRole(str, Enum):
    admin = "admin"
    user = "user"
```

## Rate limiting

Use `slowapi` ou middleware customizado:

```python
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@router.post("/login")
@limiter.limit("5/minute")
async def login(request: Request, payload: LoginRequest):
    ...
```

## Documentação automática

FastAPI gera OpenAPI/Swagger automaticamente em `/docs` e `/redoc`.

Personalize:

```python
app = FastAPI(
    title="API Nome",
    version="1.0.0",
    description="Descrição da API",
    docs_url="/docs",
    redoc_url="/redoc",
)
```

Adicione exemplos nos schemas:

```python
class UserCreate(BaseModel):
    name: str = Field(..., description="Nome completo", examples=["João Silva"])
    email: EmailStr = Field(..., description="Email válido", examples=["joao@email.com"])
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

Em produção: `allow_origins` com lista explícita, nunca `["*"]`.

## Regras duras

- Não usar status code 200 para tudo — use o código correto.
- Não retornar `{"success": true}` — use status code + schema.
- Não expor campos sensíveis em response (password_hash, tokens internos).
- Não validar input no router com if/else — use Pydantic.
- Não hardcodar URLs — use path params e named routes.
- Não criar endpoint sem schema de request e response.
- Não usar `str` para datas — use `datetime` ou `date`.
- Não retornar trace de erro em produção.
