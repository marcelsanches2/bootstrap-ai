# Architecture

Estrutura de diretórios e arquitetura do projeto Python backend.

## Visão geral

Projeto backend em Python com FastAPI, seguindo arquitetura em camadas com separação clara de responsabilidades.

Fluxo de dados:

```
Request → Router → Schema (validação) → Service → Repository → Model → Banco
                                    ↓
                                 Response Schema
```

Cada camada tem uma responsabilidade única. Não pular camadas.

## Estrutura de diretórios

```
<raiz>/
├── app/                        # Código fonte principal
│   ├── __init__.py
│   ├── main.py                 # Entry point FastAPI
│   ├── config.py               # Settings via pydantic-settings
│   ├── database.py             # Engine, session factory, base model
│   ├── dependencies.py         # Dependências injetáveis (get_db, get_current_user, etc.)
│   │
│   ├── routers/                # Definição de rotas (controllers)
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── users.py
│   │   └── health.py
│   │
│   ├── schemas/                # Pydantic models (request/response)
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   └── users.py
│   │
│   ├── services/               # Lógica de negócio
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   └── users.py
│   │
│   ├── repositories/           # Acesso a dados (queries, ORM)
│   │   ├── __init__.py
│   │   └── users.py
│   │
│   ├── models/                 # SQLAlchemy models (tabelas)
│   │   ├── __init__.py
│   │   ├── base.py             # Base declarativa, mixins
│   │   └── users.py
│   │
│   ├── middleware/             # Middleware customizado
│   │   ├── __init__.py
│   │   └── logging.py
│   │
│   └── utils/                  # Funções utilitárias
│       ├── __init__.py
│       └── security.py
│
├── alembic/                    # Migrations
│   ├── versions/
│   ├── env.py
│   └── alembic.ini
│
├── tests/                      # Testes
│   ├── conftest.py             # Fixtures compartilhadas
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── scripts/                    # Scripts auxiliares (seed, deploy, etc.)
├── pyproject.toml              # Config do projeto (deps, lint, mypy)
├── Dockerfile
├── docker-compose.yml
├── .env.example
└── .env                        # NÃO commitar
```

## Camadas e responsabilidades

### Router (Controller)

- Recebe HTTP request, chama service, retorna HTTP response.
- Usa schemas Pydantic para validação de entrada/saída.
- Não contém lógica de negócio.
- Não acessa models ou banco diretamente.

```python
# routers/users.py
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db, get_current_user
from app.schemas.users import UserCreate, UserResponse, UserList
from app.services.users import UserService

router = APIRouter(prefix="/users", tags=["users"])

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    payload: UserCreate,
    db: AsyncSession = Depends(get_db),
):
    service = UserService(db)
    return await service.create(payload)

@router.get("/", response_model=UserList)
async def list_users(
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
):
    service = UserService(db)
    return await service.list(skip=skip, limit=limit)
```

### Schema (Pydantic)

- Validação e serialização de dados.
- Define contrato da API (request/response).
- Pode ter métodos auxiliares de transformação.
- Não acessa banco.

```python
# schemas/users.py
from pydantic import BaseModel, EmailStr, field_validator
from datetime import datetime
from typing import Optional

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str

    @field_validator("password")
    @classmethod
    def password_min_length(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError("Senha deve ter pelo menos 8 caracteres")
        return v

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    created_at: datetime

    model_config = {"from_attributes": True}

class UserList(BaseModel):
    items: list[UserResponse]
    total: int
    skip: int
    limit: int
```

### Service (Lógica de negócio)

- Orquestra a lógica de negócio.
- Chama repository para acessar dados.
- Pode chamar services externos, filas, cache.
- Não conhece HTTP (sem request/response).
- Não escreve queries SQL diretamente (usa repository).

```python
# services/users.py
from sqlalchemy.ext.asyncio import AsyncSession
from app.repositories.users import UserRepository
from app.schemas.users import UserCreate
from app.utils.security import hash_password

class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.repo = UserRepository(db)

    async def create(self, payload: UserCreate) -> dict:
        existing = await self.repo.get_by_email(payload.email)
        if existing:
            raise ValueError("Email já cadastrado")

        hashed = hash_password(payload.password)
        user = await self.repo.create(
            name=payload.name,
            email=payload.email,
            password_hash=hashed,
        )
        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def list(self, skip: int = 0, limit: int = 50) -> dict:
        return await self.repo.list_paginated(skip=skip, limit=limit)
```

### Repository (Acesso a dados)

- Queries e operações no banco.
- Retorna models SQLAlchemy ou dicts simples.
- Não contém lógica de negócio.
- Pode usar ORM ou queries raw para performance.

```python
# repositories/users.py
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.users import User

class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_email(self, email: str) -> User | None:
        result = await self.db.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()

    async def create(self, **kwargs) -> User:
        user = User(**kwargs)
        self.db.add(user)
        return user

    async def list_paginated(self, skip: int = 0, limit: int = 50) -> dict:
        # Count
        count_result = await self.db.execute(
            select(func.count()).select_from(User)
        )
        total = count_result.scalar()

        # Data
        result = await self.db.execute(
            select(User).offset(skip).limit(limit).order_by(User.id)
        )
        items = result.scalars().all()

        return {"items": items, "total": total, "skip": skip, "limit": limit}
```

### Model (SQLAlchemy)

- Define tabela e colunas.
- Tipagem forte com Mapped.
- Mixins para campos comuns (id, created_at, updated_at).
- Não contém lógica de negócio.

```python
# models/base.py
from datetime import datetime
from sqlalchemy import DateTime, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(DeclarativeBase):
    pass

class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

class IDMixin:
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
```

## Injeção de dependência

FastAPI usa `Depends()` para DI. Use para:

- Sessão de banco: `Depends(get_db)`
- Usuário autenticado: `Depends(get_current_user)`
- Config: `Depends(get_settings)`

Services recebam dependências no construtor, não via import global.

```python
# dependencies.py
from app.config import Settings

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_factory() as session:
        try:
            yield session
        finally:
            await session.close()

def get_settings() -> Settings:
    return Settings()
```

## Configuração

Use `pydantic-settings` para configuração:

```python
# config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    debug: bool = False
    cors_origins: list[str] = []

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}
```

Nunca hardcodar configuração. Nunca acessar `os.environ` diretamente — passe pelo Settings.

## Convenções de nomenclatura

| Elemento | Convenção | Exemplo |
|---|---|---|
| Arquivo Python | snake_case | `user_service.py` |
| Classe | PascalCase | `UserService` |
| Função/método | snake_case | `create_user()` |
| Constante | UPPER_SNAKE | `MAX_RETRIES` |
| Variável | snake_case | `user_count` |
| Rota / endpoint | kebab-case | `/api/v1/user-profiles` |
| Tabela | snake_case plural | `user_profiles` |
| Coluna | snake_case | `created_at` |
| Migration | auto-gerada | `add_user_profiles_table` |
| Variável de ambiente | UPPER_SNAKE | `DATABASE_URL` |

## Anti-patterns

- Router chamando `db.execute()` diretamente — pula service e repository.
- Service importando `Request` ou `Response` do FastAPI — acoplamento HTTP.
- Model com lógica de negócio — é dado, não comportamento.
- Repository com validação Pydantic — cada camada tem seu papel.
- `from app.main import app` em testes — use fixtures.
- Query N+1 em loop — sempre eager load ou select_related.
- `session.commit()` no repository — quem commita é o service que orquestra.
- Import circular — use TYPE_CHECKING e string annotations.

## Regras duras

- Não pular camadas. Router → Service → Repository → Model. Sempre.
- Não commitar sem migration quando alterar model.
- Não usar `session.commit()` em repository — deixe para o service.
- Não hardcodar configuração — use Settings.
- Não importar models em routers — use schemas.
- Não usar sync SQLAlchemy em projeto async — use `AsyncSession`.
- Não criar dependência circular entre módulos.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Não pular camadas**: Router → Service → Repository → Model, sempre nesta ordem.
- **Migration obrigatória com model**: Não commitar alteração em model sem migration correspondente.
- **Service é dono do commit**: Não usar `session.commit()` em repository.
- **Config via Settings**: Não hardcodar configuração; não acessar `os.environ` diretamente.
- **Schemas em routers**: Não importar models em routers — use schemas Pydantic.
- **AsyncSession obrigatório**: Não usar sync SQLAlchemy em projeto async.
- **Sem dependência circular**: Não criar dependência circular entre módulos; use `TYPE_CHECKING`.
- **Router sem lógica de negócio**: Router não contém lógica de negócio nem acessa banco diretamente.
- **Service sem HTTP**: Service não importa `Request`/`Response` do FastAPI.
- **Model sem comportamento**: Model define tabela/colunas, não contém lógica de negócio.
- **Repository sem validação**: Repository não faz validação Pydantic.
- **Evitar N+1**: Query em loop deve usar eager load ou select_related.
- **Não commitar `.env`**: Arquivo `.env` nunca entra no versionamento.
