# Feature Guide

Como desenvolver features novas no Python backend.

## Processo

1. Ler docs relevantes em `docs/ai/`.
2. Criar plano em `plans/YYYY-MM-DD-<slug>.md`.
3. Revisar com `/jarvis-plan-revisor`.
4. Implementar incrementalmente.
5. Validar com `/jarvis-test-flow`.
6. Checklist final com `/ship`.

## Nova feature passo a passo

### 1. Criar migration

```bash
alembic revision --autogenerate -m "add orders table"
```

Revisar e ajustar. Garantir downgrade:

```python
def upgrade():
    op.create_table(
        "orders",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("total", sa.Numeric(10, 2), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
    )
    op.create_index("ix_orders_user_id", "orders", ["user_id"])
    op.create_index("ix_orders_status", "orders", ["status"])

def downgrade():
    op.drop_index("ix_orders_status")
    op.drop_index("ix_orders_user_id")
    op.drop_table("orders")
```

### 2. Model

```python
# models/order.py
from datetime import datetime
from sqlalchemy import String, Numeric, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.models.base import Base, IDMixin, TimestampMixin

class Order(Base, IDMixin, TimestampMixin):
    __tablename__ = "orders"

    user_id: Mapped[int] = mapped_column()
    status: Mapped[str] = mapped_column(String(20), default="pending")
    total: Mapped[float] = mapped_column(Numeric(10, 2))

    items: Mapped[list["OrderItem"]] = relationship(back_populates="order", cascade="all, delete-orphan")
```

### 3. Schema

```python
# schemas/orders.py
from pydantic import BaseModel, Field
from datetime import datetime
from enum import str, Enum

class OrderStatus(str, Enum):
    pending = "pending"
    confirmed = "confirmed"
    shipped = "shipped"
    delivered = "delivered"
    cancelled = "cancelled"

class OrderItemCreate(BaseModel):
    product_id: int
    quantity: int = Field(ge=1)
    unit_price: float = Field(ge=0)

class OrderCreate(BaseModel):
    items: list[OrderItemCreate] = Field(min_length=1)
    notes: str | None = None

class OrderResponse(BaseModel):
    id: int
    user_id: int
    status: OrderStatus
    total: float
    created_at: datetime

    model_config = {"from_attributes": True}
```

### 4. Repository

```python
# repositories/orders.py
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from app.models.orders import Order, OrderItem

class OrderRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, order: Order) -> Order:
        self.db.add(order)
        await self.db.flush()
        return order

    async def get_by_id(self, order_id: int) -> Order | None:
        result = await self.db.execute(
            select(Order).options(selectinload(Order.items)).where(Order.id == order_id)
        )
        return result.scalar_one_or_none()

    async def list_by_user(self, user_id: int, skip: int = 0, limit: int = 20):
        count = await self.db.execute(
            select(func.count()).select_from(Order).where(Order.user_id == user_id)
        )
        total = count.scalar()

        result = await self.db.execute(
            select(Order)
            .where(Order.user_id == user_id)
            .order_by(Order.created_at.desc())
            .offset(skip).limit(limit)
        )
        return {"items": result.scalars().all(), "total": total, "skip": skip, "limit": limit}
```

### 5. Service

```python
# services/orders.py
from sqlalchemy.ext.asyncio import AsyncSession
from app.repositories.orders import OrderRepository
from app.schemas.orders import OrderCreate
from app.models.orders import Order, OrderItem
from app.utils.errors import AppError, NotFoundError

class OrderService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.repo = OrderRepository(db)

    async def create(self, user_id: int, payload: OrderCreate) -> Order:
        total = sum(item.quantity * item.unit_price for item in payload.items)

        order = Order(
            user_id=user_id,
            total=total,
            items=[OrderItem(**item.model_dump()) for item in payload.items],
        )
        order = await self.repo.create(order)
        await self.db.commit()
        await self.db.refresh(order)
        return order

    async def get(self, order_id: int) -> Order:
        order = await self.repo.get_by_id(order_id)
        if not order:
            raise NotFoundError("Pedido", order_id)
        return order
```

### 6. Router

```python
# routers/orders.py
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.dependencies import get_db, get_current_user
from app.schemas.orders import OrderCreate, OrderResponse
from app.services.orders import OrderService

router = APIRouter(prefix="/api/v1/orders", tags=["orders"])

@router.post("/", response_model=OrderResponse, status_code=201)
async def create_order(
    payload: OrderCreate,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
):
    service = OrderService(db)
    return await service.create(current_user.id, payload)

@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: int,
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user),
):
    service = OrderService(db)
    return await service.get(order_id)
```

## Regras duras

- Sempre: migration → model → schema → repository → service → router.
- Nunca pular camada.
- Nunca criar endpoint sem schema de request e response.
- Nunca criar tabela sem migration com downgrade.
- Testes seguem `docs/ai/TESTING_GUIDE.md`.
