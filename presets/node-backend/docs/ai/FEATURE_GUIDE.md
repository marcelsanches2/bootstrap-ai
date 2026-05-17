# Feature Guide

Como desenvolver features novas no Node.js backend.

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

## Regras duras

- Sempre: schema → migration → repository → service → controller → route → teste.
- Nunca pular camada.
- Nunca criar endpoint sem Zod schema.
- Nunca criar tabela sem migration.
- Nunca criar feature sem teste.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Ordem obrigatória**: schema → migration → repository → service → controller → route → teste — nunca pular.
- **Nunca pular camada**: Cada camada tem responsabilidade própria; não combinar.
- **Nunca criar endpoint sem Zod schema**: Todo endpoint precisa de validação com Zod.
- **Nunca criar tabela sem migration**: Toda mudança no banco passa por migration.
- **Nunca criar feature sem teste**: Toda feature deve ter pelo menos teste da mudança.
