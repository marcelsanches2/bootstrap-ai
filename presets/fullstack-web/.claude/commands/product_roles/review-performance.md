# Role: Frontend Performance

## Your contribution
Generates the "Frontend performance" section of the plan, defining bundle, rendering, assets, lazy loading, and Web Vitals measurement strategies.

## Reference
- docs/ai/PERFORMANCE_GUIDE.md

## What to include
- **Bundle**: impact of new dependencies, optimized imports (tree-shaking, barrel exports). Heavy dependency with justification and alternative considered.
- **Lazy loading**: heavy routes/areas with `React.lazy` or dynamic import. Heavy screen not on the critical path.
- **Renders**: avoid duplicate state, large lists virtualized when needed, optimized effects. Identify avoidable re-renders.
- **Images/assets**: size, format (WebP/AVIF), explicit dimensions, native lazy loading. Asset without optimization needs justification.
- **Measurement**: before/after metrics when performance is the goal (LCP, FID/INP, CLS). Optimization without metrics needs a risk justification.
- **Frontend scale**: for large features, consider bundle growth, server state caching, long lists (virtualization), global context (split), and frontend observability.

## Rules
- Heavy dependency without justification is a pending item.
- Heavy screen on critical path without lazy loading is a pending item.
- Optimization without metrics or identified risk is a pending item.
- Performance without premature optimization — only optimize when there is risk or metrics.
- If the change does not affect performance: write "Does not apply" and explain why.

## Output format

```md
## Frontend performance

### Bundle
| New dep | Approximate size | Justification | Alternative considered |
|---|---|---|---|
| {name} | {KB} | {why} | {alternative} |

### Lazy loading
| Route/area | Strategy | Condition |
|---|---|---|
| {name} | {React.lazy / dynamic / suspense} | {when it loads} |

### Renders
| Component | Risk | Mitigation |
|---|---|---|
| {name} | {re-render / large list / effect} | {memo / virtualization / cleanup} |

### Images/assets
| Asset | Format | Dimensions | Lazy | Optimization |
|---|---|---|---|---|
| {path} | {WebP/PNG/...} | {WxH} | {yes/no} | {compression/responsive} |

### Measurement
| Metric | Before (estimated) | Target | How to measure |
|---|---|---|---|
| {LCP/FID/CLS} | {value} | {value} | {tool} |

### Frontend scale
{strategies for large features: bundle, cache, lists, context split}
```
