# Guia de Testes — Fullstack Web

Padrões de teste para aplicação fullstack (frontend + backend) com TypeScript.

## Framework

**Vitest** — framework único para frontend e backend.

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node', // override para 'jsdom' em testes de componente
    setupFiles: ['./tests/setup.ts'],
    coverage: { provider: 'v8', reporter: ['text', 'html'] },
  },
});
```

---

## Pirâmide de testes

5 camadas, da mais rápida/barata à mais lenta/cara:

| Camada | O quê | Quando |
|---|---|---|
| **Unit** | Funções puras, formatadores, utils, hooks simples | Sempre — base da pirâmide |
| **Component** | Render, interação e acessibilidade de componentes UI | Toda feature com UI |
| **Integration** | Tela com dados mockados; rota de API com DB de teste | Toda feature integrada |
| **API** | Contrato HTTP completo (status, body, headers, erros) | Todo endpoint |
| **E2E** | Jornada crítica realista de ponta a ponta | Fluxos críticos de negócio |

---

## Estrutura

```
tests/
├── setup.ts                  # DB setup, mocks globais
├── unit/
│   ├── format-date.test.ts
│   └── calc-total.test.ts
├── component/
│   ├── OrderCard.test.tsx
│   └── OrderList.test.tsx
├── integration/
│   ├── OrdersPage.test.tsx       # tela com API mockada (MSW)
│   └── users.routes.test.ts      # rota de API com DB real de teste
└── e2e/
    └── order-flow.test.ts        # Playwright/Cypress
```

---

## Convenções

- **Arquivo:** `<module>.test.ts` (ou `.test.tsx` para componentes)
- **Describe:** nome do módulo
- **Test:** `should <behavior> when <condition>`

```typescript
describe('UsersService', () => {
  it('should create user when email is unique', async () => { /* ... */ });
  it('should throw CONFLICT when email already exists', async () => { /* ... */ });
  it('should hash password before saving', async () => { /* ... */ });
});
```

---

## O que testar — Frontend

Para toda feature de UI, cubra os 8 estados:

1. **Render inicial** — componente monta sem erro
2. **Loading** — estado de carregamento visível
3. **Empty** — lista vazia mostra estado vazio
4. **Error** — erro de API exibe mensagem + ação
5. **Success** — dados renderizados corretamente
6. **Interação principal** — click, submit, filtro funcionam
7. **Cenário negativo** — dados inválidos, permissão negada
8. **Acessibilidade** — labels, foco, navegação por teclado

---

## O que testar — Backend

Para toda feature de API, cubra:

- **Service behavior** — lógica de domínio funciona (happy path e edge cases)
- **API contracts** — status code correto, body shape, headers
- **Edge cases** — registro não encontrado, dados duplicados, limite de paginação
- **Input validation** — Zod schema rejeita dados inválidos em cada campo

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

Test DB isolado (Prisma) com cleanup automático:

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

Use factories para criar entidades de teste:

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

### Frontend — MSW para API

- MSW (Mock Service Worker) para interceptar chamadas de API.
- Mock determinístico, sem depender de rede real.
- Não mockar componente que é o alvo do teste.

### Backend — vi.mock para serviços externos

```typescript
import { vi } from 'vitest';

vi.mock('../src/services/email.service', () => ({
  EmailService: { sendWelcome: vi.fn().mockResolvedValue(undefined) },
}));
```

---

## Comandos

```bash
# Qualidade
npm run lint
npm run typecheck

# Testes
vitest                              # Watch mode
vitest run                          # Single run
vitest run tests/unit/              # Só unitários
vitest run tests/integration/       # Só integração
vitest run --coverage               # Com coverage

# E2E
npx playwright test                 # Quando houver E2E configurado

# Build (não substitui testes, mas é obrigatório antes de deploy)
npm run build
```

---

## Hard rules

- **Não** remover assertion para fazer teste passar.
- **Não** usar `any` em testes.
- **Não** depender de ordem de execução dos testes.
- **Não** chamar serviço externo real (API, email, pagamento).
- **Não** commitar mudança sem pelo menos testes da alteração.
- **Sempre** rode build production para mudanças relevantes de rotas/deps.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

### Integridade dos testes
- **Não remover assertion para fazer teste passar**: se o teste falha, corrija o código.
- **Não usar `any` em testes**: use tipos específicos ou fixtures tipadas.
- **Não depender de ordem de execução dos testes**: cada teste deve ser isolado e independente.

### Isolamento
- **Não chamar serviço externo real (API, email, pagamento)**: use mocks (MSW, vi.mock).
- **Testes não podem depender de produção, relógio real sem controle ou rede externa sem mock**.

### Commit
- **Não commitar mudança sem pelo menos testes da alteração**: toda mudança precisa cobertura de teste.
- **Sempre rode build production para mudanças relevantes de rotas/deps**.
