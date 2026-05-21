# React Web Architecture

## Objective

Organize UI, state, data fetching, and presentation rules without turning each screen into its own framework.

## Recommended structure

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

Adapt to the framework. In Next.js, respect `app/`/`pages/`, but preserve feature boundaries.

## Components

- Page/container coordinates data and high-level layout.
- UI components receive explicit props.
- Pure components do not call APIs directly.
- Hooks encapsulate data fetching, events, and browser integration.

## Data fetching

- Centralize HTTP client and error handling.
- Use TanStack Query or equivalent pattern for cache/server state.
- Do not confuse server state with client-side global state.
- Define loading, error, empty, and retry.

## State

- `useState/useReducer`: local state.
- URL/search params: filters and navigable state.
- TanStack Query: remote data/cache.
- Zustand/Redux/context: truly global and rare state.

## Routes

- Public/protected routes must be explicit.
- New screen must declare path, params, and navigation behavior.
- Do not use loose repeated strings when a route map exists.

## Errors

- API error must become renderable state.
- Error boundary must exist in critical areas.
- Technical message must not leak to the end user.

## Anti-patterns

- 500-line component doing fetch, logic, layout, and formatting.
- `useEffect` to derive state that could be calculated.
- Global context to avoid passing two props.
- Duplicated API client per feature without reason.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any below.

- **Pure components do not call APIs**: UI components receive props; data fetching stays in hooks.
- **Do not confuse server state with global state**: remote data belongs to TanStack Query, not Zustand/Redux.
- **Do not use loose strings for routes**: when a route map exists, use it instead of repeated strings.
- **Technical message cannot leak to the user**: API errors must become renderable state, no stack traces.
- **Error boundary in critical areas**: critical UI areas must have error boundaries.
- **Avoid monolithic component**: 500+ line component with fetch + logic + layout + formatting is an anti-pattern.
- **Do not use useEffect to derive state**: derivable state from props/state should be calculated directly.
- **Do not use global Context to avoid light prop drilling**: global Context only when truly necessary.
