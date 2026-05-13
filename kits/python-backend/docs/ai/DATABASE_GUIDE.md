# Database Guide

Padrões de banco de dados com SQLAlchemy 2.0 + Alembic + PostgreSQL.

## ORM e Query Builder

### Setup async

```python
# database.py
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from app.config import Settings

engine = create_async_engine(
    Settings().database_url,
    echo=False,
    pool_size=20,
    max_overflow=10,
    pool_timeout=30,
    pool_recycle=1800,
)

async_session_factory = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
```

### Queries com select()

```python
from sqlalchemy import select, func

# Simples
result = await session.execute(select(User).where(User.id == user_id))
user = result.scalar_one_or_none()

# Com join
result = await session.execute(
    select(User, Profile)
    .join(Profile, User.id == Profile.user_id)
    .where(User.is_active == True)
)

# Com agregação
result = await session.execute(
    select(func.count()).select_from(User).where(User.is_active == True)
)
total = result.scalar()
```

### Paginação com cursor (offset para listas simples)

```python
async def list_paginated(session: AsyncSession, skip: int, limit: int):
    # Count
    count_q = select(func.count()).select_from(User)
    total = (await session.execute(count_q)).scalar()

    # Data
    data_q = select(User).offset(skip).limit(limit).order_by(User.id)
    items = (await session.execute(data_q)).scalars().all()

    return {"items": items, "total": total, "skip": skip, "limit": limit}
```

Para tabelas grandes (>1M), use cursor-based (keyset):

```python
async def list_cursor(session: AsyncSession, after_id: int | None, limit: int):
    q = select(User).order_by(User.id).limit(limit)
    if after_id:
        q = q.where(User.id > after_id)
    return (await session.execute(q)).scalars().all()
```

## Migrations (Alembic)

### Comandos

```bash
# Gerar migration auto
alembic revision --autogenerate -m "add users table"

# Aplicar
alembic upgrade head

# Rollback 1
alembic downgrade -1

# Rollback para specific
alembic downgrade <revision>

# Ver histórico
alembic history

# Ver current
alembic current
```

### Regras de migration

- Toda migration DEVE ter `upgrade()` e `downgrade()`.
- Não usar `autogenerate` cegamente — revisar antes de aplicar.
- Não alterar migration já aplicada em produção — criar nova.
- Não deletar dados sem migration explícita.
- Testar downgrade antes de deploy.

```python
def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("email", sa.String(255), nullable=False),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("is_active", sa.Boolean(), server_default="true"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)

def downgrade() -> None:
    op.drop_index("ix_users_email")
    op.drop_table("users")
```

## Índices

Criar índice para:

- Colunas usadas em WHERE frequente.
- Colunas de JOIN (foreign keys).
- Colunas de ORDER BY com WHERE.
- Colunas de busca (email, slug, código).

```python
# No model
class User(Base):
    email: Mapped[str] = mapped_column(String(255), index=True)  # automático

# Índice composto
__table_args__ = (
    Index("ix_user_org_active", "organization_id", "is_active"),
)
```

## N+1 e eager loading

```python
# ❌ N+1: carrega users, depois 1 query por user para pegar profile
users = (await session.execute(select(User))).scalars().all()
for u in users:
    print(u.profile.name)  # +1 query por user

# ✓ Eager loading com selectinload
from sqlalchemy.orm import selectinload

users = (
    await session.execute(
        select(User).options(selectinload(User.profile))
    )
).scalars().all()
for u in users:
    print(u.profile.name)  # 0 queries extras
```

### Quando usar cada estratégia

- `selectinload`: melhor para coleções (one-to-many, many-to-many).
- `joinedload`: melhor para many-to-one, single relacionamento.
- `subqueryload`: quando não pode usar IN (selectinload).
- `lazyload` (default): quando certeza que não vai acessar.

## Transações

### Commit e rollback

```python
async def create_user_with_profile(db: AsyncSession, data: UserCreate):
    try:
        user = User(email=data.email, name=data.name)
        db.add(user)
        await db.flush()  # gera ID sem commitar

        profile = Profile(user_id=user.id, bio=data.bio)
        db.add(profile)

        await db.commit()
        await db.refresh(user)
        return user
    except Exception:
        await db.rollback()
        raise
```

### Pessimistic locking

```python
# Lock de linha para evitar race condition
result = await session.execute(
    select(Account)
    .where(Account.id == account_id)
    .with_for_update()
)
account = result.scalar_one()
account.balance -= amount
await session.commit()
```

## Constraints

```python
class User(Base):
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    cpf: Mapped[str] = mapped_column(String(11), unique=True)

    __table_args__ = (
    #   CheckConstraint("char_length(cpf) = 11", name="ck_user_cpf_length"),
    )
```

Deixar constraint no banco, não só na aplicação.

## Seeds

Scripts em `scripts/seed_*.py`:

```python
# scripts/seed_roles.py
import asyncio
from sqlalchemy import select
from app.database import async_session_factory
from app.models import Role

async def seed():
    async with async_session_factory() as session:
        for name in ["admin", "user", "viewer"]:
            existing = await session.execute(select(Role).where(Role.name == name))
            if not existing.scalar_one_or_none():
                session.add(Role(name=name))
        await session.commit()

asyncio.run(seed())
```

## Conexões e pool

Config no engine:

- `pool_size`: conexões permanentes (default 5, production 20).
- `max_overflow`: extra sob demanda (default 10).
- `pool_timeout`: espera por conexão livre (default 30s).
- `pool_recycle`: recicla conexão velha (default -1, usar 1800s).
- `pool_pre_ping`: verifica conexão antes de usar (default True).

Monitorar uso com:

```python
engine.pool.status()  # "Pool size: 5  Connections in pool: 3  Current Overflow: 0"
```

## Regras duras

- Não usar `SELECT *` — sempre colunas explícitas.
- Não fazer N+1 — usar eager loading.
- Não commitar migration sem downgrade.
- Não alterar migration aplicada — criar nova.
- Não criar tabela sem índice em FK.
- Não usar offset em tabela com >1M linhas — usar cursor.
- Não executar query sem timeout em produção.
- Não logar dados sensíveis do banco.
