# derive-roles.md

Generate the review roles in `.claude/commands/product_roles/` specific to the stack.

## Input

- **Stack**: `{{DESCRIPTION}}`
- **Preset name**: `{{PRESET_NAME}}`
- **Type**: backend / frontend / mobile (infer from description)

## Reference

Read the roles from existing presets before generating:

- `presets/python-backend/.claude/commands/product_roles/role-*.md` — complete backend
- `presets/react-web/.claude/commands/product_roles/role-*.md` — complete frontend
- `presets/node-backend/.claude/commands/product_roles/role-*.md` — Node backend
- `presets/flutter-app/.claude/commands/product_roles/role-*.md` — Flutter mobile
- Most similar preset — generic roles (copy directly from preset)

## Naming convention

| Type | Prefix | Examples |
|---|---|---|
| Person who reviews | `role-` | `role-architect.md`, `role-pm.md`, `role-designer.md`, `role-delivery.md` |
| Person + stack | `role-<stack>-` | `role-flutter-qa.md`, `role-web-qa.md`, `role-api-qa.md` |
| Technical perspective | `review-` | `review-database.md`, `review-api.md`, `review-security.md` |

Always in English. Always kebab-case. Each file ~40-50 lines (objective + checklist + hard rule, NO Input/Method/Output boilerplate).

## Generic roles (copy from most similar preset, do not rewrite)

- `role-architect.md`
- `role-pm.md`
- `role-delivery.md`

## Generic reviews (copy from most similar preset when applicable)

- Backend: `review-api.md`, `review-database.md`, `review-security.md`, `review-observability.md`, `review-scalability.md`
- Frontend: `review-accessibility.md`, `review-performance.md`
- All: `review-testing.md`

## Specific roles (create for the stack)

Delivery perspective:
- Objective: validate that the plan is implementable without surprises
- Checklist: clear scope, dependencies, risks, rollback, deploy
- Hard rule: plan without rollback or without considering deploy is not ready

## Roles by stack type

### Backend (generate ALL)

#### review-api.md (~80+ lines)
- HTTP contract (verb, path, payload, response, status codes)
- Input validation
- Pagination and sorting
- Versioning
- Consistent error handling
- Auto-documentation

#### role-<stack>-architect.md (~100+ lines)
- Layer separation (router/controller → service → repository/data)
- Dependency injection
- Error handling per layer
- Config and env vars
- Typing/contracts between layers
- Stack-specific anti-patterns

#### review-database.md (~80+ lines)
- Migrations (up/down, rollback)
- Indexes on search columns
- N+1, SELECT *, query optimization
- Constraints and integrity
- Connections, pool, timeouts
- Seeds and initial data

#### review-security.md (~80+ lines)
- Auth and authorization
- Sensitive data (PII, secrets, tokens)
- Input validation and sanitization
- Rate limiting
- Security headers
- Logs without sensitive data

#### review-observability.md (~80+ lines)
- Structured logging
- Metrics (latency, throughput, error rate)
- Healthcheck endpoints
- Tracing and correlation IDs
- Alerts and thresholds

#### review-scalability.md (~100+ lines)
- Concurrency and race conditions
- Cache and invalidation
- Queues and jobs (retry, DLQ, backpressure)
- Rate limit, timeout, bulkhead, circuit breaker
- Connection pools
- Graceful shutdown

#### review-api-qa.md (~80+ lines)
- Plan testability
- Happy path
- Negative scenarios (error 400, 401, 403, 404, 500)
- Deterministic test data
- API contract (integration tests)
- Edge cases

### Frontend (generate ALL)

#### role-frontend-architect.md (~100+ lines)
- Componentization and composition
- Hooks/services for logic
- State (local vs global, scope)
- Centralized routing
- Error boundaries
- Code splitting and lazy loading

#### role-designer.md (~80+ lines)
- Design system / tokens
- Visual fidelity
- Visual states (loading, error, empty, disabled)
- Responsiveness
- Visual componentization

#### review-accessibility.md (~80+ lines)
- HTML semantics
- Keyboard navigation
- Contrast and colors
- Forms (labels, association, errors)
- ARIA attributes

#### review-performance.md (~80+ lines)
- Bundle size and code splitting
- Rendering (memo, virtualization, rerenders)
- Images and assets
- Data cache and invalidation
- Web Vitals

#### role-web-qa.md (~80+ lines)
- Testability
- Happy path via UI
- Negative scenarios
- Responsiveness
- Accessibility

### Mobile (generate ALL)

#### role-architect.md (~100+ lines)
- Feature-first + clean architecture
- presentation/domain/data separation
- DI and providers
- Centralized navigation
- Mocks and overrides

#### role-designer.md (~80+ lines)
- Design system / tokens
- Visual fidelity
- Visual states
- Platforms (iOS/Android)

#### role-qa-e2e-<stack>.md (~80+ lines)
- Integration test
- Deterministic mocks
- Happy path
- Negative scenarios
- Test data

## Mandatory format for each role

```md
# role-<name>

## Objective
<1 sentence>

## Reference source
- `docs/ai/<GUIDE>.md`

## Expected input
<what the role needs to receive to review>

## Method
<how the role evaluates>

## Mandatory checklist
- [ ] Item 1 — description
- [ ] Item 2 — description
...

## Expected result per item
For each checklist item:
- **OK**: evidence of compliance
- **OK — not applicable**: why it doesn't apply
- **PENDING (severity, evidence, concrete correction)**

## Output in Markdown
<report format>

## Hard rule
<one restriction that rejects the plan if violated>
```

## Quality rules

- Each role must have at least 80 lines.
- Checklist with at least 8 items.
- Reference to specific docs/ai, not generic.
- Concrete stack examples, not abstractions.
