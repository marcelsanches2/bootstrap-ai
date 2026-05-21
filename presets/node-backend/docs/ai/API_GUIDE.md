# API Guide

REST conventions for Node.js/TypeScript APIs.

## Versioning

URL prefix: `/api/v1/`, `/api/v2/`.

## Status codes

| Code | When to use |
|---|---|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No content (DELETE) |
| 400 | Input validation failed |
| 401 | Not authenticated |
| 403 | No permission |
| 404 | Resource not found |
| 409 | Conflict (duplicate) |
| 422 | Unprocessable entity (Zod validation) |
| 429 | Rate limit |
| 500 | Internal error |

## Error format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email already registered",
    "field": "email"
  }
}
```

## Validation with Zod

```typescript
import { z } from 'zod';

const createUserSchema = z.object({
  name: z.string().min(2).max(255),
  email: z.string().email(),
  password: z.string().min(8).max(128),
});

// Validation middleware
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

## Pagination

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

Limits: limit min 1, max 100, default 20.

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

Never `origin: '*'` in production.

## Hard rules

- Do not use status 200 for everything.
- Do not return `{ success: true }`.
- Do not expose passwordHash, internal tokens.
- Do not validate with if/else — use Zod.
- Do not create endpoints without request and response schema.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any of the rules below.

- **Do not use status 200 for everything**: Use the correct status code by semantics (201, 400, 404, etc.).
- **Do not return `{ success: true }`**: Return standardized error or data structure.
- **Do not expose passwordHash, internal tokens**: Never include sensitive fields in the response.
- **Do not validate with if/else**: Use Zod for input validation.
- **Do not create endpoints without request and response schema**: Every endpoint needs a Zod contract.
- **Never `origin: '*'` in production**: CORS must restrict allowed origins.
