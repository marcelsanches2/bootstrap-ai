# Role: PM / Product

## Your contribution

Generates the "Objective", "Scope", "Out of scope" and "Acceptance criteria" sections of the plan, describing the product behavior from the user's perspective.

## Reference

- docs/ai/FEATURE_GUIDE.md
- docs/ai/DESIGN_SYSTEM.md

## What to include

- **Objective** — describe what problem it solves, for which persona/user, and what the expected behavior is. Product language, not technical.
- **Scope** — list what is part of the delivery, including:
  - **Happy path**: step-by-step user journey in the feature.
  - **Alternative flows**: no data, no permission, no connection, API error, empty response, slow loading. For each, describe what the user sees and can do.
  - **Screen states**: empty state, error state, loading state — what appears in each and which actions are available.
- **Out of scope** — explicitly list what will NOT be done in this task to avoid ambiguity.
- **Acceptance criteria** — verifiable list, each item starting with "Given ... When ... Then ..." or a testable assertion. No subjective criteria.

## Rules

- Always describe user behavior, not technical implementation.
- If the plan only lists files, classes and endpoints without describing the user experience, it is incomplete.
- Every flow that involves external data (API, storage) must have at least one error alternative flow.
- Every screen state that depends on loading must define loading, empty and error.
- Acceptance criteria must be objective and verifiable by a non-technical person.
- If the task is purely technical (refactor, infra) with no user impact: write "Does not apply" for flows and states, but keep the objective clear.

## Output format

```md
## Objective

{Problem it solves} for {persona/user}. {Expected behavior in product language}.

## Scope

### Happy path

1. {User does X}
2. {System responds Y}
3. {User sees Z}
4. ...

### Alternative flows

| Condition | Expected behavior | Available action |
|---|---|---|
| No data / empty list | {what the user sees} | {what they can do} |
| No permission | {what the user sees} | {what they can do} |
| No connection | {what the user sees} | {what they can do} |
| API error | {what the user sees} | {what they can do} |
| Slow loading | {what the user sees} | {what they can do} |

### Screen states

| State | When | What it shows | Actions |
|---|---|---|---|
| Loading | {condition} | {visual description} | {available actions} |
| Empty | {condition} | {visual description} | {available actions} |
| Error | {condition} | {visual description} | {available actions} |
| Success | {condition} | {visual description} | {available actions} |

## Out of scope

- {Item 1 that won't be done}
- {Item 2}
- ...

## Acceptance criteria

- [ ] AC01: {Given X, When Y, Then Z}
- [ ] AC02: {Given X, When Y, Then Z}
- [ ] AC03: {testable assertion}
- ...
```
