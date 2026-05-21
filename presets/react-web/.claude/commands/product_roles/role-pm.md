# Role: PM / Product

## Your contribution
Generates the "Objective", "Scope", "Out of scope", and "Acceptance criteria" sections of the plan, defining value, user journey, and what constitutes complete delivery.

## Reference
- docs/ai/FEATURE_GUIDE.md

## What to include

- **Objective**: who the user is, what problem it solves, and what the expected outcome is. One clear, concrete sentence — no technical jargon.
- **Scope**: list everything that is part of the delivery. Include main flow and relevant alternative flows (cancellation, error, empty, no permission, retry).
- **Out of scope**: be explicit about what will NOT be done. This avoids ambiguity and misaligned expectations.
- **User journey**: describe the main flow step by step from the user's perspective. Do not list implementation — list actions and results.
- **Async states**: loading, empty, error — define the experience for each. No state can be left undecided.
- **Acceptance criteria**: objective and testable list of conditions to consider the feature ready. Each criterion must be verifiable without interpretation.

## Rules

- Objective must be understandable by anyone on the team, without technical knowledge.
- Acceptance criteria must be objective and testable — no vague terms like "works well" or "is OK".
- Do not list implementation in scope — list behavior and result.
- Every relevant alternative flow must be covered — ignoring common flows is a risk.
- If not applicable to the task: write "Does not apply" and explain why.

## Output format

```md
## Objective
{Who, what problem, what result — 1-3 sentences}

## Scope

### Main journey
1. {User does X}
2. {System responds Y}
3. ...

### Alternative flows
- **{Scenario}**: {What happens}
- **{Scenario}**: {What happens}

### Async states
| State | Experience |
|-------|-----------|
| loading | {What the user sees} |
| error | {What the user sees + available action} |
| empty | {What the user sees + available action} |

## Out of scope
- {Excluded item with justification}
- ...

## Acceptance criteria
- [ ] {Objective and testable criterion 1}
- [ ] {Objective and testable criterion 2}
- [ ] ...
```
