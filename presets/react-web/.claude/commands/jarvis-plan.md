---
name: jarvis-plan
description: Unified planning — explores codebase, grills if necessary, generates technical plan with all perspectives embedded for React web. One LLM pass.
---

# /jarvis-plan

Generate the definitive technical plan for the task, with all perspectives embedded from the start.

Do not execute implementation. Do not alter production code. Only plan.

## Sequence

---

## 1. Understand the task

Read the available context:

- `CLAUDE.md` — project contract, structure, conventions
- `PRODUCT_BRIEF.md` — if it exists, domain terms and entities
- The task described by the user
- Explore the relevant codebase (components, hooks, routes, existing tests)

**If the task is ambiguous** — activate the grill (step 2).
**If the task is clear** — skip directly to step 3.

---

## 2. Integrated grill (conditional)

Activate ONLY when the task has:

- New feature without clear specification
- Multiple viable approaches with real trade-offs
- Ambiguous terms that the codebase doesn't resolve
- Irreversible architecture decision

**Grill rules:**

- **ONE question at a time. Ask the question and STOP. Your response must be ONLY the question — no prologue, no additional explanation. Wait for the user to answer before continuing.**
- Each question with: recommendation + why + alternative.
- Maximum 7 questions. If you need more, the task is too large — suggest breaking it down.
- If the answer is in the codebase, search instead of asking.
- Challenge vague terms, test edge cases, compare with what exists.
- Suggest ADR when: hard to reverse + surprising + real trade-off.

**When the grill is finished, generate a summary in table format:**

```md
| Decision | Choice | Reason |
|---------|--------|--------|
| ...     | ...    | ...    |
```

---

## 3. Select contributors

Select the roles relevant to the task. None are mandatory.

| Task condition | Role |
|---|---|
| Scope, requirements, acceptance criteria, product impact | `product_roles/role-pm.md` |
| Structure, layers, dependencies, architecture decision | `product_roles/role-architect.md` |
| UI, screen, visual component, layout, design system, token, color, typography | `product_roles/role-designer.md` |
| Component, hook, context, provider, store, state, route, page | `product_roles/role-frontend-architect.md` |
| Accessibility, keyboard, focus, semantics, ARIA, screen reader | `product_roles/review-accessibility.md` |
| Bundle, rendering, images, Web Vitals, lazy loading, memo | `product_roles/review-performance.md` |
| Testable flow, integration, state, data fetching, business logic | `product_roles/role-web-qa.md` |
| Deploy, env, build, cache, CI/CD, release, rollback | `product_roles/role-delivery.md` |

**If no condition applies** (e.g.: simple infra/config task), generate the plan without roles.

---

## 4. Generate plan with contributions

For each selected role:

1. Read the role file
2. Consult the references listed in the role
3. Generate the section according to the role's "Output format"
4. If the role says "Does not apply", include the section with justification

**Plan assembly:**

- Respect the order: PM → Architect → Stack-specific → Domain reviews → QA → Delivery
- Deduplicate: if architect and QA both mention tests, QA becomes the owner of the test section
- Each section with a clear heading, no overlap

---

## 5. Blocking rules

Consult the `## Blocking rules` section of the guides referenced by the selected roles (step 3). The plan CANNOT be proposed if it violates any rule listed as blocking in those guides.

**Universal rule:** the plan must have product behavior, not just a list of files/classes.

If any rule is violated, fix the plan before presenting it.

---

## 6. Mandatory final format

```md
# Plan: {title}

Date: {YYYY-MM-DD}

## Objective
{What it solves, for whom, expected behavior}

## Scope / Out of scope
{Included} / {Excluded}

## Acceptance criteria
- [ ] {verifiable}

## Architecture
{Architect section}

## {Sections from selected roles}

## Tests
{QA section}

## Incremental plan
1. **Step N — {title}**: {description}. Files: {list}. Validation: {how to verify}.

## References
- `docs/ai/{file}` — {why}
```

---

## 7. Save and await approval — INTERACTIVE MODE

1. Save the plan in `plans/YYYY-MM-DD-{slug}.md`
2. Present the plan to the user
3. **STOP.** Your last line must be EXACTLY a question: **"Plan approved? Reply 'yes' to implement or request adjustments."**
4. Do not proceed to implementation. Do not generate code. Do nothing else until the user responds.
5. If the user requests adjustments, update the plan, save it, and ask the question again.

---

## Rules

- One LLM pass — no draft followed by review.
- If information is missing, ask (grill) before assuming.
- Do not implement. Do not create production files.
