# CLAUDE.md

Main contract for Claude Code in this Node.js/TypeScript backend.

## Project

{{PROJECT_NAME}} is a Node.js/TypeScript backend for APIs and domain services, focused on simple architecture, explicit contracts, operational security, and incremental evolution.

Default stack:

- Node.js LTS
- TypeScript
- Fastify, Express, or Nest when applicable
- Zod/class-validator for edge validation when applicable
- Prisma or Drizzle for persistence when applicable
- PostgreSQL in production; SQLite only for development/tests when appropriate
- Vitest/Jest for testing
- ESLint/Prettier per project

## On-demand reading

Files in `docs/ai/` should be read according to the task type. Do not read all of them automatically — load only the relevant ones.

| Task type | Document(s) to read |
|---|---|
| Architecture, boundaries, DI, config, or dependencies | `docs/ai/ARCHITECTURE.md` |
| Endpoint, status code, schema, OpenAPI, pagination, or HTTP contract | `docs/ai/API_GUIDE.md` |
| Models, migrations, indexes, constraints, or queries | `docs/ai/DATABASE_GUIDE.md` |
| Auth, authorization, secrets, PII, rate limit, or sensitive validation | `docs/ai/SECURITY_GUIDE.md` |
| Logs, metrics, tracing, healthcheck, or incidents | `docs/ai/OBSERVABILITY_GUIDE.md` |
| Scale, concurrency, backend performance, queues, cache, pool, load, or critical production | `docs/ai/SCALABILITY_GUIDE.md` |
| Deploy, env vars, systemd, nginx, CI/CD, release, or rollback | `docs/ai/DEPLOYMENT_GUIDE.md` |
| Code, refactoring, or tests | `docs/ai/CODING_STANDARDS.md`, `docs/ai/TESTING_GUIDE.md` |
| Full feature | `docs/ai/FEATURE_GUIDE.md` + documents for affected areas |

## Current priority

1. stable API contract
2. domain isolated from framework
3. safe migrations
4. deterministic tests
5. minimal observability for production debugging
6. recoverable deploy
7. production scale without guessing bottlenecks

## Mandatory rules

- Do not change schema without a migration and a documented rollback/downgrade path.
- Do not commit secrets, tokens, dumps, real `.env`, or database credentials.
- Do not log tokens, passwords, Authorization headers, cookies, or PII without masking.
- Public functions require explicit types.
- Endpoints require predictable error contracts.
- API DTO/schema is not a domain entity.
- Domain must not import Express/Fastify/Nest, ORM, fetch/axios, or external SDKs.
- Transactions must have explicit boundaries.
- Tests must not depend on production, uncontrolled real clocks, or external networks without mocks.
- Do not create abstractions before at least one real usage exists.
- Plans that touch critical paths, growing databases, queues, or external integrations must address scale, limits, and diagnostics.

## After changes

- Run `npm run lint` when available.
- Run `npm run typecheck` when configured.
- Run `npm test` for logic, API, migrations, or regression.
- If dependencies were changed, run the project's installer/lockfile.
- Report changed files, executed commands, and actual pending items.

## Decision principle

Prefer explicit, testable, and operationally simple code. A good backend is one that fails with a diagnosable error, preserves data, and allows rollback at 3 AM.
