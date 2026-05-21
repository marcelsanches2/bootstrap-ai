# Feature Guide

How to develop new features in the Node.js backend.

## New feature step by step

### 1. Update Prisma schema

```prisma
model Order {
  id        Int      @id @default(autoincrement())
  userId    Int      @map("user_id")
  status    String   @default("pending") @db.VarChar(20)
  total     Decimal  @db.Decimal(10, 2)
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  user  User         @relation(fields: [userId], references: [id])
  items OrderItem[]

  @@index([userId])
  @@index([status])
  @@map("orders")
}

model OrderItem {
  id        Int    @id @default(autoincrement())
  orderId   Int    @map("order_id")
  productId Int    @map("product_id")
  quantity  Int
  unitPrice Decimal @map("unit_price") @db.Decimal(10, 2)

  order Order @relation(fields: [orderId], references: [id], onDelete: Cascade)

  @@index([orderId])
  @@map("order_items")
}
```

### 2. Migration

```bash
npx prisma migrate dev --name add_orders_table
```

### 3. Schema (Zod)

```typescript
export const createOrderSchema = z.object({
  body: z.object({
    items: z.array(z.object({
      productId: z.number().int().positive(),
      quantity: z.number().int().positive(),
      unitPrice: z.number().positive(),
    })).min(1),
    notes: z.string().optional(),
  }),
});
```

### 4. Repository

```typescript
export class OrdersRepository {
  constructor(private prisma: PrismaClient) {}

  async create(data: Prisma.OrderCreateInput) {
    return this.prisma.order.create({ data, include: { items: true } });
  }

  async findById(id: number) {
    return this.prisma.order.findUnique({ where: { id }, include: { items: true } });
  }
}
```

### 5. Service

```typescript
export class OrdersService {
  constructor(private prisma: PrismaClient) {}

  async create(userId: number, data: CreateOrderInput) {
    const total = data.items.reduce((sum, i) => sum + i.quantity * i.unitPrice, 0);
    return this.prisma.order.create({
      data: { userId, total, items: { create: data.items } },
      include: { items: true },
    });
  }
}
```

### 6. Controller

```typescript
export const OrdersController = {
  create: async (req: Request, res: Response) => {
    const service = new OrdersService(prisma);
    const order = await service.create(req.userId!, req.validated.body);
    res.status(201).json(order);
  },
};
```

### 7. Route

```typescript
router.post('/', authMiddleware, validate(createOrderSchema), OrdersController.create);
```

## Hard rules

- Always: schema → migration → repository → service → controller → route → test.
- Never skip a layer.
- Never create endpoints without Zod schema.
- Never create tables without migration.
- Never create features without tests.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any of the rules below.

- **Mandatory order**: schema → migration → repository → service → controller → route → test — never skip.
- **Never skip a layer**: Each layer has its own responsibility; do not combine.
- **Never create endpoints without Zod schema**: Every endpoint needs Zod validation.
- **Never create tables without migration**: Every database change goes through migration.
- **Never create features without tests**: Every feature must have at least tests for the change.
