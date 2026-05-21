# derive-docs-ai.md

Generate the guides in `docs/ai/` with content **specific to the stack** — not generic templates.

## Input

- **Stack**: `{{DESCRIPTION}}`
- **Preset name**: `{{PRESET_NAME}}`
- **Type**: backend / frontend / mobile (infer from description)

## MANDATORY Reference

Read the docs/ai of existing presets **before** generating. Use them as the quality bar:

- `presets/python-backend/docs/ai/` — backend with API, DB, security, observability, scalability
- `presets/react-web/docs/ai/` — frontend with design system, accessibility, performance
- `presets/node-backend/docs/ai/` — same pattern as python-backend adapted for Node/TypeScript
- `presets/flutter-app/docs/ai/` — mobile with feature guide, design system

**The quality bar = existing presets.** If the content you generate is shorter or more generic than what exists in those presets, you failed.

## Rule #1: Stack-specific, not generic

**BAD (generic):**
```markdown
## Naming
- Use descriptive names for variables.
- Functions should have verbal names.
```

**GOOD (stack-specific):**
```markdown
## Naming
- Controllers: `<Resource>Controller` (`UserController`, `OrderController`)
- Services: `<Resource>Service` with verbal methods (`findMany`, `create`, `update`)
- Repositories: `<Resource>Repository` — never use `*Impl` or `*DAO`
- Prisma entities: PascalCase in schema, camelCase in queries
- DTOs: `<Resource>CreateDTO`, `<Resource>UpdateDTO` — never reuse create DTO for update
```

**Every section should mention:**
- Stack-specific tools (Prisma, SQLAlchemy, Riverpod, etc.)
- Specific commands (not "run the tests", but `pytest --cov=src -x`)
- Named anti-patterns (`N+1 in Prisma`, `god widget`, `setState cascade`)
- Specific file conventions (`<feature>/`, `use_case/`, `repository/`)

## Mandatory guides (all stacks)

### ARCHITECTURE.md (~100-150 lines)

Stack directory structure with:
- Architecture overview (layers, boundaries)
- **Real directory tree** with description of each folder (e.g.: `controllers/`, `services/`, `repositories/`)
- Layers and responsibilities with examples of where each thing lives
- Data flow (request → middleware → controller → service → repository → DB)
- **Stack-specific** dependency injection patterns (DI container, constructor injection, provider pattern)
- File and folder naming conventions
- Anti-patterns with examples of what NOT to do

### CODING_STANDARDS.md (~80-120 lines)

Code standards with:
- Linting and formatting: **real tool + config** (e.g.: `ruff.toml`, `.eslintrc`, `analysis_options.yaml`)
- Typing: specific conventions (e.g.: `strict=True` in mypy, `noUncheckedIndexedAccess` in tsconfig)
- Naming with examples **by artifact type** (controller, service, model, DTO, test, etc.)
- Error handling: **stack-specific pattern** (e.g.: custom error classes, error middleware, Result type)
- Logging: **library + format** (e.g.: structlog, winston, logger.setLevel)
- Comments: what to document and what not to document
- Imports: order, aliasing, barrel exports
- Stack-specific prohibitions (e.g.: "never use `any` in TypeScript", "never use `setState` with callback in Flutter")

### TESTING_GUIDE.md (~80-120 lines)

Testing standards with:
- **Test framework + exact command** (`pytest -x --cov`, `flutter test --coverage`, `vitest run`)
- Test directory structure (co-location vs mirror)
- Naming conventions (test files, describe blocks, test names)
- **Stack-specific** fixtures/factories/mocks (e.g.: `factory_boy`, `msw`, `mocktail`)
- Minimum expected coverage and how to measure it
- What to test per layer (unit → integration → E2E)
- Stack-specific test anti-patterns
- **Separation of concerns**: this is the ONLY guide that talks about testing. No other guide should have testing sections.

## Guides by stack type

### Backend (generate ALL)

- **API_GUIDE.md** (~80-120 lines): REST conventions, versioning, payload, status codes, pagination, errors, auto-documentation (Swagger/OpenAPI), rate limiting — all with stack examples
- **DATABASE_GUIDE.md** (~80-120 lines): **specific** ORM/query builder (Prisma, SQLAlchemy, TypeORM), migrations, indexes, N+1, transactions, constraints, seeds, connections/pool — with real commands
- **SECURITY_GUIDE.md** (~60-100 lines): auth (JWT/session/OAuth), authorization (RBAC/ABAC), PII, encryption, input validation, CORS, headers, secrets management — with stack libraries
- **OBSERVABILITY_GUIDE.md** (~60-100 lines): structured logging **with real library**, metrics, healthcheck endpoint, tracing, alerts, incident response
- **SCALABILITY_GUIDE.md** (~80-120 lines): concurrency (async/worker), cache (Redis/Memcached), queues, rate limiting, connection pool, bulkhead, circuit breaker, graceful shutdown — all stack-specific
- **DEPLOYMENT_GUIDE.md** (~60-80 lines): env vars, build, deploy, rollback, healthcheck, monitoring — with real tools

### Frontend (generate ALL)

- **DESIGN_SYSTEM.md** (~80-120 lines): tokens (colors, typography, spacing), components, themes, states, responsiveness, iconography — with the stack's CSS/component library
- **ACCESSIBILITY_GUIDE.md** (~60-100 lines): semantics, ARIA, contrast, keyboard, screen readers, forms — with testing tools (axe, lighthouse)
- **PERFORMANCE_GUIDE.md** (~60-100 lines): bundle analysis, code splitting, lazy loading, images, cache, Web Vitals — with real stack tools
- **DEPLOYMENT_GUIDE.md** (~60-80 lines): build, env vars, CDN, rollback, preview deploy

### Mobile (generate ALL)

- **DESIGN_SYSTEM.md** (~80-120 lines): tokens, components, themes, states, platforms (iOS/Android)
- **FEATURE_GUIDE.md** (~80-100 lines): feature-first, clean architecture, DI, state management, navigation — with specific lib (Riverpod, BLoC, etc.)

## Quality rules

1. **Every section must mention real stack tools/libraries** — never "test framework", but "pytest with factory_boy fixtures"
2. **Include exact commands** — not "run the tests", but `pytest --cov=src --cov-report=term-missing -x`
3. **Include anti-patterns with "Don't do X, do Y"** — stack-specific
4. **Minimum 60 lines per guide, ideally 80-120** — if it's shorter than the reference presets, it's incomplete
5. **No guide other than TESTING_GUIDE should talk about testing** — separation of concerns
6. **Use `{{PROJECT_NAME}}`** where the project name is referenced
