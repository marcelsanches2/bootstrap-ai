# Database Guide

Padrões de banco de dados com Prisma ORM + PostgreSQL.

## Prisma Setup

```typescript
// config/database.ts
import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient({
  log: [
    { emit: 'event', level: 'query' },
  ],
});

prisma.$on('query', (e) => {
  if (e.duration > 500) {
    logger.warn({ query: e.query, duration: e.duration, params: e.params }, 'slow_query');
  }
});
```

## Schema (prisma/schema.prisma)

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id           Int      @id @default(autoincrement())
  email        String   @unique @db.VarChar(255)
  name         String   @db.VarChar(255)
  passwordHash String   @map("password_hash") @db.VarChar(255)
  isActive     Boolean  @default(true) @map("is_active")
  createdAt    DateTime @default(now()) @map("created_at")
  updatedAt    DateTime @updatedAt @map("updated_at")

  orders Order[]

  @@map("users")
}
```

## Queries

```typescript
// Criar
const user = await prisma.user.create({
  data: { email, name, passwordHash },
  select: { id: true, name: true, email: true, createdAt: true },
});

// Buscar por ID
const user = await prisma.user.findUnique({ where: { id } });

// Buscar com include (eager loading)
const order = await prisma.order.findUnique({
  where: { id: orderId },
  include: { items: true, user: { select: { id: true, name: true } } },
});

// Paginação
const [items, total] = await Promise.all([
  prisma.user.findMany({ skip, limit, orderBy: { id: 'asc' } }),
  prisma.user.count(),
]);

// Transação
const [order, account] = await prisma.$transaction([
  prisma.order.create({ data: orderData }),
  prisma.account.update({ where: { id: accountId }, data: { balance: { decrement: amount } } }),
]);

// Interactive transaction (para lógica entre steps)
await prisma.$transaction(async (tx) => {
  const account = await tx.account.findUnique({ where: { id: accountId } });
  if (!account || account.balance < amount) throw new AppError('CONFLICT', 'Saldo insuficiente', 409);
  await tx.account.update({ where: { id: accountId }, data: { balance: { decrement: amount } } });
  await tx.order.create({ data: orderData });
});
```

## Migrations

```bash
# Criar migration
npx prisma migrate dev --name add_orders_table

# Aplicar em produção
npx prisma migrate deploy

# Reset (desenvolvimento)
npx prisma migrate reset

# Status
npx prisma migrate status
```

Regras:
- Sempre revisar migration gerada antes de aplicar.
- Não editar migration aplicada — criar nova.
- Testar rollback (revert) antes de deploy.

## Índices

```prisma
model Order {
  userId Int @map("user_id")
  status String @db.VarChar(20)

  @@index([userId])
  @@index([status])
  @@index([userId, status])
  @@map("orders")
}
```

## N+1

Prisma faz eager loading com `include`:

```typescript
// ❌ N+1 manual
const users = await prisma.user.findMany();
for (const u of users) {
  const orders = await prisma.order.findMany({ where: { userId: u.id } });
}

// ✓ Eager loading
const users = await prisma.user.findMany({
  include: { orders: true },
});
```

## Seeds

```typescript
// prisma/seed.ts
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  await prisma.role.upsert({ where: { name: 'admin' }, update: {}, create: { name: 'admin' } });
  await prisma.role.upsert({ where: { name: 'user' }, update: {}, create: { name: 'user' } });
}

main().finally(() => prisma.$disconnect());
```

## Regras duras

- Não usar SELECT * — sempre `select` explícito em endpoints.
- Não fazer N+1 — usar `include`.
- Não commitar migration sem testar.
- Não criar tabela sem índice em FK.
- Não usar offset em tabela grande — cursor.
- Não logar dados sensíveis.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Não usar `SELECT *`**: Sempre usar `select` explícito em endpoints.
- **Não fazer N+1**: Usar `include` para eager loading.
- **Não commitar migration sem testar**: Migration deve ser testada antes de deploy.
- **Não criar tabela sem índice em FK**: Toda foreign key precisa de índice.
- **Não usar offset em tabela grande**: Usar cursor-based pagination quando volume for alto.
- **Não logar dados sensíveis**: Nunca logar senhas, tokens, PII.
- **Sempre revisar migration gerada antes de aplicar**: Validar SQL gerado pelo Prisma.
- **Não editar migration aplicada**: Criar nova migration para alterações.
- **Testar rollback antes de deploy**: Toda migration deve ter caminho de revert validado.
