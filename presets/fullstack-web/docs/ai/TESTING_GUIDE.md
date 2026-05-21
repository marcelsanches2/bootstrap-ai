# Testing Guide — Fullstack Web

Testing standards for fullstack applications (frontend + backend) with TypeScript.

## Framework

**Vitest** — single framework for frontend and backend.

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node', // override to 'jsdom' for component tests
    setupFiles: ['./tests/setup.ts'],
    coverage: { provider: 'v8', reporter: ['text', 'html'] },
  },
});
```

---

## Testing pyramid

5 layers, from fastest/cheapest to slowest/most expensive:

| Layer | What | When |
|---|---|---|
| **Unit** | Pure functions, formatters, utils, simple hooks | Always — base of the pyramid |
| **Component** | Render, interaction, and accessibility of UI components | Every feature with UI |
| **Integration** | Screen with mocked data; API route with test DB | Every integrated feature |
| **API** | Complete HTTP contract (status, body, headers, errors) | Every endpoint |
| **E2E** | Realistic end-to-end critical journey | Critical business flows |

---

## Structure

```
tests/
├── setup.ts                  # DB setup, global mocks
├── unit/
│   ├── format-date.test.ts
│   └── calc-total.test.ts
├── component/
│   ├── OrderCard.test.tsx
│   └── OrderList.test.tsx
├── integration/
│   ├── OrdersPage.test.tsx       # screen with mocked API (MSW)
│   └── users.routes.test.ts      # API route with real test DB
└── e2e/
    └── order-flow.test.ts        # Playwright/Cypress
```

---

## Conventions

- **File:** `<module>.test.ts` (or `.test.tsx` for components)
- **Describe:** module name
- **Test:** `should <behavior> when <condition>`

```typescript
describe('UsersService', () => {
  it('should create user when email is unique', async () => { /* ... */ });
  it('should throw CONFLICT when email already exists', async () => { /* ... */ });
  it('should hash password before saving', async () => { /* ... */ });
});
```

---

## What to test — Frontend

For every UI feature, cover the 8 states:

1. **Initial render** — component mounts without error
2. **Loading** — loading state is visible
3. **Empty** — empty list shows empty state
4. **Error** — API error displays message + action
5. **Success** — data rendered correctly
6. **Main interaction** — click, submit, filter work
7. **Negative scenario** — invalid data, permission denied
8. **Accessibility** — labels, focus, keyboard navigation

---

## What to test — Backend

For every API feature, cover:

- **Service behavior** — domain logic works (happy path and edge cases)
- **API contracts** — correct status code, body shape, headers
- **Edge cases** — record not found, duplicate data, pagination limit
- **Input validation** — Zod schema rejects invalid data for each field

```typescript
it('POST /api/v1/users should return 201', async () => {
  const response = await request(app)
    .post('/api/v1/users')
    .send({ name: 'Test', email: 'test@test.com', password: 'secret123' });

  expect(response.status).toBe(201);
  expect(response.body).toHaveProperty('id');
  expect(response.body).not.toHaveProperty('passwordHash');
});
```

---

## Fixtures

Isolated test DB (Prisma) with automatic cleanup:

```typescript
// tests/setup.ts
import { PrismaClient } from '@prisma/client';

export const testPrisma = new PrismaClient({
  datasources: { db: { url: process.env.TEST_DATABASE_URL } },
});

beforeEach(async () => {
  await testPrisma.user.deleteMany();
});

afterAll(async () => {
  await testPrisma.$disconnect();
});
```

Use factories to create test entities:

```typescript
function createUser(overrides?: Partial<UserCreateInput>) {
  return {
    name: 'Test User',
    email: `test-${Date.now()}@test.com`,
    password: 'secret123',
    ...overrides,
  };
}
```

---

## Mocks

### Frontend — MSW for API

- MSW (Mock Service Worker) to intercept API calls.
- Deterministic mocks, no dependency on real network.
- Do not mock the component that is the target of the test.

### Backend — vi.mock for external services

```typescript
import { vi } from 'vitest';

vi.mock('../src/services/email.service', () => ({
  EmailService: { sendWelcome: vi.fn().mockResolvedValue(undefined) },
}));
```

---

## Commands

```bash
# Quality
npm run lint
npm run typecheck

# Tests
vitest                              # Watch mode
vitest run                          # Single run
vitest run tests/unit/              # Unit only
vitest run tests/integration/       # Integration only
vitest run --coverage               # With coverage

# E2E
npx playwright test                 # When E2E is configured

# Build (does not replace tests, but is mandatory before deploy)
npm run build
```

---

## Hard rules

- **Do not** remove assertions to make a test pass.
- **Do not** use `any` in tests.
- **Do not** depend on test execution order.
- **Do not** call real external services (API, email, payment).
- **Do not** commit changes without at least tests for the changes.
- **Always** run production build for relevant route/dependency changes.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

### Test integrity
- **Do not remove assertions to make a test pass**: if the test fails, fix the code.
- **Do not use `any` in tests**: use specific types or typed fixtures.
- **Do not depend on test execution order**: each test must be isolated and independent.

### Isolation
- **Do not call real external services (API, email, payment)**: use mocks (MSW, vi.mock).
- **Tests must not depend on production, real clocks without control, or external networks without mocks**.

### Commit
- **Do not commit changes without at least tests for the changes**: every change needs test coverage.
- **Always run production build for relevant route/dependency changes**.
