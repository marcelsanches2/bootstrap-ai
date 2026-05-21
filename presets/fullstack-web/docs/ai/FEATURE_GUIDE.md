# Feature Guide — Fullstack Web

How to develop new features in the fullstack application (frontend + backend).

---

## Minimum plan

Every feature must define:

1. **User objective** — what the user wants to accomplish
2. **Affected route/screen/component** — where the feature lives in the frontend
3. **Database schema** — required Prisma/Drizzle model
4. **Migration** — database change and rollback path
5. **API contract** — endpoints, methods, request/response shapes
6. **Main flow** — end-to-end happy path
7. **Alternative flows** — edge cases and error paths
8. **UI states** — loading / empty / error / success
9. **Consumed/sent data** — types and validation (Zod)
10. **Accessibility** — navigation, labels, focus, responsiveness
11. **Tests** — which layers to test (details in `TESTING_GUIDE.md`)
12. **Performance/build impact** — bundle, queries, indexes

---

## Standard feature structure

```
features/
  orders/
    components/
      OrderCard.tsx
      OrderList.tsx
      OrderFilters.tsx
    hooks/
      use-orders.ts
      use-create-order.ts
    api/
      orders-api.ts
    pages/
      OrdersPage.tsx
    types/
      order.types.ts
    server/
      orders.repository.ts
      orders.service.ts
      orders.controller.ts
      orders.routes.ts
      orders.schema.ts       # Zod schemas
```

Not every feature needs to start with all files. Create only what is necessary for the current task.

**Alternative (colocated):** in frameworks like Next.js App Router, server logic can be colocated in `app/` with server actions/loaders. The important thing is to maintain conceptual separation: types → validation → data access → business logic → HTTP → UI.

---

## Integrated flow — fullstack vertical slice

Prefer delivering a small complete journey instead of several hollow layers.

Mandatory order:

```
types → Prisma schema → migration → Zod schema → repository → service → API route → API client → hook → components → page → register route → test all layers
```

### 1. Types

```typescript
// features/orders/types/order.types.ts
export interface Order {
  id: string;
  customer: string;
  total: number;
  status: 'pending' | 'completed' | 'cancelled';
  createdAt: string;
}
```

### 2. Prisma schema

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
```

### 3. Migration

```bash
npx prisma migrate dev --name add_orders_table
```

### 4. Zod schema (API validation)

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

### 5. Repository

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

### 6. Service

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

### 7. API route

```typescript
router.post('/', authMiddleware, validate(createOrderSchema), OrdersController.create);
```

### 8. API client (frontend)

```typescript
// features/orders/api/orders-api.ts
import { api } from '@/shared/api/client';
import type { Order } from '../types/order.types';

export const ordersApi = {
  getAll: async (filters?: Record<string, string>): Promise<Order[]> => {
    const { data } = await api.get('/orders', { params: filters });
    return data;
  },
};
```

### 9. Hook

```typescript
// features/orders/hooks/use-orders.ts
import { useQuery } from '@tanstack/react-query';
import { ordersApi } from '../api/orders-api';

export function useOrders(filters?: Record<string, string>) {
  return useQuery({
    queryKey: ['orders', filters],
    queryFn: () => ordersApi.getAll(filters),
    staleTime: 30_000,
  });
}
```

### 10–12. Components → Page → Register route

```tsx
// features/orders/pages/OrdersPage.tsx
import { useOrders } from '../hooks/use-orders';
import { OrderList } from '../components/OrderList';

export function OrdersPage() {
  const { data: orders, isLoading, isError, refetch } = useOrders();

  if (isLoading) return <OrderListSkeleton />;
  if (isError) return <ErrorState onRetry={refetch} />;
  if (!orders?.length) return <EmptyState message="No orders found" />;

  return <OrderList orders={orders} />;
}
```

### 13. Test all layers

> Details on how to test each layer in `TESTING_GUIDE.md`.

---

## Correct dependency flow

```
Page
  → Hook (TanStack Query)
    → API client (shared/api)
      → HTTP client (axios/fetch) → API Route → Service → Repository → DB

Page
  → Component
    → receives props (data + callbacks)

Page
  → Store (Zustand) only if global state
```

---

## When to create a feature

Create a feature when it represents a clear functional area of the product:

- `auth` — login, registration, password recovery
- `dashboard` — main panel with summaries
- `orders` — listing, creation, order details
- `profile` — user data editing
- `settings` — preferences and configuration
- `notifications` — notification list and details

---

## When not to create a feature

Do not create a new feature for:

- Shared component → `shared/components/`
- Generic hook → `shared/hooks/`
- Utility → `shared/utils/`
- API configuration → `shared/api/`
- Global constants → `shared/config/`
- Shared types → `shared/types/`

---

## Acceptance criteria

Criteria must be verifiable by test or objective inspection:

**Frontend:**
- Button disables during submit
- Error X appears on field Y
- User without permission sees state Z
- Empty list shows empty state
- Loading is displayed during async operation
- Keyboard navigation reaches main actions
- Form does not send invalid data

**Backend:**
- Endpoint returns correct status for each scenario
- Validation rejects invalid data field by field
- Domain error returns predictable message and code
- Sensitive data does not leak in response (passwordHash, PII)

---

## Checklist before finalizing feature

- Feature respects the folder structure?
- Types are explicit and validated (Zod)?
- Migration created and tested (with rollback)?
- Repository/Service does not import framework/ORM directly?
- Endpoint has Zod validation on input?
- Hook uses TanStack Query (not useEffect + useState)?
- Component does not call API directly?
- Loading/error/empty states are handled?
- Accessibility: labels, focus, keyboard navigation?
- Responsiveness verified?
- `npm run build` passes?
- `npm run lint` passes?
- Tests for altered layers pass?

---

## Scope rule

- If the task asks for "structure", do not implement a feature.
- If the task asks for "feature", implement only that feature.
- If the task asks for "design", do not touch business rules.
- If the task asks for "refactoring", do not add new behavior.

---

## Product

When behavior is ambiguous, stop and expose the pending decision. Do not invent business rules in the frontend.

The frontend must:
- reflect backend state
- validate for UX (not for security)
- display errors clearly
- not create rules that the backend does not confirm

---

## Anti-patterns

**Frontend:**
- Feature without UI states (loading, error, empty).
- Custom hook with useEffect for fetch — use TanStack Query.
- Component that does everything — separate page, list, card, filters.
- Duplicated types between features — extract to `shared/types/`.
- Feature that imports from another feature directly — use `shared/` as bridge.
- Test that tests implementation (internal methods) — test behavior.
- Feature commit without passing build.
- Unnecessary global state — if data is page-scoped, use local state or TanStack Query.

**Backend:**
- Endpoint without Zod validation.
- Service that depends on HTTP request/response directly.
- N+1 query without eager loading or batch.
- Logging of sensitive data (token, password, PII).
- Abstraction created before real use exists.
- Migration without documented rollback path.

---

## Hard rules

- Always follow the order: types → schema → migration → Zod → repository → service → route → API client → hook → components → page → tests.
- Never skip a layer.
- Never create an endpoint without Zod validation schema.
- Never create a table without migration.
- Never create a feature without tests.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

### Order and layers
- **Follow the mandatory order**: types → schema → migration → Zod → repository → service → route → API client → hook → components → page → tests.
- **Never skip a layer**: each step depends on the previous one.

### Validation and database
- **Never create an endpoint without Zod validation schema**: every input must be validated.
- **Never create a table without migration**: migration with documented rollback path is mandatory.

### Tests
- **Never create a feature without tests**: every feature needs tests for altered layers.

### Frontend
- **Do not invent business rules in the frontend**: ambiguous behavior must be exposed as a pending decision.
- **Feature without UI states (loading, error, empty) is an anti-pattern**: every async feature must handle these states.

### Backend
- **Service must not depend on HTTP request/response directly**: service is pure business logic.
- **Endpoint without Zod validation is prohibited**: includes body, query, and params.
- **Migration without documented rollback path is prohibited**.
