# Security Guide

Security standards for Node.js backend.

## JWT Authentication

```typescript
import jwt from 'jsonwebtoken';

function createAccessToken(userId: number): string {
  return jwt.sign({ sub: userId, type: 'access' }, config.JWT_SECRET, { expiresIn: '15m' });
}

function createRefreshToken(userId: number): string {
  return jwt.sign({ sub: userId, type: 'refresh' }, config.JWT_SECRET, { expiresIn: '7d' });
}

// Middleware
export function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Token missing' } });

  try {
    const payload = jwt.verify(token, config.JWT_SECRET) as { sub: string };
    req.userId = parseInt(payload.sub);
    next();
  } catch {
    res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Invalid token' } });
  }
}
```

## Password hashing

```typescript
import bcrypt from 'bcryptjs';
const SALT_ROUNDS = 12;

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

## Input validation (Zod)

Always validate input with Zod. Never trust req.body directly.

## CORS

```typescript
app.use(cors({
  origin: config.CORS_ORIGINS.split(','),
  credentials: true,
}));
```

Never `origin: '*'` in production.

## Security headers

```typescript
import helmet from 'helmet';
app.use(helmet());
```

## Rate limiting

```typescript
import rateLimit from 'express-rate-limit';
app.use('/api/v1/auth', rateLimit({ windowMs: 60_000, max: 5 }));
```

## Hard rules

- Never log passwords, tokens, or PII.
- Never store passwords in plain text.
- Never `origin: '*'` in production.
- Never commit `.env`.
- Never use `eval()`.
- Never expose stack traces in production.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Never log passwords, tokens, or PII**: sensitive data must never appear in logs.
- **Never store passwords in plain text**: always hash with bcrypt.
- **Never `origin: '*'` in production**: CORS must have explicit origins.
- **Never commit `.env`**: secrets must not enter the repository.
- **Never use `eval()`**: prohibited under any circumstance.
- **Never expose stack traces in production**: capture internally, return generic error.
- **Never trust `req.body` directly**: always validate input with Zod.
