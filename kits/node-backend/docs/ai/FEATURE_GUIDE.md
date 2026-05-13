# Feature Guide

Como desenvolver features novas no Node.js backend.

## Processo

1. Ler docs relevantes em `docs/ai/`.
2. Criar plano em `plans/YYYY-MM-DD-<slug>.md`.
3. Revisar com `/jarvis-revisor`.
4. Implementar incrementalmente.
5. Validar com `/test-flow`.
6. Checklist final com `/ship`.

## Nova feature passo a passo

### 1. Atualizar Prisma schema

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

### 8. Teste

```typescript
it('POST /api/v1/orders should return 201', async () => {
  const res = await request(app)
    .post('/api/v1/orders')
    .set('Authorization', `Bearer ${token}`)
    .send({ items: [{ productId: 1, quantity: 2, unitPrice: 29.90 }] });
  expect(res.status).toBe(201);
  expect(res.body.status).toBe('pending');
});
```

## Regras duras

- Sempre: schema → migration → repository → service → controller → route → teste.
- Nunca pular camada.
- Nunca criar endpoint sem Zod schema.
- Nunca criar tabela sem migration.
- Nunca criar feature sem teste.
