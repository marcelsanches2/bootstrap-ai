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
