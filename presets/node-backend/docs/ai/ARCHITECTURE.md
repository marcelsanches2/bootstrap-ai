# Architecture

Estrutura de diretórios e arquitetura do projeto Node.js backend.

## Visão geral

Projeto backend em Node.js com TypeScript, seguindo arquitetura em camadas com separação clara de responsabilidades.

Fluxo de dados:

```
Request → Router/Controller → Schema (Zod validation) → Service → Repository → Model → Banco
```

## Estrutura de diretórios

```
<raiz>/
├── src/
│   ├── index.ts                  # Entry point (Express/Fastify)
│   ├── config/
│   │   ├── index.ts              # Config via env vars (zod validated)
│   │   └── database.ts           # Prisma client singleton
│   │
│   ├── routes/                   # Definição de rotas
│   │   ├── index.ts              # Router aggregator
│   │   ├── auth.routes.ts
│   │   └── users.routes.ts
│   │
│   ├── controllers/              # Handlers HTTP
│   │   ├── auth.controller.ts
│   │   └── users.controller.ts
│   │
│   ├── schemas/                  # Zod schemas (validação)
│   │   ├── auth.schema.ts
│   │   └── users.schema.ts
│   │
│   ├── services/                 # Lógica de negócio
│   │   ├── auth.service.ts
│   │   └── users.service.ts
│   │
│   ├── repositories/             # Acesso a dados (Prisma queries)
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
│   ├── schema.prisma             # Schema do banco
│   ├── migrations/               # Migrations auto-geradas
│   └── seed.ts                   # Dados iniciais
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
└── .env                          # NÃO commitar
```

## Camadas e responsabilidades

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
    if (existing) throw new AppError('CONFLICT', 'Email já cadastrado', 409);

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

### Repository Pattern (quando Prisma direto não basta)

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

## Configuração

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

## Convenções de nomenclatura

| Elemento | Convenção | Exemplo |
|---|---|---|
| Arquivo | kebab-case | user-service.ts |
| Classe | PascalCase | UsersService |
| Função | camelCase | createUser() |
| Constante | UPPER_SNAKE | MAX_RETRIES |
| Interface | PascalCase + I prefix opcional | UserProfile |
| Type | PascalCase | OrderStatus |
| Enum | PascalCase | OrderStatus.Pending |
| Tabela | PascalCase (Prisma) | User, Order |
| Campo | camelCase (Prisma) | createdAt |
| Rota | kebab-case | /api/v1/user-profiles |

## Anti-patterns

- Controller com lógica de negócio — pertence ao service.
- Service com req/res — não conhece HTTP.
- Raw SQL quando Prisma resolve — só raw para performance crítica.
- `any` em TypeScript — usar tipo específico ou `unknown`.
- Import circular — usar dependency injection.
- Console.log em produção — usar logger estruturado.

## Regras duras

- Não pular camadas. Controller → Service → Repository → Prisma.
- Não usar `any` sem justificativa documentada.
- Não commitar sem `tsc --noEmit` passando.
- Não criar endpoint sem Zod schema de request e response.
- Não hardcodar config — usar env vars via zod.
- Não usar `require()` — sempre ES modules ou import.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Não pular camadas**: Controller → Service → Repository → Prisma — respeitar sempre o fluxo.
- **Não usar `any` sem justificativa documentada**: Usar tipo específico ou `unknown`.
- **Não commitar sem `tsc --noEmit` passando**: Type checking deve estar limpo antes de commit.
- **Não criar endpoint sem Zod schema**: Todo endpoint precisa de schema de request e response.
- **Não hardcodar config**: Usar env vars via Zod validação.
- **Não usar `require()`**: Sempre ES modules ou import.
- **Controller não deve ter lógica de negócio**: Lógica pertence ao service.
- **Service não deve conhecer req/res**: Não importar nada de HTTP no service.
- **Não usar raw SQL quando Prisma resolve**: Só raw para performance crítica.
- **Não usar import circular**: Usar dependency injection.
- **Não usar `console.log` em produção**: Usar logger estruturado.
