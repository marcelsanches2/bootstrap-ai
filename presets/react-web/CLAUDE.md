# CLAUDE.md

Main contract for Claude Code in this React Web project.

## Project

{{PROJECT_NAME}} is a React/TypeScript web application. Focus: consistent UX, predictable components, real accessibility, sufficient performance, and verifiable delivery.

Default stack:

- React
- TypeScript
- Vite or Next.js when applicable
- React Router / framework router when applicable
- TanStack Query / Axios when relevant data fetching exists
- Zustand / Redux only when global state is needed
- Vitest / Jest for unit/component
- Playwright / Cypress for E2E when the flow justifies it

## On-demand reading

| Task type | Document(s) to read |
|---|---|
| Architecture, boundaries, state, routes, or data fetching | `docs/ai/ARCHITECTURE.md` |
| Screen, component, layout, color, typography, or UX | `docs/ai/DESIGN_SYSTEM.md` |
| Accessibility, keyboard, focus, labels, or semantics | `docs/ai/ACCESSIBILITY_GUIDE.md` |
| Performance, bundle, rendering, images, or Web Vitals | `docs/ai/PERFORMANCE_GUIDE.md` |
| Deploy, env, build, cache, or rollback | `docs/ai/DEPLOYMENT_GUIDE.md` |
| Code / refactor | `docs/ai/CODING_STANDARDS.md` |
| Tests | `docs/ai/TESTING_GUIDE.md` |
| Full feature | `docs/ai/FEATURE_GUIDE.md` + documents of affected areas |

## Current priorities

1. Clear and consistent UX
2. Small, testable components
3. Minimum accessibility from the start
4. State/data fetching without magic
5. Reliable production build
6. Performance without premature optimization

## Mandatory rules

- Do not mix heavy business logic inside a visual component.
- Do not scatter HTTP calls in components when an API/hook layer exists.
- Do not create global state for local state.
- Do not use `any` to bypass typing in a public contract.
- Do not break keyboard navigation.
- Do not use hardcoded color/spacing when a token/component exists.
- Do not create a generic component before there is real repetition.
- Do not rely on layout solely by pixel-perfect at one width.
- Do not leave loading/error/empty states undecided.
- Do not commit real `.env`.

## After changes

- Run typecheck/lint when scripts exist.
- Run affected tests.
- Run production build for relevant changes to app/routes/deps.
- For relevant UI, validate responsiveness, focus, and visual states.
- Report changed files, executed commands, and pending items.
