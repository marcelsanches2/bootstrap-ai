# Fullstack Web Architecture

## Overview

Fullstack application with frontend and backend in the same monorepo repository. The frontend (Next.js App Router or Remix) and the backend (API layers) share types, schemas, and utilities, but maintain clear boundaries.

**Backend flow:**

```
Request → Route → Controller → Schema (Zod) → Service → Repository → Database → Response
```

**Frontend flow:**

```
Database → Server Component / API Route → Client Component → UI
```

The meeting point is the `shared/` layer: types, constants, and Zod schemas are consumed by both server and client, ensuring a single contract.

---

## Directory structure

```txt
src/
  app/ (or pages/)              # Routes, pages, layouts (Next.js App Router / Remix)
  components/                   # Shared UI components
  hooks/                        # Shared React hooks
  server/                       # Backend layers
    config/                     # Env vars validated via Zod, DB client singleton
    routes/                     # HTTP route handlers
    controllers/                # Request orchestration
    schemas/                    # Zod validation schemas (request/response)
    services/                   # Business logic
    repositories/               # Data access (Prisma queries)
  shared/                       # Code shared frontend ↔ backend
    utils/                      # Pure helpers
    types/                      # Shared TypeScript types/interfaces
    api/                        # API client (frontend → backend)
    constants/                  # Domain constants
  features/<name>/              # Optional feature colocation
    components/
    hooks/
    api/
    server/                     # Feature server-side logic
prisma/
  schema.prisma                 # Database schema
  migrations/                   # Auto-generated migrations
  seed.ts                       # Initial data
```

---

## Layers — Frontend

### Component hierarchy

```
Page (loads data, assembles layout)
  → Container (coordinates state and callbacks)
    → UI Component (receives props, renders markup)
```

- **Page**: orchestrates data fetching and high-level layout. Can be a Server Component or client-side.
- **UI Components**: receive explicit props, do not call API directly, do not manage global state.
- **Hooks**: encapsulate data fetching, events, and browser integration.

### Data fetching

- Centralize the HTTP client and error handling in `shared/api/`.
- Use TanStack Query for cache and server state.
- Always define loading, error, empty, and retry states.

```typescript
// hooks/useUsers.ts
export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => apiClient.get('/users'),
  });
}
```

### State decision

| State type | Solution | When to use |
|---|---|---|
| Component local | `useState` / `useReducer` | Toggle, form input, selection |
| Navigable / shareable | URL search params | Filters, pagination, active tab |
| Remote data | TanStack Query | Any server data |
| Global client-side | Zustand / Context | Theme, locale, auth state |

### Routes

- Public and protected routes declared explicitly.
- New screen must declare path, params, and navigation behavior.
- Use a centralized route map, never loose repeated strings.

### Frontend errors

- API error must become renderable state.
- Error boundaries in critical UI areas.
- Technical message never leaks to the end user.

---

## Layers — Backend

Complete request pipeline:

```
Route → Controller → Schema → Service → Repository → Prisma → Database
```

### Route → Controller

Route defines only the HTTP binding (path, method, middleware, handler).

```typescript
// server/routes/users.routes.ts
import { Router } from 'express';
import { UsersController } from '../controllers/users.controller';
import { validate } from '../middleware/validate';
import { createUserSchema } from '../schemas/users.schema';

const router = Router();
router.post('/', validate(createUserSchema), UsersController.create);
router.get('/', authMiddleware, UsersController.list);
export { router as usersRoutes };
```

### Schema (Zod)

Input and output validation. Each endpoint has a request schema.

```typescript
// server/schemas/users.schema.ts
import { z } from 'zod';

export const createUserSchema = z.object({
  body: z.object({
    name: z.string().min(2).max(255),
    email: z.string().email(),
    password: z.string().min(8).max(128),
  }),
});

export type CreateUserInput = z.infer<typeof createUserSchema>['body'];
```

### Service

Pure business logic. Does not know HTTP (no req/res).

```typescript
// server/services/users.service.ts
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
}
```

### Repository

Data access. When direct Prisma in the service suffices, use it directly. When queries are complex or reused, extract to a repository.

```typescript
// server/repositories/orders.repository.ts
export class OrdersRepository {
  constructor(private prisma: PrismaClient) {}

  async findByIdWithItems(orderId: number) {
    return this.prisma.order.findUnique({
      where: { id: orderId },
      include: { items: true },
    });
  }
}
```

### Configuration (env vars via Zod)

```typescript
// server/config/index.ts
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string().min(32),
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
});

export const config = envSchema.parse(process.env);
```

Each layer has **a single responsibility**. Service never imports Express. Repository never validates input. Controller never makes direct queries.

---

## Server Components boundary

### What runs on server vs client

| Concept | Server | Client |
|---|---|---|
| Database / ORM access | ✅ | ❌ |
| Env vars / secrets | ✅ | ❌ |
| Business logic | ✅ | ❌ |
| Initial data fetching | ✅ | Optional (TanStack Query) |
| Interactivity (onClick, useState) | ❌ | ✅ |
| Browser APIs (localStorage, window) | ❌ | ✅ |
| Side effects (useEffect) | ❌ | ✅ |

### When to use `'use client'`

Only when the component needs:
- Event handlers (onClick, onChange)
- State hooks (useState, useReducer)
- Effect hooks (useEffect, useLayoutEffect)
- Browser APIs (localStorage, matchMedia, IntersectionObserver)

### Data fetching strategies

```typescript
// Server Component — direct database fetch
async function UserPage({ params }: { params: { id: string } }) {
  const user = await prisma.user.findUnique({ where: { id: params.id } });
  return <UserProfile user={user} />;
}

// Client Component — fetch via API with cache
'use client';
function UserDashboard() {
  const { data, isLoading } = useQuery({ queryKey: ['user'], queryFn: fetchUser });
  if (isLoading) return <Skeleton />;
  return <UserProfile user={data} />;
}
```

Prefer Server Components for data that does not change by user interaction. Use client-side fetching for data that updates by user action or polling.

---

## Anti-patterns

### Frontend

- **500-line monolith**: component that does fetch, business rule, layout, and formatting. Split into hook + pure component.
- **useEffect to derive state** that could be `useMemo` or simple calculation during render.
- **Global Context to avoid props**: if it's 2–3 props, pass as props. Context is for truly global state.
- **Duplicated API client per feature**: centralize in `shared/api/`.

```typescript
// ❌ Bad — effect to derive
useEffect(() => { setFullName(`${first} ${last}`); }, [first, last]);

// ✅ Good — derived without effect
const fullName = `${first} ${last}`;
```

### Backend

- **Controller with business logic** — belongs in the service.
- **Service with req/res** — does not know HTTP.
- **Raw SQL when Prisma works** — only raw for critical performance with evidence.
- **Circular import** — use dependency injection or extract to `shared/`.

```typescript
// ❌ Bad — controller with logic
static async create(req: Request, res: Response) {
  const hash = await bcrypt.hash(req.body.password, 10); // logic in controller
  const user = await prisma.user.create({ data: { ...req.body, passwordHash: hash } });
  return res.json(user);
}

// ✅ Good — controller orchestrates, service executes
static async create(req: Request, res: Response) {
  const input = req.validatedBody as CreateUserInput;
  const user = await usersService.create(input);
  return res.status(201).json(user);
}
```

---

## Hard rules

- **Do not skip layers**: Controller → Service → Repository → Prisma. No shortcuts.
- **Do not use `any`**: specific type or `unknown` with type guard.
- **Do not create an endpoint without Zod schema** for request and response.
- **Do not change database schema without migration** and documented rollback path.
- **Do not commit without `tsc --noEmit`** passing.
- **Do not hardcode config**: use env vars validated via Zod.
- **Do not commit real `.env`**, secrets, tokens, or credentials.
- **Do not create abstraction before at least one real use exists**.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

### Layers and separation
- **Do not skip layers**: Controller → Service → Repository → Prisma, no shortcuts.
- **Service does not know HTTP**: service never imports Express or receives req/res.
- **Repository does not validate input**: validation is the responsibility of the schema/controller.
- **Controller does not make direct queries**: data access goes through the repository or service.

### Typing and validation
- **Do not use `any`**: use a specific type or `unknown` with type guard.
- **Do not create an endpoint without Zod schema**: every endpoint needs request and response schemas.

### Database
- **Do not change schema without migration**: every database change needs a migration with a documented rollback path.

### Configuration and security
- **Do not hardcode config**: use env vars validated via Zod.
- **Do not commit real `.env`**, secrets, tokens, or credentials.
- **Do not commit without `tsc --noEmit`** passing.

### Abstraction
- **Do not create abstraction before real use**: at least one real use must exist before extracting.

### Frontend
- **Technical message never leaks to the end user**: API errors become friendly renderable state.
- **Centralized route map**: never loose repeated strings for routes.
- **Centralized API client in `shared/api/`**: do not duplicate HTTP client per feature.
