# Web Performance

## Principle

Optimize what affects experience or cost. Do not turn simple code into a maze for micro-optimization.

## Bundle

- New dependency must consider size.
- Use lazy loading for heavy routes/areas.
- Avoid importing an entire library for a single small function.

## Rendering

- Avoid duplicate state that forces unnecessary renders.
- Virtualize large lists.
- Debounce for search/input that triggers network requests.
- Memoization needs a clear reason.

## Images/assets

- Defined dimensions when possible.
- Modern format when the pipeline supports it.
- Lazy load for below-the-fold images.
- Do not upload giant assets without compression.

## Web Vitals

Changes affecting the first screen must consider:

- LCP
- CLS
- INP

## Measurement

When performance is the goal of the task, the plan must indicate before/after metrics or a validation tool.

## Large applications

When the application grows, also review:

- route/feature splitting to reduce initial bundle
- server state cache with clear invalidation
- large lists with pagination, controlled infinite loading, or virtualization
- large forms without global rendering on every keystroke
- provider/context in small scope to avoid re-rendering the entire tree
- shared assets and dependencies without duplication
- frontend observability: error, route, version, and Web Vitals when applicable

A large frontend plan that only talks about visual components and ignores data/cache/rendering must become a pending item in `review-performance`.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Do not upload giant assets without compression**: images and assets must use modern format and adequate compression.
- **Large frontend plan that ignores data/cache/rendering**: must become a pending item in `review-performance`.
- **Mandatory measurement when performance is the task goal**: the plan must indicate before/after metrics or a validation tool.
- **Virtualize large lists**: large lists must use virtualization, not render everything at once.
- **Debounce for search/input that triggers network**: avoid excessive requests per keystroke.
