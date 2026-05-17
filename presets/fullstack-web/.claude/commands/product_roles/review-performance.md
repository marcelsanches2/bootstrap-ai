# Role: Performance Frontend

## Sua contribuição
Gera a seção "Performance frontend" do plano, definindo estratégias de bundle, renderização, assets, lazy loading e medição de Web Vitals.

## Referência
- docs/ai/PERFORMANCE_GUIDE.md

## O que incluir
- **Bundle**: impacto de dependências novas, imports otimizados (tree-shaking, barrel exports). Dependência pesada com justificativa e alternativa considerada.
- **Lazy loading**: rotas/áreas pesadas com `React.lazy` ou dynamic import. Tela pesada não carrega no caminho crítico.
- **Renderizações**: evitar estado duplicado, listas grandes virtualizadas quando necessário, efeitos otimizados. Identificar re-renders evitáveis.
- **Imagens/assets**: tamanho, formato (WebP/AVIF), dimensões explícitas, lazy loading nativo. Asset sem otimização precisa de justificativa.
- **Medição**: métrica antes/depois quando performance é objetivo (LCP, FID/INP, CLS). Otimização sem métrica precisa de justificativa de risco.
- **Escala de frontend**: para features grandes, considere bundle growth, cache de server state, listas longas (virtualização), contexto global (split) e observabilidade frontend.

## Regras
- Dependência pesada sem justificativa é pendência.
- Tela pesada no caminho crítico sem lazy loading é pendência.
- Otimização sem métrica ou risco identificado é pendência.
- Performance sem otimização prematura — só otimize quando há risco ou métrica.
- Se a mudança não afeta performance: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Performance frontend

### Bundle
| Dep nova | Tamanho aprox. | Justificativa | Alternativa considerada |
|---|---|---|---|
| {nome} | {KB} | {por quê} | {alternativa} |

### Lazy loading
| Rota/área | Estratégia | Condição |
|---|---|---|
| {nome} | {React.lazy / dynamic / suspense} | {quando carrega} |

### Renderizações
| Componente | Risco | Mitigação |
|---|---|---|
| {nome} | {re-render / lista grande / efeito} | {memo / virtualização / cleanup} |

### Imagens/assets
| Asset | Formato | Dimensões | Lazy | Otimização |
|---|---|---|---|---|
| {caminho} | {WebP/PNG/...} | {WxH} | {sim/não} | {compressão/responsive} |

### Medição
| Métrica | Antes (estimado) | Meta | Como medir |
|---|---|---|---|
| {LCP/FID/CLS} | {valor} | {valor} | {ferramenta} |

### Escala de frontend
{estratégias para features grandes: bundle, cache, listas, context split}
```
