# Padrões de Código React/TypeScript

## Princípios

O código deve ser:

- simples e explícito
- legível sem comentário excessivo
- testável em isolado
- modular e fácil de refatorar

Não criar abstrações antes de existir repetição real.

---

## Nomeação

Use nomes claros e específicos.

Bom:

```ts
useUserOrders       // hook que busca pedidos do usuário
OrderCard           // componente visual de pedido
formatCurrency      // utilidade de formatação
userApi             // camada de API de usuário
OrderStatus         // enum/union de status
```

Ruim:

```ts
useData             // genérico demais
Component1          // sem significado
utils               // caixa de ferramentas sem critério
api                 // mistura tudo
stuff               // inaceitável
```

---

## TypeScript

### Regras obrigatórias

- Tipar props, responses e eventos relevantes.
- Evitar `any`; se inevitável, isole na borda e valide com Zod.
- Preferir tipos explícitos para contratos públicos (props de componentes, parâmetros de hooks).
- Usar `interface` para contratos de objeto, `type` para unions e utilitários.

### Props de componente

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

```tsx
// ❌ Errado: props sem tipo ou com any
export function UserCard(props: any) {
  // ...
}
```

### Validação de dados externos

Sempre valide dados de API com Zod na borda:

```ts
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;

// Na camada de API
async function fetchUser(id: string): Promise<User> {
  const response = await api.get(`/users/${id}`);
  return UserSchema.parse(response.data);
}
```

---

## React

### Componentes

- Componentes pequenos e nomeados pela responsabilidade.
- Props com nomes semânticos, não acopladas ao layout interno.
- Um arquivo, um componente exportado (exceto subcomponentes coesos).
- Não misturar regra de negócio com renderização.

### Hooks

- Hook custom deve encapsular comportamento reutilizável real.
- Hook que faz fetch deve usar TanStack Query, não `useEffect` + `useState`.
- Não esconda side effects perigosos em hook com nome genérico.

### useMemo / useCallback

- Memoização só quando há custo/medição ou renderização problemática.
- Não envolva tudo em `useMemo` por precaução.

```tsx
// ✅ Justificado: filtro pesado em lista grande
const filteredItems = useMemo(
  () => items.filter(complexFilter),
  [items, complexFilter]
);

// ❌ Desnecessário: criação de objeto simples
const style = useMemo(() => ({ color: 'red' }), []);
```

### useEffect

- Evite `useEffect` para derivar estado que pode ser calculado diretamente.
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

---

## Estado

### Escolha da solução

| Tipo de estado | Solução |
|---|---|
| Local de componente | `useState` / `useReducer` |
| Estado de formulário | React Hook Form |
| Dados remotos/cache | TanStack Query |
| Filtros e paginação | URL params (searchParams) |
| Estado global raro | Zustand (ou Redux se já adotado) |

### Zustand — padrão de uso

```ts
// store/cart-store.ts
import { create } from 'zustand';

interface CartItem {
  id: string;
  name: string;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
  clear: () => void;
}

export const useCartStore = create<CartState>((set) => ({
  items: [],
  addItem: (item) =>
    set((state) => ({
      items: [...state.items, item],
    })),
  removeItem: (id) =>
    set((state) => ({
      items: state.items.filter((i) => i.id !== id),
    })),
  clear: () => set({ items: [] }),
}));
```

Não crie store global para estado que vive em uma página.

---

## Data Fetching com TanStack Query

```tsx
// hooks/use-orders.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ordersApi } from '@/shared/api/orders';

export function useOrders(filters: OrderFilters) {
  return useQuery({
    queryKey: ['orders', filters],
    queryFn: () => ordersApi.getAll(filters),
    staleTime: 30_000,
  });
}

export function useCreateOrder() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ordersApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
    },
  });
}
```

### Regras TanStack Query

- `queryKey` deve ser único e incluir parâmetros relevantes.
- `staleTime` explícito quando dado muda pouco.
- `useMutation` com `invalidateQueries` para manter cache atualizado.
- Tratar `isLoading`, `isError` e estado vazio em toda query.
- Não duplicar lógica de fetch em componentes. Use hooks centralizados.

---

## Forms

- Use React Hook Form + Zod para formulários com validação.
- Erros por campo e erro geral devem ser representáveis.
- Submit deve tratar loading e evitar duplo envio.

```tsx
const schema = z.object({
  name: z.string().min(2, 'Nome obrigatório'),
  email: z.string().email('E-mail inválido'),
});

type FormData = z.infer<typeof schema>;

function CreateUserForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } =
    useForm<FormData>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: FormData) => {
    await createUser(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('name')} aria-invalid={!!errors.name} />
      {errors.name && <span role="alert">{errors.name.message}</span>}
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Criando...' : 'Criar'}
      </button>
    </form>
  );
}
```

---

## Estilo

- Use tokens/classes/componentes do design system.
- Tailwind CSS: prefira composição com `@apply` ou `cva` para variantes.
- Evite inline style para regra visual reutilizável.
- Não misture design system com workaround local sem comentário.

---

## Arquivos

- Um arquivo não deve ultrapassar 200-300 linhas sem justificativa.
- Arquivo grande é sinal de responsabilidade mista.

---

## Dependências

Antes de adicionar dependência:

1. Verifique se já existe alternativa no projeto.
2. Avalie se é realmente necessária vs. browser API ou código simples.
3. Verifique tamanho do bundle (`bundlephobia.com`).
4. Verifique se é mantida ativamente.

Não adicionar lib para uma função resolvida com stdlib/browser API.

---

## Comentários

Comente apenas quando o código não for autoexplicativo.

Não usar comentários para explicar código ruim — melhore o código.

---

## Anti-patterns

- **useEffect para sincronizar state do React:** se o dado deriva de props/state, calcule diretamente.
- **Store global para estado local:** não use Zustand/Redux para dados que vivem em um componente.
- **Chamada HTTP em componente:** use hook + TanStack Query.
- **`any` em contrato público:** use Zod ou tipo explícito.
- **Componente de 500 linhas:** separe em componentes menores.
- **Prop drilling profundo:** se passou por 4+ níveis, considere context ou store.
- **Duplicação de lógica entre componentes:** extraia para hook ou utilitário.
- **Import barrel sem tree-shaking:** evite `index.ts` que re-exporta tudo em library code.
- **Re-renderização sem memoização em lista grande:** use `key` estável e `React.memo` quando medido.
