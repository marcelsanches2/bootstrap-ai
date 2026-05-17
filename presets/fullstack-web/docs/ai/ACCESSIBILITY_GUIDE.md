# Acessibilidade React Web

## Princípios

Acessibilidade não é opcional nem fase final. Todo componente entregue deve ser navegável por teclado e compreensível por leitor de tela.

## Mínimo obrigatório

- HTML semântico antes de ARIA.
- Botões são `<button>`; links são `<a>`.
- Toda ação via mouse deve ser possível por teclado.
- Foco visível e ordem de foco lógica.
- Inputs com `<label>` associado (não apenas placeholder).
- Erros de formulário anunciáveis e próximos do campo.
- Contraste mínimo 4.5:1 para texto normal, 3:1 para texto grande.

## Semântica e componentes

Prefira elementos nativos. Use ARIA apenas para complementar.

```tsx
// ✅ Certo: botão nativo com semântica automática
<button onClick={handleSave}>Salvar</button>

// ❌ Errado: div sem semântica nenhuma
<div onClick={handleSave}>Salvar</div>
```

Para componentes compostos (dropdowns, modais, tabs), use primitivas acessíveis:

- `@radix-ui/react-*` — acesso livre, semântica completa
- `@headlessui/react` — boa integração com Tailwind
- `react-aria` — hooks focados em acessibilidade

Não reinvente padrão WAI-ARIA se biblioteca consolidada resolve.

## Formulários

### Labels e ajuda

```tsx
<label htmlFor="email">E-mail</label>
<input id="email" type="email" aria-describedby="email-help" />
<span id="email-help">Use seu e-mail corporativo</span>
```

### Erros de campo

```tsx
<input
  id="email"
  type="email"
  aria-invalid={!!error}
  aria-describedby={error ? 'email-error' : undefined}
/>
{error && <span id="email-error" role="alert">{error}</span>}
```

### Validação com React Hook Form + Zod

```tsx
const schema = z.object({
  email: z.string().email('E-mail inválido'),
  password: z.string().min(8, 'Mínimo 8 caracteres'),
});

const { register, formState: { errors } } = useForm({
  resolver: zodResolver(schema),
});

<input
  {...register('email')}
  aria-invalid={!!errors.email}
  aria-describedby={errors.email ? 'email-error' : undefined}
/>
{errors.email && (
  <span id="email-error" role="alert">{errors.email.message}</span>
)}
```

## ARIA

Use ARIA para complementar semântica, não para consertar HTML errado.

- `aria-label` quando texto visível não existe.
- `aria-describedby` para ajuda/erro.
- `aria-live="polite"` para feedback assíncrono (toast, status de loading).
- `aria-live="assertive"` apenas para alertas críticos.
- `aria-expanded`, `aria-controls` para dropdowns e collapsibles.

### Região live com TanStack Query

```tsx
<div aria-live="polite" aria-atomic="true">
  {isLoading && 'Carregando dados...'}
  {isError && 'Erro ao carregar. Tente novamente.'}
</div>
```

## Modais e overlays

Requisitos obrigatórios:

- Trap de foco dentro do modal enquanto aberto.
- Escape fecha quando seguro (sem dados não salvos).
- Foco move para o modal ao abrir.
- Foco retorna ao elemento gatilho ao fechar.
- Clique fora não deve destruir dados sem confirmação.

Use `@radix-ui/react-dialog` ou equivalente que resolve isso automaticamente:

```tsx
<Dialog.Root open={open} onOpenChange={setOpen}>
  <Dialog.Trigger asChild>
    <button>Abrir</button>
  </Dialog.Trigger>
  <Dialog.Portal>
    <Dialog.Overlay className="fixed inset-0 bg-black/50" />
    <Dialog.Content className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
      <Dialog.Title>Confirmar ação</Dialog.Title>
      <Dialog.Description>Tem certeza que deseja continuar?</Dialog.Description>
      {/* conteúdo */}
    </Dialog.Content>
  </Dialog.Portal>
</Dialog.Root>
```

## Imagens e ícones

- Imagens informativas precisam de `alt` descritivo.
- Imagens decorativas usam `alt=""` e `aria-hidden="true"`.
- Ícones clicáveis precisam de `aria-label` ou label visível.

```tsx
// Ícone como botão
<button aria-label="Fechar notificação" onClick={onClose}>
  <XIcon aria-hidden="true" />
</button>
```

## Navegação e rotas

- Use `<nav>` com `aria-label` para navegação principal.
- Indique página ativa com `aria-current="page"`.
- React Router: use `<Link>` do router, não `<a>` com onClick.

```tsx
<nav aria-label="Navegação principal">
  <ul>
    {links.map((link) => (
      <li key={link.path}>
        <Link
          to={link.path}
          aria-current={location.pathname === link.path ? 'page' : undefined}
        >
          {link.label}
        </Link>
      </li>
    ))}
  </ul>
</nav>
```

## Ferramentas de verificação

```bash
# Lint de acessibilidade com eslint-plugin-jsx-a11y
npx eslint --rule 'jsx-a11y/*: error' src/
```

## Anti-patterns

- **Div como botão:** não use `<div onClick>` para ações. Use `<button>`.
- **Placeholder como label:** placeholder desaparece ao digitar e não substitui label.
- **Overlay sem trap de foco:** tab sai do modal para conteúdo invisível.
- **Cor como única indicação:** nunca use apenas cor para indicar erro/estado. Combine com ícone ou texto.
- **aria-hidden em elemento focável:** se tem `aria-hidden`, não pode receber foco.
- **Imagem sem alt:** alt vazio para decorativa, alt descritivo para informativa. Nunca omitir o atributo.
- **Lista infinita sem anúncio:** paginação/scroll infinito precisa anunciar novos itens via `aria-live`.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

### Semântica e navegação
- **Acessibilidade não é opcional nem fase final**: todo componente entregue deve ser navegável por teclado e compreensível por leitor de tela.
- **Div como botão é proibido**: ações usam `<button>`, links usam `<a>`.
- **Toda ação via mouse deve ser possível por teclado**: sem exceções.

### Formulários
- **Inputs com `<label>` associado**: nunca usar apenas placeholder como label.
- **Erros de formulário devem ser anunciáveis e próximos do campo**: use `aria-invalid` e `aria-describedby`.

### Visual
- **Contraste mínimo 4.5:1 para texto normal, 3:1 para texto grande**: nunca usar apenas cor para indicar erro/estado.
- **Imagem informativa precisa `alt` descritivo**: decorativa usa `alt=""` + `aria-hidden="true"`. Nunca omitir o atributo.

### Modais e overlays
- **Overlay sem trap de foco é proibido**: tab não pode sair do modal para conteúdo invisível.

### ARIA
- **Não reinventar padrão WAI-ARIA se biblioteca consolidada resolve**: use Radix, Headless UI ou react-aria.
- **`aria-hidden` em elemento focável é proibido**: se tem `aria-hidden`, não pode receber foco.
- **Lista infinita sem anúncio**: paginação/scroll infinito precisa anunciar novos itens via `aria-live`.
