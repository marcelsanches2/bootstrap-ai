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

Return Markdown only. Be concise; prefer bullets over prose and tables only for real comparisons.

Required section(s):
- `## Frontend performance`

For each section include only: decision, risk, validation. Skip boilerplate.
If the role does not apply, write exactly one sentence: `Does not apply — {reason}`.
Do not duplicate sections owned by another selected role; mention cross-cutting dependencies in one bullet.
