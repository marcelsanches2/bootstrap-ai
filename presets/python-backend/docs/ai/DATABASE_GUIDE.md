# Database Guide

Database standards with SQLAlchemy 2.0 + Alembic + PostgreSQL.

## ORM and Query Builder

### Async setup

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

### Queries with select()

```python
from sqlalchemy import select, func

# Simple
result = await session.execute(select(User).where(User.id == user_id))
user = result.scalar_one_or_none()

# With join
result = await session.execute(
    select(User, Profile)
    .join(Profile, User.id == Profile.user_id)
    .where(User.is_active == True)
)

# With aggregation
result = await session.execute(
    select(func.count()).select_from(User).where(User.is_active == True)
)
total = result.scalar()
```

### Pagination with cursor (offset for simple lists)

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

For large tables (>1M), use cursor-based (keyset):

```python
async def list_cursor(session: AsyncSession, after_id: int | None, limit: int):
    q = select(User).order_by(User.id).limit(limit)
    if after_id:
        q = q.where(User.id > after_id)
    return (await session.execute(q)).scalars().all()
```

## Migrations (Alembic)

### Commands

```bash
# Auto-generate migration
alembic revision --autogenerate -m "add users table"

# Apply
alembic upgrade head

# Rollback 1
alembic downgrade -1

# Rollback to specific
alembic downgrade <revision>

# View history
alembic history

# View current
alembic current
```

### Migration rules

- Every migration MUST have `upgrade()` and `downgrade()`.
- Do not use `autogenerate` blindly — review before applying.
- Do not modify a migration already applied in production — create a new one.
- Do not delete data without explicit migration.
- Test downgrade before deploy.

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

## Indexes

Create index for:

- Columns used in frequent WHERE.
- JOIN columns (foreign keys).
- ORDER BY columns with WHERE.
- Search columns (email, slug, code).

```python
# In model
class User(Base):
    email: Mapped[str] = mapped_column(String(255), index=True)  # automatic

# Composite index
__table_args__ = (
    Index("ix_user_org_active", "organization_id", "is_active"),
)
```

## N+1 and eager loading

```python
# ❌ N+1: loads users, then 1 query per user to get profile
users = (await session.execute(select(User))).scalars().all()
for u in users:
    print(u.profile.name)  # +1 query per user

# ✓ Eager loading with selectinload
from sqlalchemy.orm import selectinload

users = (
    await session.execute(
        select(User).options(selectinload(User.profile))
    )
).scalars().all()
for u in users:
    print(u.profile.name)  # 0 extra queries
```

### When to use each strategy

- `selectinload`: best for collections (one-to-many, many-to-many).
- `joinedload`: best for many-to-one, single relationship.
- `subqueryload`: when you can't use IN (selectinload).
- `lazyload` (default): when certain you won't access.

## Transactions

### Commit and rollback

```python
async def create_user_with_profile(db: AsyncSession, data: UserCreate):
    try:
        user = User(email=data.email, name=data.name)
        db.add(user)
        await db.flush()  # generates ID without committing

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
# Row lock to prevent race condition
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
    ssn: Mapped[str] = mapped_column(String(11), unique=True)

    __table_args__ = (
    #   CheckConstraint("char_length(ssn) = 11", name="ck_user_ssn_length"),
    )
```

Leave constraints in the database, not only in the application.

## Seeds

Scripts in `scripts/seed_*.py`:

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

## Connections and pool

Config in engine:

- `pool_size`: permanent connections (default 5, production 20).
- `max_overflow`: extra on demand (default 10).
- `pool_timeout`: wait for free connection (default 30s).
- `pool_recycle`: recycle old connection (default -1, use 1800s).
- `pool_pre_ping`: verify connection before use (default True).

Monitor usage with:

```python
engine.pool.status()  # "Pool size: 5  Connections in pool: 3  Current Overflow: 0"
```

## Hard rules

- Do not use `SELECT *` — always explicit columns.
- Do not do N+1 — use eager loading.
- Do not commit migration without downgrade.
- Do not modify applied migration — create new one.
- Do not create table without index on FK.
- Do not use offset on table with >1M rows — use cursor.
- Do not execute query without timeout in production.
- Do not log sensitive database data.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Explicit columns**: Do not use `SELECT *`; always explicit columns.
- **No N+1**: Do not do N+1; use eager loading (`selectinload`, `joinedload`).
- **Migration with downgrade**: Do not commit migration without functional `downgrade()`.
- **Immutable migration in production**: Do not modify already applied migration; create new one.
- **Index on FK**: Do not create table without index on foreign key.
- **Cursor for large tables**: Do not use offset on table with >1M rows; use cursor-based.
- **Query with timeout**: Do not execute query without timeout in production.
- **Do not log sensitive data**: Do not log sensitive database data.
- **Constraint in database**: Leave constraints in the database, not only in the application.
- **Test downgrade**: Test migration downgrade before deploy.
