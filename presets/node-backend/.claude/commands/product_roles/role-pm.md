# Role: Product Manager

## Your contribution
Generates the "Objective", "Scope", "Out of scope", and "Acceptance criteria" sections of the plan, describing user-observable behavior in business language.

## Reference
- docs/ai/FEATURE_GUIDE.md

## What to include
- **Objective**: one clear sentence in business language about what the feature solves and for whom.
- **Scope**:
  - Main flow (happy path) documented step by step.
  - Alternative flows (e.g., cancellation, editing, retry).
  - Error states documented (duplicate, insufficient, timeout, not found).
  - Loading states considered.
  - Empty states considered (empty list, no results).
- **Out of scope**: explicitly list everything that will NOT be done in this delivery. Avoid ambiguity between dev and PM.
- **Impact on existing features**: assess what changes in features already in production.
- **Acceptance criteria**: explicit and testable list. Each criterion must be verifiable by a human or automated test. Include test data / required fixtures.

## Rules
- Main flow must be described. Without it the plan is incomplete (BLOCKER).
- Acceptance criteria must be unambiguous — no subjective language (BLOCKER).
- If it doesn't apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## Objective
{1–2 sentences: what it solves, for whom, what value}

## Scope

### Main flow
1. {step}
2. {step}
3. {step}

### Alternative flows
- {scenario}: {behavior}
- {scenario}: {behavior}

### Error states
- {error}: {behavior / message}
- {error}: {behavior / message}

### Loading states
- {where}: {behavior}

### Empty states
- {where}: {behavior}

### Impact on existing features
- {feature}: {what changes}

## Out of scope
- {item 1}
- {item 2}

## Acceptance criteria
- [ ] {testable criterion 1}
- [ ] {testable criterion 2}
- [ ] {testable criterion 3}

### Test data
- {fixtures needed to validate the criteria}
```
