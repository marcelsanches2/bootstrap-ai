# Coding Standards — Fullstack TypeScript

Authoritative document for code conventions in the fullstack React + Node.js with TypeScript project.

## 1. Principles

Code must be:

- **Simple and explicit** — no magic, no premature abstraction
- **Readable** — self-explanatory, comments only when necessary
- **Testable in isolation** — each module with clear responsibilities
- **Modular and easy to refactor** — low coupling between layers

Do not create abstraction before real repetition exists. Bad code is not fixed with comments — improve the code.

---

## 2. Tools

| Tool | Configuration |
|---|---|
| **Formatter** | Prettier |
| **Linter** | ESLint + `@typescript-eslint` + `eslint-plugin-import` |
| **Type checker** | `tsc --noEmit` |

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "esModuleInterop": true,
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

---

## 3. Naming

### Conventions table

| Element | Convention | Good example | Bad example |
|---|---|---|---|
| General file | `kebab-case` | `user-service.ts` | `UserService.ts` |
| React component | `PascalCase` | `OrderCard.tsx` | `orderCard.tsx` |
| React hook | `camelCase` with `use` prefix | `useUserOrders.ts` | `userOrders.ts` |
| Service | `kebab-case` | `order-service.ts` | `orderService.ts` |
| Controller | `kebab-case` | `user-controller.ts` | `UserController.ts` |
| Repository | `kebab-case` | `product-repository.ts` | `ProductRepo.ts` |
| Route (file) | `kebab-case` | `user-routes.ts` | `userRoutes.ts` |
| Route (path) | `kebab-case` | `/api/v1/user-profiles` | `/api/v1/userProfiles` |
| Type alias | `PascalCase` | `OrderStatus` | `orderStatus` |
| Interface | `PascalCase` | `UserProfile` | `IUserProfile` |
| Constant | `UPPER_SNAKE` | `MAX_RETRIES` | `maxRetries` |
| Function | `camelCase` | `createUser()` | `CreateUser()` |
| Class | `PascalCase` | `UsersService` | `usersService` |
| Boolean | `is/has/can` | `isActive`, `hasPermission` | `active`, `permission` |
| Prisma model | `PascalCase` | `User`, `OrderItem` | `user`, `order_item` |
| Prisma field | `camelCase` | `createdAt` | `Created_At` |
| Migration | `kebab-case` with timestamp | `20240115-add-user-role.ts` | `migration1.ts` |
| Test file | `kebab-case` + `.spec`/`.test` | `user-service.spec.ts` | `test-user.ts` |

### Examples by context

```ts
// ✅ Frontend — clear and specific names
useUserOrders       // hook that fetches user orders
OrderCard           // visual order component
formatCurrency      // formatting utility
userApi             // user API layer
OrderStatus         // status union

// ❌ Frontend — too generic
useData             // doesn't describe what it does
Component1          // no meaning
utils               // toolbox without criteria

// ✅ Backend — explicit and standardized
async function getUser(id: number): Promise<User | null> { ... }
const MAX_RETRIES = 3;

// ❌ Backend — vague or inconsistent
function process(data: any): any { ... }
const max = 3;
```

---

## 4. TypeScript — Shared Rules

### Required typing

- Type props, responses, public function parameters, and relevant events.
- **Never `any`** — use `unknown` and validate with Zod at the boundary.
- If `any` is unavoidable, isolate it at the boundary and document the reason.
- Explicit types for public contracts (component props, hook parameters, service signatures).
- Use `interface` for object contracts; `type` for unions, intersections, and utilities.

```typescript
// ✅ Correct: explicit type + unknown at boundary
function process(data: unknown): Result {
  const parsed = schema.parse(data);
  return transform(parsed);
}

// ❌ Wrong: loose any
function process(data: any): any { ... }
```

### Validation with Zod

**All external data must be validated with Zod** — both API responses (frontend) and HTTP inputs (backend):

```ts
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;
```

- **Frontend**: validate API responses in the fetch layer.
- **Backend**: validate body, query params, and path params in route schemas.

---

## 5. React (Frontend)

### Components

- Small components named by responsibility.
- Props with semantic names, not coupled to internal layout.
- One file, one exported component (except cohesive subcomponents).
- Do not mix business rules with rendering.

```tsx
// ✅ Correct: explicit interface
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
  isLoading?: boolean;
}

export function UserCard({ user, onEdit, isLoading = false }: UserCardProps) {
  // ...
}
```

### Hooks

- Custom hook should encapsulate truly reusable behavior.
- Hook that fetches must use TanStack Query, never `useEffect` + `useState`.
- Do not hide dangerous side effects in a hook with a generic name.

### useMemo / useCallback

- Memoization only when there is measurable cost or problematic rendering.
- Do not wrap everything in `useMemo` as a precaution.

```tsx
// ✅ Justified: heavy filter on large list
const filteredItems = useMemo(
  () => items.filter(complexFilter),
  [items, complexFilter]
);

// ❌ Unnecessary: simple object
const style = useMemo(() => ({ color: 'red' }), []);
```

### useEffect

- Avoid `useEffect` to derive directly calculable state.
- `useEffect` is for synchronization with external systems (API, DOM, timer).
- Do not use `useEffect` to react to state changes within the same component.

```tsx
// ✅ Correct: direct calculation
const fullName = `${firstName} ${lastName}`;

// ❌ Wrong: unnecessary effect
useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);
```

### State

| State type | Solution |
|---|---|
| Component local | `useState` / `useReducer` |
| Form state | React Hook Form |
| Remote data/cache | TanStack Query |
| Filters and pagination | URL params (`searchParams`) |
| Rare global state | Zustand |

- `queryKey` must be unique and include relevant parameters.
- Explicit `staleTime` when data changes infrequently.
- `useMutation` with `invalidateQueries` to keep cache updated.
- Handle `isLoading`, `isError`, and empty state in every query.
- Do not duplicate fetch logic in components — use centralized hooks.
- Do not create a global store for state that lives on one page.

### Forms

- Use React Hook Form + Zod for forms with validation.
- Per-field errors and general error must be representable.
- Submit must handle loading and prevent double submission.

### Styling

- Use design system tokens/classes/components (Tailwind).
- Prefer composition with `@apply` or `cva` for variants.
- Avoid inline style for reusable visual rules.
- Do not mix design system with local workaround without a comment.

---

## 6. Node.js (Backend)

### Error handling

```typescript
// utils/errors.ts
export class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public status: number,
    public field?: string,
  ) { super(message); }
}
```

- Centralized middleware converts `AppError` to standardized JSON response.
- Unexpected errors are logged and return a generic 500 (never leak stack trace).
- API DTO/schema is not a domain entity.

### Logging

```typescript
import pino from 'pino';
const logger = pino();

logger.info({ userId: user.id }, 'user_created');
logger.error({ orderId: order.id, error: err.message }, 'payment_failed');
```

- Structured logs (JSON) via pino.
- **Never log** passwords, tokens, Authorization header, cookies, PII, or sensitive data.

### Async

- Always `async/await`. Never callbacks or chained `.then().catch()`.

```typescript
// ✅
const user = await prisma.user.findUnique({ where: { id } });

// ❌ Never callback hell
prisma.user.findUnique({ where: { id } }).then(user => { ... }).catch(err => { ... });
```

---

## 7. Files and Dependencies

### File size

- A file should not exceed **200–300 lines** without justification.
- Large file is a sign of mixed responsibility — split it.

### Checklist before adding a dependency

1. Check if an alternative already exists in the project.
2. Evaluate if it's truly necessary vs. stdlib / browser API / simple code.
3. Check bundle size (`bundlephobia.com` for frontend).
4. Check if it is actively maintained.
5. Do not add a library for a function solvable with stdlib/browser API.

---

## 8. Anti-patterns

### Frontend

1. **`useEffect` to sync React state** — if data derives from props/state, calculate directly.
2. **Global store for local state** — do not use Zustand/Redux for data that lives in one component.
3. **HTTP call in component** — use hook + TanStack Query.
4. **`any` in public contract** — use Zod or explicit type.
5. **500+ line component** — split into smaller components.
6. **Deep prop drilling** — if passed through 4+ levels, consider context or store.
7. **Duplicated logic between components** — extract to hook or utility.
8. **Barrel import without tree-shaking** — avoid `index.ts` that re-exports everything in library code.
9. **Re-render without memoization on large list** — use stable `key` and `React.memo` when measured.

### Backend

1. **`console.log` in production** — use structured logger (pino).
2. **Returning stack trace to client** — capture internally, return generic error.
3. **Business logic in controller** — extract to service.
4. **SQL/ORM query inline in route** — use repository or dedicated data layer.
5. **Callback or `.then()` for async flow** — always `async/await`.
6. **Hardcoded configuration** — use env vars and startup validation.

---

## 9. Hard Rules

- **Never** use `eval()` or `new Function()`.
- **Never** use `// @ts-ignore` or `// @ts-expect-error` without documented justification.
- **Never** use `require()` — always `import`.
- **Never** use `any` without documenting the reason.
- **Never** use `console.log` in production — use logger.
- **Never** log passwords, tokens, PII, or sensitive data.
- **Never** hardcode configuration — use environment variables.
- **Never** commit real `.env`, secrets, tokens, or credentials.
- **Never** use inline styles when design system tokens/components exist.
- **Do not** commit without `tsc --noEmit` passing.
- **Do not** create abstraction before at least one real use exists.
- **Do not** mix heavy business logic inside a visual component.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

### TypeScript
- **Never use `eval()` or `new Function()`**: prohibited under any circumstance.
- **Never use `// @ts-ignore` or `// @ts-expect-error` without documented justification**: if needed, document the reason.
- **Never use `require()`**: always `import`.
- **Never use `any` without documenting the reason**: prefer `unknown` + Zod at the boundary.
- **Do not commit without `tsc --noEmit`** passing.

### Logging and security
- **Never use `console.log` in production**: use structured logger (pino).
- **Never log passwords, tokens, PII, or sensitive data**: including Authorization header, cookies.
- **Never commit real `.env`, secrets, tokens, or credentials**.

### Configuration
- **Never hardcode configuration**: use environment variables.
- **Do not create abstraction before at least one real use exists**.

### React/Frontend
- **Do not mix heavy business logic inside a visual component**: extract to hook or service.
- **Hook that fetches must use TanStack Query**: never `useEffect` + `useState` for data fetching.
- **Never use inline styles when design system tokens/components exist**.

### Backend
- **Always `async/await`**: never callbacks or chained `.then().catch()`.
- **Unexpected errors return generic 500**: never leak stack trace to client.
