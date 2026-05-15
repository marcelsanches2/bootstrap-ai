# Guia de Feature React Web

## Plano mínimo

Toda feature deve definir:

- objetivo do usuário
- rota/tela/componente afetado
- fluxo principal
- fluxos alternativos
- estados loading/empty/error/success
- dados consumidos/enviados (API)
- acessibilidade (navegação, labels, foco)
- responsividade (mobile, tablet, desktop)
- testes (unitário, integração, E2E quando crítico)
- impacto em performance/build

---

## Estrutura padrão de uma feature

```txt
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
    tests/
      OrderCard.test.tsx
      use-orders.test.ts
```

Nem toda feature precisa começar com todos os arquivos. Crie apenas o necessário para a tarefa atual.

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

- componente compartilhado → `shared/components/`
- hook genérico → `shared/hooks/`
- utilitário → `shared/utils/`
- configuração de API → `shared/api/`
- constantes globais → `shared/config/`
- tipos compartilhados → `shared/types/`

---

## Fatia vertical

Prefira entregar uma jornada pequena completa em vez de várias telas ocas.

```txt
rota → página → hook de dados → componente → estados UI → testes → build
```

Exemplo de fatia vertical para feature de pedidos:

1. Definir tipos (`order.types.ts`)
2. Criar camada de API (`orders-api.ts`)
3. Criar hook TanStack Query (`use-orders.ts`)
4. Criar componentes visuais (`OrderCard`, `OrderList`)
5. Criar página que compõe tudo (`OrdersPage.tsx`)
6. Registrar rota
7. Tratar loading/error/empty

---

## Fluxo de dependência correto

```txt
Page
  → Hook (TanStack Query)
    → API layer (shared/api)
      → HTTP client (axios/fetch)

Page
  → Component
    → recebe props (dados + callbacks)

Page
  → Store (Zustand) apenas se estado global
```

---

## Exemplo completo: feature de listagem

### Tipos

```ts
// features/orders/types/order.types.ts
export interface Order {
  id: string;
  customer: string;
  total: number;
  status: 'pending' | 'completed' | 'cancelled';
  createdAt: string;
}
```

### API

```ts
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

### Hook

```ts
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

### Página com estados

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

---

## Critérios de aceite

Critérios devem ser verificáveis por teste ou inspeção objetiva:

- botão desabilita durante submit
- erro X aparece no campo Y
- usuário sem permissão vê estado Z
- lista vazia mostra estado vazio
- loading é exibido durante operação assíncrona
- navegação por teclado alcança ações principais
- formulário não envia dados inválidos

---

## Checklist antes de finalizar feature

- Feature respeita a estrutura de pastas?
- Tipos estão explícitos e validados?
- Hook usa TanStack Query (não useEffect + useState)?
- Componente não chama API diretamente?
- Estados loading/error/empty estão tratados?
- Acessibilidade: labels, foco, navegação por teclado?
- Responsividade verificada?
- `npm run build` passa?
- `npm run lint` passa?

---

## Produto

Quando comportamento estiver ambíguo, pare e exponha decisão pendente. Não invente regra de negócio no frontend.

O frontend deve:

- refletir o estado do backend
- validar para UX (não para segurança)
- exibir erros de forma clara
- não criar regras que o backend não confirma

---

## Regra de escopo

- Se a tarefa pedir "estrutura", não implemente feature.
- Se a tarefa pedir "feature", implemente somente aquela feature.
- Se a tarefa pedir "design", não mexa em regra de negócio.
- Se a tarefa pedir "refatoração", não adicione comportamento novo.

---

## Anti-patterns

- **Feature sem estados de UI:** loading, error e empty não são opcionais.
- **Hook custom com useEffect para fetch:** use TanStack Query.
- **Componente que faz tudo:** separe página, lista, card, filtros.
- **Tipos duplicados entre features:** extraia para `shared/types/` ou `features/<name>/types/`.
- **Feature que importa de outra feature diretamente:** use `shared/` como ponte.
- **Teste que testa implementação (métodos internos):** teste comportamento e output.
- **Commit de feature sem build passing:** rode `npm run build` antes.
- **Feature com estado global desnecessário:** se o dado é da página, use estado local ou TanStack Query.
