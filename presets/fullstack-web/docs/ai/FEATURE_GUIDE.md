# Guia de Feature — Fullstack Web

Como desenvolver features novas na aplicação fullstack (frontend + backend).

---

## Plano mínimo

Toda feature deve definir:

1. **Objetivo do usuário** — o que o usuário quer accomplir
2. **Rota/tela/componente afetado** — onde a feature vive no frontend
3. **Schema do banco** — modelo Prisma/Drizzle necessário
4. **Migration** — mudança no banco e caminho de rollback
5. **Contrato de API** — endpoints, métodos, request/response shapes
6. **Fluxo principal** — happy path de ponta a ponta
7. **Fluxos alternativos** — edge cases e caminhos de erro
8. **Estados de UI** — loading / empty / error / success
9. **Dados consumidos/enviados** — tipos e validação (Zod)
10. **Acessibilidade** — navegação, labels, foco, responsividade
11. **Testes** — quais camadas testar (detalhes em `TESTING_GUIDE.md`)
12. **Impacto em performance/build** — bundle, queries, índices

---

## Estrutura padrão de uma feature

```
features/
  orders/
    components/
      OrderCard.tsx
      OrderList.tsx
      OrderFilters.tsx
    hooks/
      use-orders.ts
      use-create-order.ts
    api/
      orders-api.ts
    pages/
      OrdersPage.tsx
    types/
      order.types.ts
    server/
      orders.repository.ts
      orders.service.ts
      orders.controller.ts
      orders.routes.ts
      orders.schema.ts       # Zod schemas
```

Nem toda feature precisa começar com todos os arquivos. Crie apenas o necessário para a tarefa atual.

**Alternativa (colocada):** em frameworks como Next.js App Router, server logic pode ficar colocalizada em `app/` com server actions/loaders. O importante é manter a separação conceitual: types → validation → data access → business logic → HTTP → UI.

---

## Fluxo integrado — fatia vertical fullstack

Prefira entregar uma jornada pequena completa em vez de várias camadas ocas.

Ordem obrigatória:

```
types → Prisma schema → migration → Zod schema → repository → service → API route → API client → hook → components → page → register route → test all layers
```

### 1. Tipos

```typescript
// features/orders/types/order.types.ts
export interface Order {
  id: string;
  customer: string;
  total: number;
  status: 'pending' | 'completed' | 'cancelled';
  createdAt: string;
}
```

### 2. Prisma schema

```prisma
model Order {
  id        Int      @id @default(autoincrement())
  userId    Int      @map("user_id")
  status    String   @default("pending") @db.VarChar(20)
  total     Decimal  @db.Decimal(10, 2)
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  user  User         @relation(fields: [userId], references: [id])
  items OrderItem[]

  @@index([userId])
  @@index([status])
  @@map("orders")
}
```

### 3. Migration

```bash
npx prisma migrate dev --name add_orders_table
```

### 4. Zod schema (validação de API)

```typescript
export const createOrderSchema = z.object({
  body: z.object({
    items: z.array(z.object({
      productId: z.number().int().positive(),
      quantity: z.number().int().positive(),
      unitPrice: z.number().positive(),
    })).min(1),
    notes: z.string().optional(),
  }),
});
```

### 5. Repository

```typescript
export class OrdersRepository {
  constructor(private prisma: PrismaClient) {}

  async create(data: Prisma.OrderCreateInput) {
    return this.prisma.order.create({ data, include: { items: true } });
  }

  async findById(id: number) {
    return this.prisma.order.findUnique({ where: { id }, include: { items: true } });
  }
}
```

### 6. Service

```typescript
export class OrdersService {
  constructor(private prisma: PrismaClient) {}

  async create(userId: number, data: CreateOrderInput) {
    const total = data.items.reduce((sum, i) => sum + i.quantity * i.unitPrice, 0);
    return this.prisma.order.create({
      data: { userId, total, items: { create: data.items } },
      include: { items: true },
    });
  }
}
```

### 7. API route

```typescript
router.post('/', authMiddleware, validate(createOrderSchema), OrdersController.create);
```

### 8. API client (frontend)

```typescript
// features/orders/api/orders-api.ts
import { api } from '@/shared/api/client';
import type { Order } from '../types/order.types';

export const ordersApi = {
  getAll: async (filters?: Record<string, string>): Promise<Order[]> => {
    const { data } = await api.get('/orders', { params: filters });
    return data;
  },
};
```

### 9. Hook

```typescript
// features/orders/hooks/use-orders.ts
import { useQuery } from '@tanstack/react-query';
import { ordersApi } from '../api/orders-api';

export function useOrders(filters?: Record<string, string>) {
  return useQuery({
    queryKey: ['orders', filters],
    queryFn: () => ordersApi.getAll(filters),
    staleTime: 30_000,
  });
}
```

### 10–12. Componentes → Página → Registrar rota

```tsx
// features/orders/pages/OrdersPage.tsx
import { useOrders } from '../hooks/use-orders';
import { OrderList } from '../components/OrderList';

export function OrdersPage() {
  const { data: orders, isLoading, isError, refetch } = useOrders();

  if (isLoading) return <OrderListSkeleton />;
  if (isError) return <ErrorState onRetry={refetch} />;
  if (!orders?.length) return <EmptyState message="Nenhum pedido encontrado" />;

  return <OrderList orders={orders} />;
}
```

### 13. Testar todas as camadas

> Detalhes de como testar cada camada em `TESTING_GUIDE.md`.

---

## Fluxo de dependência correto

```
Page
  → Hook (TanStack Query)
    → API client (shared/api)
      → HTTP client (axios/fetch) → API Route → Service → Repository → DB

Page
  → Component
    → recebe props (dados + callbacks)

Page
  → Store (Zustand) apenas se estado global
```

---

## Quando criar uma feature

Crie uma feature quando ela representar uma área funcional clara do produto:

- `auth` — login, registro, recuperação de senha
- `dashboard` — painel principal com resumos
- `orders` — listagem, criação, detalhe de pedidos
- `profile` — edição de dados do usuário
- `settings` — preferências e configurações
- `notifications` — lista e detalhe de notificações

---

## Quando não criar uma feature

Não crie feature nova para:

- Componente compartilhado → `shared/components/`
- Hook genérico → `shared/hooks/`
- Utilitário → `shared/utils/`
- Configuração de API → `shared/api/`
- Constantes globais → `shared/config/`
- Tipos compartilhados → `shared/types/`

---

## Critérios de aceite

Critérios devem ser verificáveis por teste ou inspeção objetiva:

**Frontend:**
- Botão desabilita durante submit
- Erro X aparece no campo Y
- Usuário sem permissão vê estado Z
- Lista vazia mostra estado vazio
- Loading é exibido durante operação assíncrona
- Navegação por teclado alcança ações principais
- Formulário não envia dados inválidos

**Backend:**
- Endpoint retorna status correto para cada cenário
- Validação rejeita dados inválidos campo a campo
- Erro de domínio retorna mensagem e código previsíveis
- Dados sensíveis não vazam na resposta (passwordHash, PII)

---

## Checklist antes de finalizar feature

- Feature respeita a estrutura de pastas?
- Tipos estão explícitos e validados (Zod)?
- Migration criada e testada (com rollback)?
- Repository/Service não importa framework/ORM diretamente?
- Endpoint com validação Zod no input?
- Hook usa TanStack Query (não useEffect + useState)?
- Componente não chama API diretamente?
- Estados loading/error/empty estão tratados?
- Acessibilidade: labels, foco, navegação por teclado?
- Responsividade verificada?
- `npm run build` passa?
- `npm run lint` passa?
- Testes das camadas alteradas passam?

---

## Regra de escopo

- Se a tarefa pedir "estrutura", não implemente feature.
- Se a tarefa pedir "feature", implemente somente aquela feature.
- Se a tarefa pedir "design", não mexa em regra de negócio.
- Se a tarefa pedir "refatoração", não adicione comportamento novo.

---

## Produto

Quando comportamento estiver ambíguo, pare e exponha decisão pendente. Não invente regra de negócio no frontend.

O frontend deve:
- refletir o estado do backend
- validar para UX (não para segurança)
- exibir erros de forma clara
- não criar regras que o backend não confirma

---

## Anti-patterns

**Frontend:**
- Feature sem estados de UI (loading, error, empty).
- Hook custom com useEffect para fetch — use TanStack Query.
- Componente que faz tudo — separe página, lista, card, filtros.
- Tipos duplicados entre features — extraia para `shared/types/`.
- Feature que importa de outra feature diretamente — use `shared/` como ponte.
- Teste que testa implementação (métodos internos) — teste comportamento.
- Commit de feature sem build passing.
- Estado global desnecessário — se o dado é da página, use estado local ou TanStack Query.

**Backend:**
- Endpoint sem validação Zod.
- Service que depende de HTTP request/response diretamente.
- Query N+1 sem eager loading ou batch.
- Log de dados sensíveis (token, senha, PII).
- Abstração criada antes de existir uso real.
- Migration sem caminho de rollback documentado.

---

## Hard rules

- Sempre seguir a ordem: types → schema → migration → Zod → repository → service → route → API client → hook → components → page → testes.
- Nunca pular camada.
- Nunca criar endpoint sem Zod schema de validação.
- Nunca criar tabela sem migration.
- Nunca criar feature sem testes.
