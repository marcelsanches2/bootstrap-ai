---
name: jarvis-plan
description: Unified planning — explores codebase, grills if necessary, generates technical plan with all perspectives built in. One LLM pass.
---

# /jarvis-plan

Generate the definitive technical plan for the task, with all perspectives built in from the start.

Do not execute implementation. Do not modify production code. Only plan.

## Sequence

---

## 1. Understand the task

Read the available context:

- `CLAUDE.md` — project contract, structure, conventions
- `PRODUCT_BRIEF.md` — if it exists, domain terms and entities
- The task described by the user
- Explore the relevant codebase (models, services, routes, existing tests)

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
- Maximum 7 questions. If you need more, the task is too big — suggest breaking it down.
- If the answer is in the codebase, search instead of asking.
- Challenge vague terms, test edge cases, compare with what exists.
- Suggest ADR when: hard to reverse + surprising + real trade-off.

**When the grill is finished, generate a summary in table format:**

```md
| Decision | Choice | Reason |
|----------|--------|--------|
| ...      | ...    | ...    |
```

---

## 3. Select contributors

Select the roles relevant to the task. None are mandatory.

| Task condition | Role |
|---|---|
| Scope, requirements, acceptance criteria, product impact | `product_roles/role-pm.md` |
| Structure, layers, dependencies, architectural decision | `product_roles/role-architect.md` |
| UI, screen, visual component, layout, design system, token | `product_roles/role-designer.md` |
| Testable flow, use case, business rule, state | `product_roles/role-flutter-qa.md` |

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
- Deduplicate: if architect and QA both mention tests, QA becomes the owner of the tests section
- Each section with a clear heading, no overlap

---

## 5. Blocking rules

Check the `## Blocking rules` section of the guides referenced by the selected roles (step 3). The plan MUST NOT be proposed if it violates any rule listed as blocking in those guides.

**Universal rule:** the plan must have product behavior, not just a list of files/classes.

If any rule is violated, correct the plan before presenting.

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
{Architect's section}

## {Sections from selected roles}

## Tests
{QA's section}

## Incremental plan
1. **Step N — {title}**: {description}. Files: {list}. Validation: {how to verify}.

## References
- `docs/ai/{file}` — {why}
```

---

## 7. Save and await approval — INTERACTIVE MODE

1. Save the plan in `plans/YYYY-MM-DD-{slug}.md`
2. Present the plan to the user
3. **STOP.** Your last line must be EXACTLY a question: **"Plan approved? Answer 'yes' to implement or request adjustments."**
4. Do not proceed to implementation. Do not generate code. Do nothing else until the user responds.
5. If the user requests adjustments, update the plan, save and ask the question again.

---

## Rules

- One LLM pass — no draft followed by review.
- If information is missing, ask (grill) before assuming.
- Do not implement. Do not create production files.
