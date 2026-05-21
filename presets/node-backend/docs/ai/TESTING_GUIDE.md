# Testing Guide

Testing standards for Node.js backend with TypeScript.

## Framework

Vitest (or Jest) with TypeScript.

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./tests/setup.ts'],
    coverage: { provider: 'v8', reporter: ['text', 'html'] },
  },
});
```

## Structure

```
tests/
├── setup.ts               # DB setup, mocks
├── unit/
│   └── users.service.test.ts
├── integration/
│   └── users.routes.test.ts
└── e2e/
    └── order-flow.test.ts
```

## Conventions

- File: `<module>.test.ts`
- Describe: module name
- Test: `should <behavior> when <condition>`

```typescript
describe('UsersService', () => {
  it('should create user when email is unique', async () => { ... });
  it('should throw CONFLICT when email already exists', async () => { ... });
  it('should hash password before saving', async () => { ... });
});
```

## Fixtures

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

## Integration test

```typescript
import request from 'supertest';
import { app } from '../src/index';

it('POST /api/v1/users should return 201', async () => {
  const response = await request(app)
    .post('/api/v1/users')
    .send({ name: 'Test', email: 'test@test.com', password: 'secret123' });

  expect(response.status).toBe(201);
  expect(response.body).toHaveProperty('id');
  expect(response.body).not.toHaveProperty('passwordHash');
});
```

## Mocks

```typescript
import { vi } from 'vitest';

// Mock external service
vi.mock('../src/services/email.service', () => ({
  EmailService: { sendWelcome: vi.fn().mockResolvedValue(undefined) },
}));
```

## Commands

```bash
vitest                    # Watch mode
vitest run                # Single run
vitest run --coverage     # With coverage
vitest run --reporter=verbose
```

## Hard rules

- Do not remove assertions to make tests pass.
- Do not use `any` in tests.
- Do not depend on execution order.
- Do not call real external services.
- Do not commit without at least tests for the change.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any of the rules below.

- **Do not remove assertions to make tests pass**: Tests must validate real behavior.
- **Do not use `any` in tests**: Use specific types or `unknown`.
- **Do not depend on execution order**: Each test must be independent and isolated.
- **Do not call real external services**: Use mocks for external dependencies.
- **Do not commit without tests for the change**: At least unit tests for the changed code.
