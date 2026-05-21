# Database Guide

Database standards with Prisma ORM + PostgreSQL.

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
// Create
const user = await prisma.user.create({
  data: { email, name, passwordHash },
  select: { id: true, name: true, email: true, createdAt: true },
});

// Find by ID
const user = await prisma.user.findUnique({ where: { id } });

// Find with include (eager loading)
const order = await prisma.order.findUnique({
  where: { id: orderId },
  include: { items: true, user: { select: { id: true, name: true } } },
});

// Pagination
const [items, total] = await Promise.all([
  prisma.user.findMany({ skip, limit, orderBy: { id: 'asc' } }),
  prisma.user.count(),
]);

// Transaction
const [order, account] = await prisma.$transaction([
  prisma.order.create({ data: orderData }),
  prisma.account.update({ where: { id: accountId }, data: { balance: { decrement: amount } } }),
]);

// Interactive transaction (for logic between steps)
await prisma.$transaction(async (tx) => {
  const account = await tx.account.findUnique({ where: { id: accountId } });
  if (!account || account.balance < amount) throw new AppError('CONFLICT', 'Insufficient balance', 409);
  await tx.account.update({ where: { id: accountId }, data: { balance: { decrement: amount } } });
  await tx.order.create({ data: orderData });
});
```

## Migrations

```bash
# Create migration
npx prisma migrate dev --name add_orders_table

# Apply in production
npx prisma migrate deploy

# Reset (development)
npx prisma migrate reset

# Status
npx prisma migrate status
```

Rules:
- Always review generated migration before applying.
- Do not edit applied migrations — create a new one.
- Test rollback (revert) before deploy.

## Indexes

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

Prisma does eager loading with `include`:

```typescript
// ❌ Manual N+1
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

## Hard rules

- Do not use SELECT * — always explicit `select` in endpoints.
- Do not do N+1 — use `include`.
- Do not commit migration without testing.
- Do not create table without index on FK.
- Do not use offset on large tables — use cursor.
- Do not log sensitive data.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any of the rules below.

- **Do not use `SELECT *`**: Always use explicit `select` in endpoints.
- **Do not do N+1**: Use `include` for eager loading.
- **Do not commit migration without testing**: Migration must be tested before deploy.
- **Do not create table without index on FK**: Every foreign key needs an index.
- **Do not use offset on large tables**: Use cursor-based pagination when volume is high.
- **Do not log sensitive data**: Never log passwords, tokens, PII.
- **Always review generated migration before applying**: Validate Prisma-generated SQL.
- **Do not edit applied migrations**: Create a new migration for changes.
- **Test rollback before deploy**: Every migration must have a validated revert path.
