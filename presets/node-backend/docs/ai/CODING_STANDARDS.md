# Coding Standards

Code standards for Node.js backend with TypeScript.

## Tools

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

## Typing

```typescript
// ✓ Explicit types
async function getUser(id: number): Promise<User | null> { ... }

// ✗ Never any
function process(data: any): any { ... }  // ❌

// ✓ Use unknown when you don't know the type
function process(data: unknown): Result {
  const parsed = schema.parse(data);
  ...
}
```

## Naming

| Element | Convention | Example |
|---|---|---|
| File | kebab-case | user-service.ts |
| Class | PascalCase | UsersService |
| Function | camelCase | createUser() |
| Constant | UPPER_SNAKE | MAX_RETRIES |
| Interface | PascalCase | UserProfile |
| Type alias | PascalCase | OrderStatus |
| Boolean | is/has/can | isActive, hasPermission |
| Route | kebab-case | /api/v1/user-profiles |
| Prisma field | camelCase | createdAt |

## Error handling

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
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message: 'Internal error' } });
});
```

## Logging

```typescript
import pino from 'pino';
const logger = pino();

logger.info({ userId: user.id }, 'user_created');
logger.error({ orderId: order.id, error: err.message }, 'payment_failed');
```

Never log passwords, tokens, PII.

## Async

Always async/await, never callbacks:

```typescript
// ✓
const user = await prisma.user.findUnique({ where: { id } });

// ✗ Never callback hell
prisma.user.findUnique({ where: { id } }).then(user => { ... }).catch(err => { ... });
```

## Prohibitions

- `any` without a comment justifying it
- `console.log` in production
- `require()` — use import
- `eval()`, `Function()`
- `// @ts-ignore` without justification
- Callbacks — use async/await
- `ts-ignore` / `ts-expect-error` without justification

## Hard rules

- Do not commit without `tsc --noEmit` passing.
- Do not use `any` without documenting.
- Do not log sensitive data.
- Do not use `console.log` in production.
- Do not hardcode configuration.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any of the rules below.

- **Do not use `any` without documenting**: Use `unknown` or specific type; if `any`, justify in a comment.
- **Do not commit without `tsc --noEmit` passing**: Type checking must be clean before commit.
- **Do not log sensitive data**: Never log passwords, tokens, PII.
- **Do not use `console.log` in production**: Use structured logger (pino).
- **Do not hardcode configuration**: Use env vars via Zod.
- **Do not use `require()`**: Use import/ES modules.
- **Do not use `eval()` or `Function()`**: Prohibited in any context.
- **Do not use `// @ts-ignore` without justification**: Justify if necessary.
- **Do not use callbacks**: Always async/await.
- **Do not use `ts-ignore` / `ts-expect-error` without justification**: Justify if necessary.
- **Always async/await, never callbacks**: Callbacks are prohibited; use async/await.
