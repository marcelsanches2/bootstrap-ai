# CLAUDE.md

Main contract for Claude Code in this Python backend.

## Project

{{PROJECT_NAME}} is a Python backend for APIs and domain services, focused on simple architecture, explicit contracts, operational security, and incremental evolution.

Default stack:

- Python 3.12+
- FastAPI when there is an HTTP API
- Pydantic v2 for schemas and edge validation
- SQLAlchemy 2.x for persistence
- Alembic for migrations
- PostgreSQL in production; SQLite only for development/tests when appropriate
- pytest for tests
- ruff for lint/format
- mypy when configured

## On-demand reading

The files in `docs/ai/` should be read according to the task type. Do not read them all automatically — load only the relevant ones.

| Task type | Document(s) to read |
|---|---|
| Architecture, boundaries, DI, config or dependencies | `docs/ai/ARCHITECTURE.md` |
| Endpoint, status code, schema, OpenAPI, pagination or HTTP contract | `docs/ai/API_GUIDE.md` |
| Models, migrations, indexes, constraints or queries | `docs/ai/DATABASE_GUIDE.md` |
| Auth, authorization, secrets, PII, rate limit or sensitive validation | `docs/ai/SECURITY_GUIDE.md` |
| Logs, metrics, tracing, healthcheck or incidents | `docs/ai/OBSERVABILITY_GUIDE.md` |
| Scale, concurrency, backend performance, queues, cache, pool, load or critical production | `docs/ai/SCALABILITY_GUIDE.md` |
| Deploy, env vars, systemd, nginx, CI/CD, release or rollback | `docs/ai/DEPLOYMENT_GUIDE.md` |
| Code, refactor or tests | `docs/ai/CODING_STANDARDS.md`, `docs/ai/TESTING_GUIDE.md` |
| Full feature | `docs/ai/FEATURE_GUIDE.md` + documents for affected areas |

## Current priority

1. stable API contract
2. domain isolated from framework
3. safe migrations
4. deterministic tests
5. minimum observability for production debugging
6. recoverable deploy
7. production scale without guessing bottlenecks

## Mandatory rules

- Do not change schema without migration and documented rollback/downgrade path.
- Do not commit secrets, tokens, dumps, real `.env` or database credentials.
- Do not log token, password, Authorization header, cookie or PII without masking.
- Public functions need type hints.
- Endpoints need predictable error contracts.
- API DTO/schema is not a domain entity.
- Domain does not import FastAPI, SQLAlchemy, requests/httpx, boto or external SDK.
- Transactions must have explicit boundaries.
- Tests cannot depend on production, uncontrolled real clock or external network without mock.
- Do not create abstraction before at least one real use exists.
- A plan that touches a critical path, growing database, queue or external integration must address scale, limits and diagnostics.

## After changes

- Run `ruff check .` and `ruff format --check .` when ruff exists.
- Run `mypy .` when configured.
- Run `pytest` for logic, API, migrations or regression.
- If dependencies were changed, run the project's installer/lockfile.
- Report changed files, executed commands and actual pending items.

## Decision principle

Prefer explicit, testable and operationally simple code. A good backend is one that fails with a diagnosable error, preserves data and allows rollback at 3 AM.
