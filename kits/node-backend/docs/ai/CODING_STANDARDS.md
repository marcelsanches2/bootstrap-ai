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

---

## Padrões de implementação — checklist de produção

Este guia existe para orientar implementação real em `node-backend`. Ele deve ser usado por `/plan`, `/jarvis-revisor`, `/refactor` e `/test-flow` antes de qualquer mudança relevante.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **tipagem**: declarar regra, exceção permitida e evidência esperada.
- **tratamento de erro**: declarar regra, exceção permitida e evidência esperada.
- **nomenclatura**: declarar regra, exceção permitida e evidência esperada.
- **validação de entrada**: declarar regra, exceção permitida e evidência esperada.
- **revisão de simplicidade**: declarar regra, exceção permitida e evidência esperada.

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
