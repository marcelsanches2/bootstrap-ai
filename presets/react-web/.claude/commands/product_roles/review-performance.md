# Role: Performance Web

## Sua contribuição
Gera a seção "Performance" do plano, definindo estratégias de bundle size, lazy loading, Web Vitals, otimização de imagens e renderização eficiente.

## Referência
- docs/ai/PERFORMANCE_GUIDE.md

## O que incluir

- **Bundle size**: analise dependências novas e impacto no bundle. Prefira imports nomeados, tree-shakeable. Dependência pesada sem justificativa é proibida.
- **Lazy loading**: rotas, modais pesados e features grandes carregadas sob demanda. Defina pontos de `React.lazy` + `Suspense` ou dynamic imports. Telas pesadas não devem carregar no caminho crítico.
- **Web Vitals**: defina métricas relevantes (LCP, FID/INP, CLS) e metas. Quando performance é objetivo explícito, proponha medição antes/depois.
- **Imagens/assets**: formato otimizado (WebP/AVIF), dimensões explícitas (`width`/`height`), lazy loading nativo, srcset para responsividade. Assets pesados sem otimização são proibidos.
- **Renderização**: evite re-renders desnecessários — memoização seletiva, listas virtualizadas quando grandes, estado no menor escopo possível. Identifique renderizações evitáveis.
- **Escala frontend**: para features grandes — cache de server state (TanStack Query), listas longas com paginação/virtualização, contexto global com escopo mínimo, observabilidade de métricas frontend.

## Regras

- Dependência pesada nova (>50KB gzip) deve ser justificada — considere alternativas leves.
- Tela pesada no caminho crítico sem lazy loading é proibida.
- Imagens sem dimensões explícitas ou formato otimizado são proibidas.
- Não proponha otimização prematura em componentes triviais — foque onde há impacto real.
- Otimização sem métrica é especulação — quando performance é objetivo, proponha medição.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Performance

### Bundle
| Item | Impacto | Estratégia |
|------|---------|-----------|
| {dependência/import} | {tamanho estimado ou risco} | {tree-shaking / alternativa / lazy} |

### Lazy loading
| Ponto | Estratégia | Justificativa |
|-------|-----------|---------------|
| {rota/modal/feature} | {React.lazy / dynamic / Suspense} | {por quê} |

### Web Vitals
| Métrica | Meta | Como medir |
|---------|------|-----------|
| LCP | {ex: <2.5s} | {ferramenta} |
| INP | {ex: <200ms} | {ferramenta} |
| CLS | {ex: <0.1} | {ferramenta} |

### Imagens / Assets
| Asset | Formato | Dimensões | Lazy | srcset |
|-------|---------|-----------|------|--------|
| {arquivo} | {WebP/AVIF/PNG} | {WxH} | {sim/não} | {sim/não} |

### Renderização
| Componente | Risco | Estratégia |
|-----------|-------|-----------|
| {componente} | {rerenders / lista grande / etc.} | {memo / virtualize / estado mínimo} |

### Escala frontend
{Cache strategy, listas longas, contexto global, observabilidade — se aplicável}
```
