# Arquitetura Fullstack Web

## Visão geral

Aplicação fullstack com frontend e backend no mesmo repositório monorepo. O frontend (Next.js App Router ou Remix) e o backend (API layers) compartilham tipos, schemas e utilitários, mas mantêm boundaries claras.

**Fluxo backend:**

```
Request → Route → Controller → Schema (Zod) → Service → Repository → Banco → Response
```

**Fluxo frontend:**

```
Banco → Server Component / API Route → Client Component → UI
```

O ponto de encontro é a camada `shared/`: tipos, constantes e schemas Zod são consumidos tanto pelo server quanto pelo client, garantindo contrato único.

---

## Estrutura de diretórios

```txt
src/
  app/ (ou pages/)              # Rotas, páginas, layouts (Next.js App Router / Remix)
  components/                   # Componentes UI compartilhados
  hooks/                        # React hooks compartilhados
  server/                       # Camadas do backend
    config/                     # Env vars validadas via Zod, DB client singleton
    routes/                     # HTTP route handlers
    controllers/                # Orquestração de requests
    schemas/                    # Zod validation schemas (request/response)
    services/                   # Lógica de negócio
    repositories/               # Acesso a dados (Prisma queries)
  shared/                       # Código compartilhado frontend ↔ backend
    utils/                      # Helpers puros
    types/                      # TypeScript types/interfaces compartilhados
    api/                        # API client (frontend → backend)
    constants/                  # Constantes do domínio
  features/<name>/              # Colocation opcional por feature
    components/
    hooks/
    api/
    server/                     # Lógica server-side da feature
prisma/
  schema.prisma                 # Schema do banco
  migrations/                   # Migrations auto-geradas
  seed.ts                       # Dados iniciais
```

---

## Camadas — Frontend

### Hierarquia de componentes

```
Page (carrega dados, monta layout)
  → Container (coordena estado e callbacks)
    → UI Component (recebe props, renderiza markup)
```

- **Page**: orquestra data fetching e layout de alto nível. Pode ser Server Component ou client-side.
- **Componentes de UI**: recebem props explícitas, não chamam API diretamente, não gerenciam estado global.
- **Hooks**: encapsulam data fetching, eventos e integração com browser.

### Data fetching

- Centralize o client HTTP e o tratamento de erro em `shared/api/`.
- Use TanStack Query para cache e server state.
- Defina sempre loading, error, empty e retry states.

```typescript
// hooks/useUsers.ts
export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => apiClient.get('/users'),
  });
}
```

### Decisão de estado

| Tipo de estado | Solução | Quando usar |
|---|---|---|
| Local de componente | `useState` / `useReducer` | Toggle, form input, seleção |
| Navegável / compartilhável | URL search params | Filtros, paginação, aba ativa |
| Dados remotos | TanStack Query | Qualquer dado do servidor |
| Global client-side | Zustand / Context | Tema, locale, auth state |

### Rotas

- Rotas públicas e protegidas declaradas explicitamente.
- Tela nova declarar path, params e comportamento de navegação.
- Usar mapa de rotas centralizado, nunca strings soltas repetidas.

### Erros no frontend

- Erro de API deve virar estado renderizável.
- Error boundaries em áreas críticas da UI.
- Mensagem técnica nunca vaza para o usuário final.

---

## Camadas — Backend

Pipeline completo de uma request:

```
Route → Controller → Schema → Service → Repository → Prisma → Banco
```

### Route → Controller

Route define apenas o binding HTTP (path, method, middleware, handler).

```typescript
// server/routes/users.routes.ts
import { Router } from 'express';
import { UsersController } from '../controllers/users.controller';
import { validate } from '../middleware/validate';
import { createUserSchema } from '../schemas/users.schema';

const router = Router();
router.post('/', validate(createUserSchema), UsersController.create);
router.get('/', authMiddleware, UsersController.list);
export { router as usersRoutes };
```

### Schema (Zod)

Validação de entrada e saída. Cada endpoint tem schema de request.

```typescript
// server/schemas/users.schema.ts
import { z } from 'zod';

export const createUserSchema = z.object({
  body: z.object({
    name: z.string().min(2).max(255),
    email: z.string().email(),
    password: z.string().min(8).max(128),
  }),
});

export type CreateUserInput = z.infer<typeof createUserSchema>['body'];
```

### Service

Lógica de negócio pura. Não conhece HTTP (sem req/res).

```typescript
// server/services/users.service.ts
export class UsersService {
  constructor(private prisma: PrismaClient) {}

  async create(data: CreateUserInput) {
    const existing = await this.prisma.user.findUnique({ where: { email: data.email } });
    if (existing) throw new AppError('CONFLICT', 'Email já cadastrado', 409);

    const passwordHash = await hashPassword(data.password);
    return this.prisma.user.create({
      data: { name: data.name, email: data.email, passwordHash },
      select: { id: true, name: true, email: true, createdAt: true },
    });
  }
}
```

### Repository

Acesso a dados. Quando Prisma direto no service basta, use direto. Quando queries são complexas ou reutilizadas, extraia para repository.

```typescript
// server/repositories/orders.repository.ts
export class OrdersRepository {
  constructor(private prisma: PrismaClient) {}

  async findByIdWithItems(orderId: number) {
    return this.prisma.order.findUnique({
      where: { id: orderId },
      include: { items: true },
    });
  }
}
```

### Configuração (env vars via Zod)

```typescript
// server/config/index.ts
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string().min(32),
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
});

export const config = envSchema.parse(process.env);
```

Cada camada tem **uma única responsabilidade**. Service nunca importa Express. Repository nunca valida input. Controller nunca faz query direta.

---

## Server Components boundary

### O que roda no server vs client

| Conceito | Server | Client |
|---|---|---|
| Acesso a banco / ORM | ✅ | ❌ |
| Env vars / secrets | ✅ | ❌ |
| Lógica de negócio | ✅ | ❌ |
| Busca de dados inicial | ✅ | Opcional (TanStack Query) |
| Interatividade (onClick, useState) | ❌ | ✅ |
| Browser APIs (localStorage, window) | ❌ | ✅ |
| Efeitos colaterais (useEffect) | ❌ | ✅ |

### Quando usar `'use client'`

Somente quando o componente precisa de:
- Event handlers (onClick, onChange)
- Hooks de estado (useState, useReducer)
- Hooks de efeito (useEffect, useLayoutEffect)
- Browser APIs (localStorage, matchMedia, IntersectionObserver)

### Estratégias de data fetching

```typescript
// Server Component — busca direta no banco
async function UserPage({ params }: { params: { id: string } }) {
  const user = await prisma.user.findUnique({ where: { id: params.id } });
  return <UserProfile user={user} />;
}

// Client Component — busca via API com cache
'use client';
function UserDashboard() {
  const { data, isLoading } = useQuery({ queryKey: ['user'], queryFn: fetchUser });
  if (isLoading) return <Skeleton />;
  return <UserProfile user={data} />;
}
```

Prefira Server Components para dados que não mudam por interação do usuário. Use client-side fetching para dados que atualizam por ação do usuário ou polling.

---

## Anti-patterns

### Frontend

- **Monolito de 500 linhas**: componente que faz fetch, regra de negócio, layout e formatação. Divida em hook + componente puro.
- **useEffect para derivar estado** que poderia ser `useMemo` ou cálculo simples durante render.
- **Context global para evitar props**: se são 2–3 props, passe como props. Context é para estado verdadeiramente global.
- **API client duplicado por feature**: centralize em `shared/api/`.

```typescript
// ❌ Ruim — efeito para derivar
useEffect(() => { setFullName(`${first} ${last}`); }, [first, last]);

// ✅ Bom — derivado sem efeito
const fullName = `${first} ${last}`;
```

### Backend

- **Controller com lógica de negócio** — pertence ao service.
- **Service com req/res** — não conhece HTTP.
- **Raw SQL quando Prisma resolve** — só raw para performance crítica com evidência.
- **Import circular** — use dependency injection ou extraia para `shared/`.

```typescript
// ❌ Ruim — controller com lógica
static async create(req: Request, res: Response) {
  const hash = await bcrypt.hash(req.body.password, 10); // lógica no controller
  const user = await prisma.user.create({ data: { ...req.body, passwordHash: hash } });
  return res.json(user);
}

// ✅ Bom — controller orquestra, service executa
static async create(req: Request, res: Response) {
  const input = req.validatedBody as CreateUserInput;
  const user = await usersService.create(input);
  return res.status(201).json(user);
}
```

---

## Regras duras

- **Não pular camadas**: Controller → Service → Repository → Prisma. Sem atalhos.
- **Não usar `any`**: tipo específico ou `unknown` com type guard.
- **Não criar endpoint sem Zod schema** de request e response.
- **Não alterar schema do banco sem migration** e caminho de rollback documentado.
- **Não commitar sem `tsc --noEmit`** passando.
- **Não hardcodar config**: usar env vars validadas via Zod.
- **Não commitar `.env` real**, secrets, tokens ou credenciais.
- **Não criar abstração antes de existir pelo menos um uso real**.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

### Camadas e separação
- **Não pular camadas**: Controller → Service → Repository → Prisma, sem atalhos.
- **Service não conhece HTTP**: service nunca importa Express ou recebe req/res.
- **Repository não valida input**: validação é responsabilidade do schema/controller.
- **Controller não faz query direta**: acesso a dados passa pelo repository ou service.

### Tipagem e validação
- **Não usar `any`**: use tipo específico ou `unknown` com type guard.
- **Não criar endpoint sem Zod schema**: todo endpoint precisa schema de request e response.

### Banco de dados
- **Não alterar schema sem migration**: toda mudança no banco precisa migration com caminho de rollback documentado.

### Configuração e segurança
- **Não hardcodar config**: usar env vars validadas via Zod.
- **Não commitar `.env` real**, secrets, tokens ou credenciais.
- **Não commitar sem `tsc --noEmit`** passando.

### Abstração
- **Não criar abstração antes de uso real**: pelo menos um uso real deve existir antes de extrair.

### Frontend
- **Mensagem técnica nunca vaza para o usuário final**: erros de API viram estado renderizável amigável.
- **Mapa de rotas centralizado**: nunca strings soltas repetidas para rotas.
- **API client centralizado em `shared/api/`**: não duplicar client HTTP por feature.
