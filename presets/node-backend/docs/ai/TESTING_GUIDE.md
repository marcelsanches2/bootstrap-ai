# Testing Guide

Padrões de teste para Node.js backend com TypeScript.

## Framework

Vitest (ou Jest) com TypeScript.

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

## Estrutura

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

## Convenções

- Arquivo: `<module>.test.ts`
- Describe: nome do módulo
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

## Comandos

```bash
vitest                    # Watch mode
vitest run                # Single run
vitest run --coverage     # Com coverage
vitest run --reporter=verbose
```

## Regras duras

- Não remover assertion para fazer passar.
- Não usar `any` em testes.
- Não depender de ordem de execução.
- Não chamar serviço externo real.
- Não commitar sem pelo menos testes da mudança.
