# Architecture

Directory structure and architecture for the Node.js backend project.

## Overview

Node.js backend project with TypeScript, following a layered architecture with clear separation of responsibilities.

Data flow:

```
Request → Router/Controller → Schema (Zod validation) → Service → Repository → Model → Database
```

## Directory structure

```
<root>/
├── src/
│   ├── index.ts                  # Entry point (Express/Fastify)
│   ├── config/
│   │   ├── index.ts              # Config via env vars (zod validated)
│   │   └── database.ts           # Prisma client singleton
│   │
│   ├── routes/                   # Route definitions
│   │   ├── index.ts              # Router aggregator
│   │   ├── auth.routes.ts
│   │   └── users.routes.ts
│   │
│   ├── controllers/              # HTTP handlers
│   │   ├── auth.controller.ts
│   │   └── users.controller.ts
│   │
│   ├── schemas/                  # Zod schemas (validation)
│   │   ├── auth.schema.ts
│   │   └── users.schema.ts
│   │
│   ├── services/                 # Business logic
│   │   ├── auth.service.ts
│   │   └── users.service.ts
│   │
│   ├── repositories/             # Data access (Prisma queries)
│   │   ├── users.repository.ts
│   │   └── orders.repository.ts
│   │
│   ├── middleware/               # Middleware (auth, logging, error)
│   │   ├── auth.middleware.ts
│   │   ├── error.middleware.ts
│   │   └── logging.middleware.ts
│   │
│   ├── utils/                    # Helpers
│   │   ├── hash.ts
│   │   └── errors.ts
│   │
│   └── types/                    # TypeScript types/interfaces
│       └── express.d.ts
│
├── prisma/
│   ├── schema.prisma             # Database schema
│   ├── migrations/               # Auto-generated migrations
│   └── seed.ts                   # Initial data
│
├── tests/
│   ├── setup.ts                  # Test setup
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── package.json
├── tsconfig.json
├── .env.example
└── .env                          # Do NOT commit
```

## Layers and responsibilities

### Route → Controller

```typescript
// routes/users.routes.ts
import { Router } from 'express';
import { UsersController } from '../controllers/users.controller';
import { authMiddleware } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate';
import { createUserSchema, listUsersSchema } from '../schemas/users.schema';

const router = Router();

router.post('/', validate(createUserSchema), UsersController.create);
router.get('/', authMiddleware, validate(listUsersSchema), UsersController.list);
router.get('/:id', authMiddleware, UsersController.getById);

export { router as usersRoutes };
```

### Schema (Zod)

```typescript
// schemas/users.schema.ts
import { z } from 'zod';

export const createUserSchema = z.object({
  body: z.object({
    name: z.string().min(2).max(255),
    email: z.string().email(),
    password: z.string().min(8).max(128),
  }),
});

export const listUsersSchema = z.object({
  query: z.object({
    skip: z.coerce.number().int().min(0).default(0),
    limit: z.coerce.number().int().min(1).max(100).default(20),
  }),
});

export type CreateUserInput = z.infer<typeof createUserSchema>['body'];
```

### Service

```typescript
// services/users.service.ts
import { PrismaClient } from '@prisma/client';
import { CreateUserInput } from '../schemas/users.schema';
import { hashPassword } from '../utils/hash';
import { AppError } from '../utils/errors';

export class UsersService {
  constructor(private prisma: PrismaClient) {}

  async create(data: CreateUserInput) {
    const existing = await this.prisma.user.findUnique({ where: { email: data.email } });
    if (existing) throw new AppError('CONFLICT', 'Email already registered', 409);

    const passwordHash = await hashPassword(data.password);
    return this.prisma.user.create({
      data: { name: data.name, email: data.email, passwordHash },
      select: { id: true, name: true, email: true, createdAt: true },
    });
  }

  async list(skip: number, limit: number) {
    const [items, total] = await Promise.all([
      this.prisma.user.findMany({ skip, limit, orderBy: { id: 'asc' } }),
      this.prisma.user.count(),
    ]);
    return { items, total, skip, limit };
  }
}
```

### Repository Pattern (when direct Prisma is not enough)

```typescript
// repositories/orders.repository.ts
import { PrismaClient, Prisma } from '@prisma/client';

export class OrdersRepository {
  constructor(private prisma: PrismaClient) {}

  async findByIdWithItems(orderId: number) {
    return this.prisma.order.findUnique({
      where: { id: orderId },
      include: { items: true },
    });
  }

  async createWithItems(data: Prisma.OrderCreateInput) {
    return this.prisma.order.create({ data, include: { items: true } });
  }
}
```

## Configuration

```typescript
// config/index.ts
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string().min(32),
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  CORS_ORIGINS: z.string().default(''),
});

export const config = envSchema.parse(process.env);
```

## Naming conventions

| Element | Convention | Example |
|---|---|---|
| File | kebab-case | user-service.ts |
| Class | PascalCase | UsersService |
| Function | camelCase | createUser() |
| Constant | UPPER_SNAKE | MAX_RETRIES |
| Interface | PascalCase + I prefix optional | UserProfile |
| Type | PascalCase | OrderStatus |
| Enum | PascalCase | OrderStatus.Pending |
| Table | PascalCase (Prisma) | User, Order |
| Field | camelCase (Prisma) | createdAt |
| Route | kebab-case | /api/v1/user-profiles |

## Anti-patterns

- Controller with business logic — belongs in the service.
- Service with req/res — does not know HTTP.
- Raw SQL when Prisma works — only raw for critical performance.
- `any` in TypeScript — use specific type or `unknown`.
- Circular import — use dependency injection.
- Console.log in production — use structured logger.

## Hard rules

- Do not skip layers. Controller → Service → Repository → Prisma.
- Do not use `any` without documented justification.
- Do not commit without `tsc --noEmit` passing.
- Do not create endpoints without Zod schema for request and response.
- Do not hardcode config — use env vars via zod.
- Do not use `require()` — always ES modules or import.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any of the rules below.

- **Do not skip layers**: Controller → Service → Repository → Prisma — always respect the flow.
- **Do not use `any` without documented justification**: Use specific type or `unknown`.
- **Do not commit without `tsc --noEmit` passing**: Type checking must be clean before commit.
- **Do not create endpoints without Zod schema**: Every endpoint needs request and response schema.
- **Do not hardcode config**: Use env vars via Zod validation.
- **Do not use `require()`**: Always ES modules or import.
- **Controller must not have business logic**: Logic belongs in the service.
- **Service must not know req/res**: Do not import anything HTTP in the service.
- **Do not use raw SQL when Prisma works**: Only raw for critical performance.
- **Do not use circular imports**: Use dependency injection.
- **Do not use `console.log` in production**: Use structured logger.
