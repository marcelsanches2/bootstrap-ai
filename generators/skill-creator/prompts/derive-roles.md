# derive-roles.md

Generate concise review roles in `.claude/commands/product_roles/` for the preset stack.

## Input

- **Stack**: `{{DESCRIPTION}}`
- **Preset name**: `{{PRESET_NAME}}`
- **Type**: backend / frontend / mobile / fullstack (infer from description)

## References

Read the closest existing preset before generating:

- Backend: `presets/python-backend/.claude/commands/product_roles/*.md`
- Node backend: `presets/node-backend/.claude/commands/product_roles/*.md`
- Frontend: `presets/react-web/.claude/commands/product_roles/*.md`
- Mobile: `presets/flutter-app/.claude/commands/product_roles/*.md`
- Fullstack: combine frontend + backend roles, but do not duplicate ownership

Copy generic roles from the closest preset when they already fit. Only create stack-specific roles for real differences.

## Naming

| Purpose | Prefix | Examples |
|---|---|---|
| Planning contributor | `role-` | `role-architect.md`, `role-pm.md`, `role-delivery.md` |
| Stack-specific contributor | `role-<stack>-` | `role-flutter-qa.md`, `role-web-qa.md`, `role-api-qa.md` |
| Technical review perspective | `review-` | `review-database.md`, `review-api.md`, `review-security.md` |

Always English. Always kebab-case.

## File shape

Each role/review must be lean: roughly 25–60 lines. No tutorial prose. No long output templates.

```md
# Role: {Name}

## Your contribution
{One sentence naming the plan section this file owns.}

## Reference
- docs/ai/{RELEVANT_GUIDE}.md

## What to include
- **{Decision/risk}**: {specific guidance}
- ...

## Rules
- {Blocking or absolute rule}
- If it does not apply to the task: write "Does not apply" and explain why.

## Output format
Return Markdown only. Be concise; prefer bullets over prose and tables only for real comparisons.

Required section(s):
- `## {Owned section}`

For each section include only: decision, risk, validation. Skip boilerplate.
If the role does not apply, write exactly one sentence: `Does not apply — {reason}`.
Do not duplicate sections owned by another selected role; mention cross-cutting dependencies in one bullet.
```

## Default role set by stack

### Backend

Generate:
- `role-pm.md` — objective, scope, acceptance criteria
- `role-architect.md` — global architecture and incremental plan
- `role-<stack>-architect.md` — stack-specific layers, DI, contracts, error boundaries
- `review-api.md` — HTTP contract, validation, status codes, pagination, OpenAPI
- `review-database.md` — migrations, rollback, indexes, constraints, query shape
- `review-security.md` — auth, authorization, secrets, PII, rate limit, secure logs
- `review-observability.md` — logs, metrics, healthcheck, tracing, alerts
- `review-scalability.md` — concurrency, cache, queues, timeouts, pools, backpressure
- `role-api-qa.md` — API/integration testability and edge cases
- `role-delivery.md` — deploy, env, CI/CD, rollback, migrations, release risk

### Frontend

Generate:
- `role-pm.md` — objective, scope, acceptance criteria
- `role-architect.md` — global architecture and incremental plan
- `role-frontend-architect.md` — components, hooks/services, state, routing, boundaries
- `role-designer.md` — design tokens, visual states, responsiveness, component polish
- `review-accessibility.md` — semantics, keyboard, focus, labels, contrast, ARIA
- `review-performance.md` — bundle, rendering, data cache, images, Web Vitals
- `role-web-qa.md` — UI flow testability, states, responsiveness, regression risk
- `role-delivery.md` — build, deploy, env, cache, rollback

### Mobile

Generate:
- `role-pm.md` — objective, scope, acceptance criteria
- `role-architect.md` — feature-first structure, presentation/domain/data, DI, navigation
- `role-designer.md` — design system, platform states, responsiveness/adaptive behavior
- `role-flutter-qa.md` or equivalent — widget/integration tests, mocks, navigation, platform edge cases

### Fullstack

Generate only the roles needed by the stack. Avoid duplicate QA/review files when one broader role owns the same section.

## Quality rules

- Reference specific `docs/ai` files, not generic documentation.
- Checklist items must be domain-specific; delete generic advice.
- One role owns one section. If two roles overlap, pick an owner and make the other point to the dependency.
- Do not enforce line-count padding. Concision is a quality requirement.
- Never generate placeholder text like “Item 1” or “TODO”.
