# CLAUDE.md

Main contract for Claude Code in this fullstack web project.

## Project

{{PROJECT_NAME}} is a fullstack web application (Next.js/Remix) with React frontend and Node.js backend in the same repository. Focus: stable API contracts, consistent UX, testable components, safe migrations, minimal observability, and recoverable deploys.

Default stack:

- Node.js LTS
- TypeScript
- Next.js or Remix (App Router / nested routes)
- React for UI
- Prisma or Drizzle for persistence
- PostgreSQL in production; SQLite for dev/test when appropriate
- TanStack Query / Axios for data fetching
- Zustand / Redux only when global state is needed
- Zod for validation (frontend boundaries AND backend input)
- Vitest / Jest for tests
- Playwright / Cypress for E2E

## On-demand reading

Files in `docs/ai/` should be read according to the task type. Do not read them all automatically.

| Task type | Document(s) to read |
|---|---|
| Architecture, boundaries, state, routes, data flow, DI | `docs/ai/ARCHITECTURE.md` |
| Screen, component, layout, color, typography, UX | `docs/ai/DESIGN_SYSTEM.md` |
| Accessibility, keyboard, focus, labels, semantics | `docs/ai/ACCESSIBILITY_GUIDE.md` |
| Performance, bundle, rendering, images, Web Vitals | `docs/ai/PERFORMANCE_GUIDE.md` |
| Endpoint, status code, schema, OpenAPI, pagination | `docs/ai/API_GUIDE.md` |
| Models, migrations, indexes, constraints, queries | `docs/ai/DATABASE_GUIDE.md` |
| Auth, authorization, secrets, PII, rate limit, headers | `docs/ai/SECURITY_GUIDE.md` |
| Logs, metrics, tracing, healthcheck, incidents | `docs/ai/OBSERVABILITY_GUIDE.md` |
| Scale, concurrency, backend performance, queues, cache, pool | `docs/ai/SCALABILITY_GUIDE.md` |
| Deploy, env, build, cache, CI/CD, rollback | `docs/ai/DEPLOYMENT_GUIDE.md` |
| Code / refactor | `docs/ai/CODING_STANDARDS.md` |
| Tests | `docs/ai/TESTING_GUIDE.md` |
| Full feature | `docs/ai/FEATURE_GUIDE.md` + docs of affected areas |

## Current priorities

1. Stable API contract
2. Clear and consistent UX
3. Small, testable components
4. Safe migrations with rollback
5. Minimal observability for production debugging
6. Recoverable deploy
7. Performance without premature optimization

## Mandatory rules

**Frontend:**

- Do not mix heavy business logic inside a visual component.
- Do not scatter HTTP calls in components when an API/hook layer exists.
- Do not create global state for local state.
- Do not use `any` to bypass typing in a public contract.
- Do not break keyboard navigation.
- Do not use hardcoded color/spacing when a token/component exists.
- Do not create a generic component before there is real repetition.
- Do not rely on layout solely by pixel-perfect at one width.
- Do not leave loading/error/empty states undecided.

**Backend:**

- Do not alter schema without a migration and a documented rollback path.
- Do not commit secrets, tokens, dumps, real `.env`, or database credentials.
- Do not log tokens, passwords, Authorization headers, cookies, or PII without masking.
- Public functions need explicit types.
- Endpoints need predictable error contracts.
- DTO/schema is not a domain entity.
- Domain does not import framework, ORM, fetch/axios, or external SDK.
- Transactions must have explicit boundaries.
- Tests cannot depend on production, real clocks without control, or external networks without mocks.

## After changes

- Run typecheck/lint when scripts exist.
- Run affected tests.
- Run production build for changes in routes/deps.
- Run `prisma generate` if schema was altered.
- For relevant UI, validate responsiveness, focus, and visual states.
- Report changed files, executed commands, and pending items.

## Decision principle

Good fullstack code fails with a diagnosable error, preserves data, and allows rollback at 3 AM. Frontend reflects backend state, validates for UX not for security. Backend is operationally simple and explicit.
