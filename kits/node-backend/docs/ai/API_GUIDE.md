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

---

## Contratos de API — checklist de produção

Este guia existe para orientar implementação real em `node-backend`. Ele deve ser usado por `/plan`, `/jarvis-revisor`, `/refactor` e `/test-flow` antes de qualquer mudança relevante.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **status codes**: declarar regra, exceção permitida e evidência esperada.
- **payloads**: declarar regra, exceção permitida e evidência esperada.
- **erros**: declarar regra, exceção permitida e evidência esperada.
- **paginação**: declarar regra, exceção permitida e evidência esperada.
- **compatibilidade**: declarar regra, exceção permitida e evidência esperada.

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
