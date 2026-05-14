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

---

## Estratégia de testes — checklist de produção

Este guia existe para orientar implementação real em `node-backend`. Ele deve ser usado por `/plan`, `/jarvis-plan-revisor`, `/refactor` e `/jarvis-test-flow` antes de qualquer mudança relevante.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **pirâmide de testes**: declarar regra, exceção permitida e evidência esperada.
- **fixtures**: declarar regra, exceção permitida e evidência esperada.
- **mocks**: declarar regra, exceção permitida e evidência esperada.
- **contratos**: declarar regra, exceção permitida e evidência esperada.
- **regressão**: declarar regra, exceção permitida e evidência esperada.

### Regras específicas para backend Node.js/TypeScript

- Use o runtime esperado: Node.js, TypeScript, Express/Fastify/Nest quando presentes, Prisma/Drizzle quando presentes.
- Não introduza framework paralelo sem justificar migração e custo de manutenção.
- Padronize validação na borda do sistema; dentro do domínio, trabalhe com tipos já confiáveis.
- Trate erro com categoria operacional: entrada inválida, regra de negócio, dependência externa, bug interno ou indisponibilidade.
- Centralize configuração por ambiente e mantenha secrets fora do repositório.
- Prefira funções pequenas com contrato claro a helpers genéricos difíceis de testar.
- Evite estado global mutável; quando inevitável, documente ciclo de vida e concorrência.
- Registre decisões que afetem deploy, segurança, dados ou compatibilidade em `plans/`.

### Validação mínima

Antes de considerar uma mudança pronta, execute ou justifique por que não executou:

```bash
npm run typecheck && npm test && npm run lint quando configurado
```

Além disso:

- [ ] Teste unitário cobre regra de negócio principal.
- [ ] Teste de integração cobre fronteira externa relevante.
- [ ] Caso de erro previsível tem teste ou simulação.
- [ ] Build/typecheck passa sem warnings novos relevantes.
- [ ] Documentação alterada quando contrato ou operação mudou.

### Revisão de risco

Classifique cada mudança antes de implementar:

- **Baixo risco**: arquivo isolado, sem contrato externo, sem estado persistente.
- **Médio risco**: altera fluxo, API interna, componente compartilhado ou configuração.
- **Alto risco**: altera schema, autenticação, autorização, pagamento, deploy, cache, fila, storage ou contrato público.

Para risco alto, o plano precisa conter:

- sequência de deploy;
- rollback;
- migração/backfill quando aplicável;
- métrica ou log para confirmar sucesso;
- teste de regressão;
- responsável por validar produção.

### Anti-patterns bloqueantes

- Capturar exceção genérica e continuar sem log estruturado.
- Criar abstração antes de existir segundo uso real.
- Misturar validação de entrada, regra de negócio e acesso externo no mesmo bloco.
- Depender de ordem implícita de execução sem teste.
- Adicionar dependência que só economiza poucas linhas de código trivial.
- Fazer mudança de schema sem rollback ou sem compatibilidade temporária.
- Usar dado real em teste automatizado.
- Commitar `.env`, token, dump, fixture sensível ou configuração local.

### Como o Jarvis deve usar este guia

Ao revisar um plano, o Jarvis deve produzir achados com:

```md
- Evidência: arquivo/seção do plano
- Violação: regra deste guia
- Impacto: risco concreto
- Correção: alteração objetiva
- Validação: comando ou teste esperado
```

Comentário sem evidência deve ser descartado.
