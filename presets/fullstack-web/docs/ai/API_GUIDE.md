# API Guide

Convenções REST para APIs Node.js/TypeScript.

## Versionamento

Prefixo na URL: `/api/v1/`, `/api/v2/`.

## Status codes

| Código | Quando usar |
|---|---|
| 200 | Sucesso (GET, PUT, PATCH) |
| 201 | Criado (POST) |
| 204 | Sem conteúdo (DELETE) |
| 400 | Validação de input falhou |
| 401 | Não autenticado |
| 403 | Sem permissão |
| 404 | Recurso não encontrado |
| 409 | Conflito (duplicado) |
| 422 | Unprocessable entity (Zod validation) |
| 429 | Rate limit |
| 500 | Erro interno |

## Error format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email já cadastrado",
    "field": "email"
  }
}
```

## Validação com Zod

```typescript
import { z } from 'zod';

const createUserSchema = z.object({
  name: z.string().min(2).max(255),
  email: z.string().email(),
  password: z.string().min(8).max(128),
});

// Middleware de validação
export function validate(schema: z.ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse({ body: req.body, query: req.query, params: req.params });
    if (!result.success) {
      return res.status(400).json({
        error: { code: 'VALIDATION_ERROR', message: result.error.errors[0].message },
      });
    }
    req.validated = result.data;
    next();
  };
}
```

## Paginação

```typescript
// Query: skip=0&limit=20
// Response:
{
  "items": [...],
  "total": 150,
  "skip": 0,
  "limit": 20
}
```

Limites: limit min 1, max 100, default 20.

## Rate limiting

```typescript
import rateLimit from 'express-rate-limit';

const authLimiter = rateLimit({ windowMs: 60_000, max: 5 }); // 5/min
app.post('/api/v1/auth/login', authLimiter, loginHandler);
```

## CORS

```typescript
import cors from 'cors';

app.use(cors({
  origin: config.CORS_ORIGINS.split(','),
  credentials: true,
}));
```

Nunca `origin: '*'` em produção.

## Regras duras

- Não usar status 200 para tudo.
- Não retornar `{ success: true }`.
- Não expor passwordHash, tokens internos.
- Não validar com if/else — usar Zod.
- Não criar endpoint sem schema de request e response.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Nunca `origin: '*'` em produção**: CORS deve ter origens explícitas.
- **Não usar status 200 para tudo**: cada cenário deve usar o status code correto (201, 400, 401, 404, etc.).
- **Não retornar `{ success: true }`**: response deve ter formato padronizado de erro ou dados.
- **Não expor passwordHash, tokens internos**: dados sensíveis nunca vazam na response.
- **Não validar com if/else**: usar Zod para validação de input.
- **Não criar endpoint sem schema de request e response**: todo endpoint precisa contrato definido.
