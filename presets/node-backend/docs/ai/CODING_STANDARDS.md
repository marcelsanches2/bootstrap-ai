# Coding Standards

Padrões de código para Node.js backend com TypeScript.

## Ferramentas

- **Formatter**: Prettier
- **Linter**: ESLint + @typescript-eslint
- **Type checker**: `tsc --noEmit`
- **Imports**: eslint-plugin-import

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

## Tipagem

```typescript
// ✓ Tipos explícitos
async function getUser(id: number): Promise<User | null> { ... }

// ✗ Nunca any
function process(data: any): any { ... }  // ❌

// ✓ Use unknown quando não sabe o tipo
function process(data: unknown): Result {
  const parsed = schema.parse(data);
  ...
}
```

## Nomenclatura

| Elemento | Convenção | Exemplo |
|---|---|---|
| Arquivo | kebab-case | user-service.ts |
| Classe | PascalCase | UsersService |
| Função | camelCase | createUser() |
| Constante | UPPER_SNAKE | MAX_RETRIES |
| Interface | PascalCase | UserProfile |
| Type alias | PascalCase | OrderStatus |
| Boolean | is/has/can | isActive, hasPermission |
| Rota | kebab-case | /api/v1/user-profiles |
| Campo Prisma | camelCase | createdAt |

## Tratamento de erros

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

// Middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError) {
    return res.status(err.status).json({ error: { code: err.code, message: err.message, field: err.field } });
  }
  logger.error('Unexpected error', { error: err.message, stack: err.stack });
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'Erro interno' } });
});
```

## Logging

```typescript
import pino from 'pino';
const logger = pino();

logger.info({ userId: user.id }, 'user_created');
logger.error({ orderId: order.id, error: err.message }, 'payment_failed');
```

Nunca logar senhas, tokens, PII.

## Async

Sempre async/await, nunca callbacks:

```typescript
// ✓
const user = await prisma.user.findUnique({ where: { id } });

// ✗ Nunca callback hell
prisma.user.findUnique({ where: { id } }).then(user => { ... }).catch(err => { ... });
```

## Proibições

- `any` sem comentário justificando
- `console.log` em produção
- `require()` — usar import
- `eval()`, `Function()`
- `// @ts-ignore` sem justificativa
- Callbacks — usar async/await
- `ts-ignore` / `ts-expect-error` sem justificativa

## Regras duras

- Não commitar sem `tsc --noEmit` passando.
- Não usar `any` sem documentar.
- Não logar dados sensíveis.
- Não usar `console.log` em produção.
- Não hardcodar configuração.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Não usar `any` sem documentar**: Usar `unknown` ou tipo específico; se `any`, justificar em comentário.
- **Não commitar sem `tsc --noEmit` passando**: Type checking deve estar limpo antes de commit.
- **Não logar dados sensíveis**: Nunca logar senhas, tokens, PII.
- **Não usar `console.log` em produção**: Usar logger estruturado (pino).
- **Não hardcodar configuração**: Usar env vars via Zod.
- **Não usar `require()`**: Usar import/ES modules.
- **Não usar `eval()` nem `Function()`**: Proibido em qualquer contexto.
- **Não usar `// @ts-ignore` sem justificativa**: Justificar se necessário.
- **Não usar callbacks**: Sempre async/await.
- **Não usar `ts-ignore` / `ts-expect-error` sem justificativa**: Justificar se necessário.
- **Sempre async/await, nunca callbacks**: Callbacks são proibidos; usar async/await.
