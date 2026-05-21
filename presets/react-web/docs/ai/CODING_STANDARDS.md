# React/TypeScript Code Standards

## Principles

Code must be:

- simple and explicit
- readable without excessive comments
- testable in isolation
- modular and easy to refactor

Do not create abstractions before real repetition exists.

---

## Naming

Use clear and specific names.

Good:

```ts
useUserOrders       // hook that fetches user orders
OrderCard           // visual order component
formatCurrency      // formatting utility
userApi             // user API layer
OrderStatus         // status enum/union
```

Bad:

```ts
useData             // too generic
Component1          // no meaning
utils               // toolbox without criteria
api                 // mixes everything
stuff               // unacceptable
```

---

## TypeScript

### Mandatory rules

- Type props, responses, and relevant events.
- Avoid `any`; if unavoidable, isolate at the boundary and validate with Zod.
- Prefer explicit types for public contracts (component props, hook parameters).
- Use `interface` for object contracts, `type` for unions and utilities.

### Component props

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

```tsx
// ❌ Wrong: untyped props or with any
export function UserCard(props: any) {
  // ...
}
```

### External data validation

Always validate API data with Zod at the boundary:

```ts
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;

// In the API layer
async function fetchUser(id: string): Promise<User> {
  const response = await api.get(`/users/${id}`);
  return UserSchema.parse(response.data);
}
```

---

## React

### Components

- Small components named by responsibility.
- Props with semantic names, not coupled to internal layout.
- One file, one exported component (except cohesive subcomponents).
- Do not mix business logic with rendering.

### Hooks

- Custom hook must encapsulate real reusable behavior.
- Hook that fetches must use TanStack Query, not `useEffect` + `useState`.
- Do not hide dangerous side effects in a generically named hook.

### useMemo / useCallback

- Memoization only when there is cost/measurement or problematic rendering.
- Do not wrap everything in `useMemo` as a precaution.

```tsx
// ✅ Justified: heavy filter on large list
const filteredItems = useMemo(
  () => items.filter(complexFilter),
  [items, complexFilter]
);

// ❌ Unnecessary: simple object creation
const style = useMemo(() => ({ color: 'red' }), []);
```

### useEffect

- Avoid `useEffect` to derive state that can be calculated directly.
- `useEffect` is for synchronization with external systems (API, DOM, timer).
- Do not use `useEffect` to react to the component's own state changes.

```tsx
// ✅ Correct: direct calculation
const fullName = `${firstName} ${lastName}`;

// ❌ Wrong: unnecessary effect
useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);
```

---

## State

### Choosing the solution

| State type | Solution |
|---|---|
| Component local | `useState` / `useReducer` |
| Form state | React Hook Form |
| Remote data/cache | TanStack Query |
| Filters and pagination | URL params (searchParams) |
| Rare global state | Zustand (or Redux if already adopted) |

### Zustand — usage pattern

```ts
// store/cart-store.ts
import { create } from 'zustand';

interface CartItem {
  id: string;
  name: string;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
  clear: () => void;
}

export const useCartStore = create<CartState>((set) => ({
  items: [],
  addItem: (item) =>
    set((state) => ({
      items: [...state.items, item],
    })),
  removeItem: (id) =>
    set((state) => ({
      items: state.items.filter((i) => i.id !== id),
    })),
  clear: () => set({ items: [] }),
}));
```

Do not create a global store for state that lives on one page.

---

## Data Fetching with TanStack Query

```tsx
// hooks/use-orders.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ordersApi } from '@/shared/api/orders';

export function useOrders(filters: OrderFilters) {
  return useQuery({
    queryKey: ['orders', filters],
    queryFn: () => ordersApi.getAll(filters),
    staleTime: 30_000,
  });
}

export function useCreateOrder() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ordersApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
    },
  });
}
```

### TanStack Query rules

- `queryKey` must be unique and include relevant parameters.
- Explicit `staleTime` when data changes infrequently.
- `useMutation` with `invalidateQueries` to keep cache updated.
- Handle `isLoading`, `isError`, and empty state on every query.
- Do not duplicate fetch logic in components. Use centralized hooks.

---

## Forms

- Use React Hook Form + Zod for forms with validation.
- Per-field errors and general error must be representable.
- Submit must handle loading and prevent double submission.

```tsx
const schema = z.object({
  name: z.string().min(2, 'Name is required'),
  email: z.string().email('Invalid email'),
});

type FormData = z.infer<typeof schema>;

function CreateUserForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } =
    useForm<FormData>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: FormData) => {
    await createUser(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('name')} aria-invalid={!!errors.name} />
      {errors.name && <span role="alert">{errors.name.message}</span>}
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create'}
      </button>
    </form>
  );
}
```

---

## Styling

- Use tokens/classes/components from the design system.
- Tailwind CSS: prefer composition with `@apply` or `cva` for variants.
- Avoid inline styles for reusable visual rules.
- Do not mix design system with local workarounds without a comment.

---

## Files

- A file should not exceed 200-300 lines without justification.
- A large file is a sign of mixed responsibilities.

---

## Dependencies

Before adding a dependency:

1. Check if an alternative already exists in the project.
2. Evaluate if it is truly necessary vs. browser API or simple code.
3. Check bundle size (`bundlephobia.com`).
4. Check if it is actively maintained.

Do not add a lib for a function solvable with stdlib/browser API.

---

## Comments

Comment only when code is not self-explanatory.

Do not use comments to explain bad code — improve the code.

---

## Anti-patterns

- **useEffect to sync React state:** if data derives from props/state, calculate directly.
- **Global store for local state:** do not use Zustand/Redux for data that lives in one component.
- **HTTP call in component:** use hook + TanStack Query.
- **`any` in public contract:** use Zod or explicit type.
- **500-line component:** break into smaller components.
- **Deep prop drilling:** if passing through 4+ levels, consider context or store.
- **Duplicated logic between components:** extract to hook or utility.
- **Barrel import without tree-shaking:** avoid `index.ts` that re-exports everything in library code.
- **Re-render without memoization on large list:** use stable `key` and `React.memo` when measured.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any below.

### TypeScript
- **Type props, responses, and events**: public contracts must have explicit types, never `any` without isolation and validation.
- **Avoid `any`**: if unavoidable, isolate at the boundary and validate with Zod.
- **Validate API data with Zod at the boundary**: always validate external data in the API layer, never trust blindly.

### React
- **Do not mix business logic with rendering**: visual components do not contain business logic.
- **Fetch hook uses TanStack Query**: never `useEffect` + `useState` for data fetching.
- **Do not hide side effects in generic hook**: hooks must have clear name and behavior.
- **Do not use useEffect to derive the component's own state**: calculate directly.
- **Do not use useEffect to react to local state changes**: useEffect is for synchronization with external systems.

### State
- **Do not create global store for local state**: Zustand/Redux only for truly global and rare state.

### Styling
- **Use design system tokens**: do not use hardcoded values when a token/component exists.
- **Do not mix design system with local workaround**: if necessary, document the reason.

### Dependencies
- **Do not add lib for function solvable with stdlib/browser API**: evaluate alternatives first.

### Code
- **Do not use comments to explain bad code**: improve the code.
- **File should not exceed 200-300 lines without justification**: large file is a sign of mixed responsibilities.
- **Do not duplicate fetch logic in components**: use centralized hooks.
- **Do not create abstractions before real repetition**: wait for concrete need.
- **`any` in public contract is prohibited**: use Zod or explicit type.
- **HTTP call in component is prohibited**: use hook + TanStack Query.
- **Global store for local state is prohibited**: use local state or TanStack Query.
