# Padrões de Código — Fullstack TypeScript

Documento autoritativo de convenções de código para o projeto fullstack React + Node.js com TypeScript.

## 1. Princípios

O código deve ser:

- **Simples e explícito** — sem mágica, sem abstração prematura
- **Legível** — autoexplicativo, comentário apenas quando necessário
- **Testável em isolado** — cada módulo com responsabilidades claras
- **Modular e fácil de refatorar** — baixo acoplamento entre camadas

Não criar abstração antes de existir repetição real. Código ruim não se conserta com comentário — melhore o código.

---

## 2. Ferramentas

| Ferramenta | Configuração |
|---|---|
| **Formatter** | Prettier |
| **Linter** | ESLint + `@typescript-eslint` + `eslint-plugin-import` |
| **Type checker** | `tsc --noEmit` |

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

---

## 3. Nomeação

### Tabela de convenções

| Elemento | Convenção | Exemplo bom | Exemplo ruim |
|---|---|---|---|
| Arquivo geral | `kebab-case` | `user-service.ts` | `UserService.ts` |
| Componente React | `PascalCase` | `OrderCard.tsx` | `orderCard.tsx` |
| Hook React | `camelCase` com prefixo `use` | `useUserOrders.ts` | `userOrders.ts` |
| Service | `kebab-case` | `order-service.ts` | `orderService.ts` |
| Controller | `kebab-case` | `user-controller.ts` | `UserController.ts` |
| Repository | `kebab-case` | `product-repository.ts` | `ProductRepo.ts` |
| Rota (arquivo) | `kebab-case` | `user-routes.ts` | `userRoutes.ts` |
| Rota (path) | `kebab-case` | `/api/v1/user-profiles` | `/api/v1/userProfiles` |
| Type alias | `PascalCase` | `OrderStatus` | `orderStatus` |
| Interface | `PascalCase` | `UserProfile` | `IUserProfile` |
| Constante | `UPPER_SNAKE` | `MAX_RETRIES` | `maxRetries` |
| Função | `camelCase` | `createUser()` | `CreateUser()` |
| Classe | `PascalCase` | `UsersService` | `usersService` |
| Boolean | `is/has/can` | `isActive`, `hasPermission` | `active`, `permission` |
| Modelo Prisma | `PascalCase` | `User`, `OrderItem` | `user`, `order_item` |
| Campo Prisma | `camelCase` | `createdAt` | `Created_At` |
| Migration | `kebab-case` com timestamp | `20240115-add-user-role.ts` | `migration1.ts` |
| Arquivo de teste | `kebab-case` + `.spec`/`.test` | `user-service.spec.ts` | `test-user.ts` |

### Exemplos por contexto

```ts
// ✅ Frontend — nomes claros e específicos
useUserOrders       // hook que busca pedidos do usuário
OrderCard           // componente visual de pedido
formatCurrency      // utilidade de formatação
userApi             // camada de API de usuário
OrderStatus         // union de status

// ❌ Frontend — genérico demais
useData             // não descreve o que faz
Component1          // sem significado
utils               // caixa de ferramentas sem critério

// ✅ Backend — explícito e padronizado
async function getUser(id: number): Promise<User | null> { ... }
const MAX_RETRIES = 3;

// ❌ Backend — vago ou inconsistente
function process(data: any): any { ... }
const max = 3;
```

---

## 4. TypeScript — Regras Compartilhadas

### Tipagem obrigatória

- Tipar props, responses, parâmetros de função pública e eventos relevantes.
- **Nunca `any`** — use `unknown` e valide com Zod na borda.
- Se `any` for inevitável, isole na borda e documente o motivo.
- Tipos explícitos para contratos públicos (props de componentes, parâmetros de hooks, assinaturas de service).
- Usar `interface` para contratos de objeto; `type` para unions, interseções e utilitários.

```typescript
// ✅ Certo: tipo explícito + unknown na borda
function process(data: unknown): Result {
  const parsed = schema.parse(data);
  return transform(parsed);
}

// ❌ Errado: any solto
function process(data: any): any { ... }
```

### Validação com Zod

**Todo dado externo deve ser validado com Zod** — tanto respostas de API (frontend) quanto inputs HTTP (backend):

```ts
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;
```

- **Frontend**: valide respostas de API na camada de fetch.
- **Backend**: valide body, query params e path params em schemas de rota.

---

## 5. React (Frontend)

### Componentes

- Componentes pequenos e nomeados pela responsabilidade.
- Props com nomes semânticos, não acopladas ao layout interno.
- Um arquivo, um componente exportado (exceto subcomponentes coesos).
- Não misturar regra de negócio com renderização.

```tsx
// ✅ Certo: interface explícita
interface UserCardProps {
  user: User;
  onEdit: (id: string) => void;
  isLoading?: boolean;
}

export function UserCard({ user, onEdit, isLoading = false }: UserCardProps) {
  // ...
}
```

### Hooks

- Hook customizado deve encapsular comportamento reutilizável real.
- Hook que faz fetch deve usar TanStack Query, nunca `useEffect` + `useState`.
- Não esconda side effects perigosos em hook com nome genérico.

### useMemo / useCallback

- Memoização apenas quando há custo mensurável ou renderização problemática.
- Não envolva tudo em `useMemo` por precaução.

```tsx
// ✅ Justificado: filtro pesado em lista grande
const filteredItems = useMemo(
  () => items.filter(complexFilter),
  [items, complexFilter]
);

// ❌ Desnecessário: objeto simples
const style = useMemo(() => ({ color: 'red' }), []);
```

### useEffect

- Evite `useEffect` para derivar estado calculável diretamente.
- `useEffect` é para sincronização com sistemas externos (API, DOM, timer).
- Não use `useEffect` para reagir a mudanças de state do próprio componente.

```tsx
// ✅ Certo: cálculo direto
const fullName = `${firstName} ${lastName}`;

// ❌ Errado: effect desnecessário
useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);
```

### Estado

| Tipo de estado | Solução |
|---|---|
| Local de componente | `useState` / `useReducer` |
| Estado de formulário | React Hook Form |
| Dados remotos/cache | TanStack Query |
| Filtros e paginação | URL params (`searchParams`) |
| Estado global raro | Zustand |

- `queryKey` deve ser único e incluir parâmetros relevantes.
- `staleTime` explícito quando dado muda pouco.
- `useMutation` com `invalidateQueries` para manter cache atualizado.
- Tratar `isLoading`, `isError` e estado vazio em toda query.
- Não duplicar lógica de fetch em componentes — use hooks centralizados.
- Não crie store global para estado que vive em uma página.

### Formulários

- Use React Hook Form + Zod para formulários com validação.
- Erros por campo e erro geral devem ser representáveis.
- Submit deve tratar loading e evitar duplo envio.

### Estilo

- Use tokens/classes/componentes do design system (Tailwind).
- Prefira composição com `@apply` ou `cva` para variantes.
- Evite inline style para regra visual reutilizável.
- Não misture design system com workaround local sem comentário.

---

## 6. Node.js (Backend)

### Tratamento de erros

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
```

- Middleware centralizado converte `AppError` em resposta JSON padronizada.
- Erros inesperados são logados e retornam 500 genérico (nunca vazar stack trace).
- DTO/schema de API não é entidade de domínio.

### Logging

```typescript
import pino from 'pino';
const logger = pino();

logger.info({ userId: user.id }, 'user_created');
logger.error({ orderId: order.id, error: err.message }, 'payment_failed');
```

- Logs estruturados (JSON) via pino.
- **Nunca logar** senhas, tokens, Authorization header, cookies, PII ou dados sensíveis.

### Async

- Sempre `async/await`. Nunca callbacks ou `.then().catch()` encadeados.

```typescript
// ✅
const user = await prisma.user.findUnique({ where: { id } });

// ❌ Nunca callback hell
prisma.user.findUnique({ where: { id } }).then(user => { ... }).catch(err => { ... });
```

---

## 7. Arquivos e Dependências

### Tamanho de arquivo

- Um arquivo não deve ultrapassar **200–300 linhas** sem justificativa.
- Arquivo grande é sinal de responsabilidade mista — separe.

### Checklist antes de adicionar dependência

1. Verifique se já existe alternativa no projeto.
2. Avalie se é realmente necessária vs. stdlib / browser API / código simples.
3. Verifique tamanho do bundle (`bundlephobia.com` para frontend).
4. Verifique se é mantida ativamente.
5. Não adicionar lib para uma função resolvida com stdlib/browser API.

---

## 8. Anti-patterns

### Frontend

1. **`useEffect` para sincronizar state do React** — se o dado deriva de props/state, calcule diretamente.
2. **Store global para estado local** — não use Zustand/Redux para dados que vivem em um componente.
3. **Chamada HTTP em componente** — use hook + TanStack Query.
4. **`any` em contrato público** — use Zod ou tipo explícito.
5. **Componente de 500+ linhas** — separe em componentes menores.
6. **Prop drilling profundo** — se passou por 4+ níveis, considere context ou store.
7. **Duplicação de lógica entre componentes** — extraia para hook ou utilitário.
8. **Import barrel sem tree-shaking** — evite `index.ts` que re-exporta tudo em library code.
9. **Re-renderização sem memoização em lista grande** — use `key` estável e `React.memo` quando medido.

### Backend

1. **`console.log` em produção** — use logger estruturado (pino).
2. **Retornar stack trace ao cliente** — capture internamente, retorne erro genérico.
3. **Lógica de negócio em controller** — extraia para service.
4. **Query SQL/ORM inline em rota** — use repository ou camada de dados dedicada.
5. **Callback ou `.then()` para fluxo assíncrono** — sempre `async/await`.
6. **Hardcodar configuração** — use env vars e validação em startup.

---

## 9. Hard Rules

- **Nunca** usar `eval()` ou `new Function()`.
- **Nunca** usar `// @ts-ignore` ou `// @ts-expect-error` sem justificativa documentada.
- **Nunca** usar `require()` — sempre `import`.
- **Nunca** usar `any` sem documentar o motivo.
- **Nunca** usar `console.log` em produção — use logger.
- **Nunca** logar senhas, tokens, PII ou dados sensíveis.
- **Nunca** hardcodar configuração — use variáveis de ambiente.
- **Nunca** commitar `.env` real, secrets, tokens ou credenciais.
- **Nunca** usar inline styles quando existirem tokens/componentes do design system.
- **Não** commitar sem `tsc --noEmit` passando.
- **Não** criar abstração antes de existir pelo menos um uso real.
- **Não** misturar regra de negócio pesada dentro de componente visual.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

### TypeScript
- **Nunca usar `eval()` ou `new Function()`**: proibido em qualquer circunstância.
- **Nunca usar `// @ts-ignore` ou `// @ts-expect-error` sem justificativa documentada**: se precisar, documente o motivo.
- **Nunca usar `require()`**: sempre `import`.
- **Nunca usar `any` sem documentar o motivo**: prefira `unknown` + Zod na borda.
- **Não commitar sem `tsc --noEmit`** passando.

### Logging e segurança
- **Nunca usar `console.log` em produção**: use logger estruturado (pino).
- **Nunca logar senhas, tokens, PII ou dados sensíveis**: incluir Authorization header, cookies.
- **Nunca commitar `.env` real, secrets, tokens ou credenciais**.

### Configuração
- **Nunca hardcodar configuração**: use variáveis de ambiente.
- **Não criar abstração antes de existir pelo menos um uso real**.

### React/Frontend
- **Não misturar regra de negócio pesada dentro de componente visual**: extraia para hook ou service.
- **Hook que faz fetch deve usar TanStack Query**: nunca `useEffect` + `useState` para data fetching.
- **Nunca usar inline styles quando existirem tokens/componentes do design system**.

### Backend
- **Sempre `async/await`**: nunca callbacks ou `.then().catch()` encadeados.
- **Erros inesperados retornam 500 genérico**: nunca vazar stack trace ao cliente.
