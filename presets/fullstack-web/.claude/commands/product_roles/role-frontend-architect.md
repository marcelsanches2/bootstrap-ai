# Role: Frontend Architect

## Sua contribuição
Gera a seção de patterns React/componentes do plano, definindo separação de componentes, data fetching, estado, rotas e tratamento de erros no frontend.

## Referência
- docs/ai/ARCHITECTURE.md
- docs/ai/CODING_STANDARDS.md

## O que incluir
- **Separação de componentes**: defina page/container, componentes puros (apenas UI), hooks customizados (lógica reutilizável). Componente visual não deve conter fetch nem regra de negócio pesada.
- **Data fetching**: encapsule chamadas HTTP em hooks ou camada de API (TanStack Query / hook próprio). Defina loading, error, retry e cache. Nunca espalhar fetch direto em componente.
- **Estado local/global**: justifique o tipo de estado para cada dado — `useState` para local, URL para filtros/nav, query cache para dados do servidor, Zustand/Redux apenas quando estado global for realmente necessário. Estado no menor escopo correto.
- **Rotas**: defina paths, params, guards (auth/role) e navegação. Rotas explícitas, sem ambiguidade.
- **Erros**: defina error boundaries, mensagens user-friendly e fallback UI. Erros viram UI recuperável, nunca vazam detalhe técnico.
- **SSR/CSR**: quando aplicável, indique o que renderiza no servidor vs cliente com justificativa.
- **Code splitting**: identifique rotas/áreas pesadas que merecem lazy loading.

## Regras
- Não misturar regra de negócio pesada dentro de componente visual.
- Não espalhar chamada HTTP em componente quando existe camada de API/hook.
- Não criar estado global para estado local.
- Não usar `any` para fugir de tipagem em contrato público.
- Não criar componente genérico antes de existir repetição real.
- Se a task não toca UI/arquitetura frontend: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Frontend — Patterns

### Componentes
{lista de componentes/pages com responsabilidade e tipo (page | container | puro | hook)}

### Data fetching
| Dado | Hook/função | Cache | Loading | Error |
|---|---|---|---|---|
| {dado} | {onde busca} | {estratégia} | {UI de loading} | {UI de erro} |

### Estado
| Estado | Tipo | Escopo | Justificativa |
|---|---|---|---|
| {dado} | local / URL / query cache / global | {onde} | {por quê} |

### Rotas
| Path | Componente | Guard | Params |
|---|---|---|---|
| {path} | {page} | {auth/role/none} | {params} |

### Tratamento de erros
{error boundaries, mensagens, fallbacks por área}

### SSR/CSR e code splitting
{o que é server-rendered vs client-rendered, o que é lazy loaded}
```
