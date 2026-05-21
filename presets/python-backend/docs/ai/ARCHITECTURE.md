# Architecture

Directory structure and architecture for the Python backend project.

## Overview

Python backend project with FastAPI, following a layered architecture with clear separation of responsibilities.

Data flow:

```
Request → Router → Schema (validation) → Service → Repository → Model → Database
                                    ↓
                                 Response Schema
```

Each layer has a single responsibility. Do not skip layers.

## Directory structure

```
<root>/
├── app/                        # Main source code
│   ├── __init__.py
│   ├── main.py                 # FastAPI entry point
│   ├── config.py               # Settings via pydantic-settings
│   ├── database.py             # Engine, session factory, base model
│   ├── dependencies.py         # Injectable dependencies (get_db, get_current_user, etc.)
│   │
│   ├── routers/                # Route definitions (controllers)
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
│   ├── services/               # Business logic
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   └── users.py
│   │
│   ├── repositories/           # Data access (queries, ORM)
│   │   ├── __init__.py
│   │   └── users.py
│   │
│   ├── models/                 # SQLAlchemy models (tables)
│   │   ├── __init__.py
│   │   ├── base.py             # Declarative base, mixins
│   │   └── users.py
│   │
│   ├── middleware/             # Custom middleware
│   │   ├── __init__.py
│   │   └── logging.py
│   │
│   └── utils/                  # Utility functions
│       ├── __init__.py
│       └── security.py
│
├── alembic/                    # Migrations
│   ├── versions/
│   ├── env.py
│   └── alembic.ini
│
├── tests/                      # Tests
│   ├── conftest.py             # Shared fixtures
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── scripts/                    # Helper scripts (seed, deploy, etc.)
├── pyproject.toml              # Project config (deps, lint, mypy)
├── Dockerfile
├── docker-compose.yml
├── .env.example
└── .env                        # Do NOT commit
```

## Layers and responsibilities

### Router (Controller)

- Receives HTTP request, calls service, returns HTTP response.
- Uses Pydantic schemas for input/output validation.
- Does not contain business logic.
- Does not access models or database directly.

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

- Data validation and serialization.
- Defines API contract (request/response).
- May have helper transformation methods.
- Does not access database.

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
            raise ValueError("Password must be at least 8 characters")
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

### Service (Business logic)

- Orchestrates business logic.
- Calls repository to access data.
- May call external services, queues, cache.
- Does not know HTTP (no request/response).
- Does not write SQL queries directly (uses repository).

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
            raise ValueError("Email already registered")

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

### Repository (Data access)

- Queries and database operations.
- Returns SQLAlchemy models or simple dicts.
- Does not contain business logic.
- May use ORM or raw queries for performance.

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

- Defines table and columns.
- Strong typing with Mapped.
- Mixins for common fields (id, created_at, updated_at).
- Does not contain business logic.

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

## Dependency injection

FastAPI uses `Depends()` for DI. Use for:

- Database session: `Depends(get_db)`
- Authenticated user: `Depends(get_current_user)`
- Config: `Depends(get_settings)`

Services should receive dependencies in the constructor, not via global import.

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

## Configuration

Use `pydantic-settings` for configuration:

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

Never hardcode configuration. Never access `os.environ` directly — go through Settings.

## Naming conventions

| Element | Convention | Example |
|---|---|---|
| Python file | snake_case | `user_service.py` |
| Class | PascalCase | `UserService` |
| Function/method | snake_case | `create_user()` |
| Constant | UPPER_SNAKE | `MAX_RETRIES` |
| Variable | snake_case | `user_count` |
| Route / endpoint | kebab-case | `/api/v1/user-profiles` |
| Table | plural snake_case | `user_profiles` |
| Column | snake_case | `created_at` |
| Migration | auto-generated | `add_user_profiles_table` |
| Environment variable | UPPER_SNAKE | `DATABASE_URL` |

## Anti-patterns

- Router calling `db.execute()` directly — skips service and repository.
- Service importing `Request` or `Response` from FastAPI — HTTP coupling.
- Model with business logic — it's data, not behavior.
- Repository with Pydantic validation — each layer has its role.
- `from app.main import app` in tests — use fixtures.
- N+1 query in loop — always eager load or select_related.
- `session.commit()` in repository — the service that orchestrates should commit.
- Circular import — use TYPE_CHECKING and string annotations.

## Hard rules

- Do not skip layers. Router → Service → Repository → Model. Always.
- Do not commit without migration when changing a model.
- Do not use `session.commit()` in repository — leave it to the service.
- Do not hardcode configuration — use Settings.
- Do not import models in routers — use schemas.
- Do not use sync SQLAlchemy in an async project — use `AsyncSession`.
- Do not create circular dependencies between modules.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Do not skip layers**: Router → Service → Repository → Model, always in this order.
- **Mandatory migration with model**: Do not commit model changes without a corresponding migration.
- **Service owns the commit**: Do not use `session.commit()` in repository.
- **Config via Settings**: Do not hardcode configuration; do not access `os.environ` directly.
- **Schemas in routers**: Do not import models in routers — use Pydantic schemas.
- **AsyncSession mandatory**: Do not use sync SQLAlchemy in an async project.
- **No circular dependencies**: Do not create circular dependencies between modules; use `TYPE_CHECKING`.
- **Router without business logic**: Router does not contain business logic nor accesses database directly.
- **Service without HTTP**: Service does not import `Request`/`Response` from FastAPI.
- **Model without behavior**: Model defines table/columns, does not contain business logic.
- **Repository without validation**: Repository does not do Pydantic validation.
- **Avoid N+1**: Query in loop must use eager load or select_related.
- **Do not commit `.env`**: `.env` file never goes into version control.
