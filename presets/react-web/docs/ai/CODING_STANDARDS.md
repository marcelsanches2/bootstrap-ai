# Padrões de Código React/TypeScript

## TypeScript

- Tipar props, responses e eventos relevantes.
- Evitar `any`; se inevitável, isole na borda e valide.
- Preferir tipos explícitos para contratos públicos.
- Não duplicar tipo de API manualmente se houver schema gerado/confiável.

## React

- Componentes pequenos e nomeados pela responsabilidade.
- Props com nomes semânticos, não acopladas ao layout interno.
- Evite efeitos para lógica síncrona derivável.
- Memoização só quando há custo/medição ou renderização problemática.

## Hooks

- Hook custom deve encapsular comportamento reutilizável real.
- Hook que faz fetch deve expor estados claros: data/loading/error/refetch.
- Não esconda side effects perigosos em hook com nome genérico.

## Forms

- Validação client-side melhora UX, não substitui validação backend.
- Erros por campo e erro geral devem ser representáveis.
- Submit deve tratar loading e evitar duplo envio quando relevante.

## Estilo

- Use tokens/classes/componentes do projeto.
- Evite inline style para regra visual reutilizável.
- Não misture design system com workaround local sem comentário.

## Dependências

- Dependência nova precisa justificar tamanho, manutenção e alternativa nativa.
- Não adicione lib para uma função pequena resolvida com stdlib/browser API.
