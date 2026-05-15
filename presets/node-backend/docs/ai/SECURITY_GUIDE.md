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

---

## Segurança — checklist de produção

Este guia define os padrões de `node-backend` para esta disciplina. Ele é referência durante implementação, revisão de código e troubleshooting.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **authn**: declarar regra, exceção permitida e evidência esperada.
- **authz**: declarar regra, exceção permitida e evidência esperada.
- **secrets**: declarar regra, exceção permitida e evidência esperada.
- **validação**: declarar regra, exceção permitida e evidência esperada.
- **abuso**: declarar regra, exceção permitida e evidência esperada.

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
