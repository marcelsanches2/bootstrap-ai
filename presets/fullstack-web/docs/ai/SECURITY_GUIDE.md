# Security Guide

Padrões de segurança para Node.js backend.

## Autenticação JWT

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
  if (!token) return res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Token ausente' } });

  try {
    const payload = jwt.verify(token, config.JWT_SECRET) as { sub: string };
    req.userId = parseInt(payload.sub);
    next();
  } catch {
    res.status(401).json({ error: { code: 'UNAUTHORIZED', message: 'Token inválido' } });
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

Sempre validar input com Zod. Nunca confiar em req.body diretamente.

## CORS

```typescript
app.use(cors({
  origin: config.CORS_ORIGINS.split(','),
  credentials: true,
}));
```

Nunca `origin: '*'` em produção.

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

## Regras duras

- Nunca logar senha, token, PII.
- Nunca armazenar senha em texto plano.
- Nunca `origin: '*'` em produção.
- Nunca commitar `.env`.
- Nunca usar `eval()`.
- Nunca expor stack trace em produção.
