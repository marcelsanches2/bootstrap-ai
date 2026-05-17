# Arquitetura React Web

## Objetivo

Organizar UI, estado, data fetching e regras de apresentação sem transformar cada tela em framework próprio.

## Estrutura recomendada

```txt
src/
  app/
    routes/
    providers/
    config/
  shared/
    components/
    hooks/
    utils/
    api/
    styles/
  features/
    billing/
      components/
      hooks/
      api/
      model/
      pages/
      tests/
```

Adapte ao framework. Em Next.js, respeite `app/`/`pages/`, mas preserve boundaries por feature.

## Componentes

- Page/container coordena dados e layout de alto nível.
- Componentes de UI recebem props explícitas.
- Componentes puros não chamam API diretamente.
- Hooks encapsulam data fetching, eventos e integração com browser.

## Data fetching

- Centralize client HTTP e tratamento de erro.
- Use TanStack Query ou padrão equivalente para cache/server state.
- Não confunda server state com estado global client-side.
- Defina loading, error, empty e retry.

## Estado

- `useState/useReducer`: estado local.
- URL/search params: filtros e estado navegável.
- TanStack Query: dados remotos/cache.
- Zustand/Redux/context: estado global real e raro.

## Rotas

- Rotas públicas/protegidas precisam estar explícitas.
- Tela nova deve declarar path, params e comportamento de navegação.
- Não use strings soltas repetidas quando houver mapa de rotas.

## Erros

- Erro de API deve virar estado renderizável.
- Boundary de erro deve existir em áreas críticas.
- Mensagem técnica não deve vazar para usuário final.

## Anti-patterns

- Componente de 500 linhas fazendo fetch, regra, layout e formatação.
- `useEffect` para derivar estado que poderia ser calculado.
- Context global para evitar passar duas props.
- API client duplicado por feature sem motivo.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Componentes puros não chamam API**: componentes de UI recebem props; data fetching fica em hooks.
- **Não confundir server state com estado global**: dados remotos pertencem ao TanStack Query, não a Zustand/Redux.
- **Não usar strings soltas para rotas**: quando houver mapa de rotas, use-o em vez de strings repetidas.
- **Mensagem técnica não pode vazar para o usuário**: erros de API devem virar estado renderizável, sem stack trace.
- **Erro boundary em áreas críticas**: áreas críticas da UI devem ter error boundary.
- **Evitar componente monolítico**: componente de 500+ linhas com fetch + regra + layout + formatação é anti-pattern.
- **Não usar useEffect para derivar estado**: estado derivável de props/state deve ser calculado diretamente.
- **Não usar Context global para evitar prop drilling leve**: Context global só quando realmente necessário.
