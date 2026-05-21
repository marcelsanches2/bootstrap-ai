# /kickoff

Initializes a project from scratch: collects requirements, generates a product brief, decides on stack, and directs to the correct preset.

## When to use

- Project is an empty or nearly empty folder (only `.git`)
- User says "new project", "start from scratch", "I want to create an app"
- `/import-project-preset` detected an empty folder

**Do NOT use when** the project already has a defined stack (code files, package.json, pubspec.yaml, etc.). In those cases, use `/import-project-preset` directly.

---

## Phase 1 — Clarify Requirements

Ask **one question at a time**. Wait for the answer before proceeding. Do not propose implementation during this phase.

### Question 1 — Problem
```
What problem does this project solve? Who experiences this problem and how frequently?
```

### Question 2 — Users
```
Who are the primary users? Be specific — "solo entrepreneurs building SaaS" not "developers".
```

### Question 3 — V1 Features
```
What are the 3 most important features for version 1? In order of priority.
```

### Question 4 — Out of scope
```
What is explicitly OUT OF SCOPE for this version?
```

### Question 5 — Stack and technical constraints
```
Do you have a technical stack preference? Any constraints (deadline, budget, needs to integrate with something specific)?
```

### Question 6 — Platform
```
What platform? Web, mobile (iOS/Android), desktop, API-only, CLI?
```

### Question 7 — Success
```
What does success look like 30 days after launch? Be measurable.
```

After the 7 answers, validate with the user:

```
Requirements summary:

1. Problem: [summary]
2. Users: [summary]
3. V1 Features: [list]
4. Out of scope: [list]
5. Stack: [summary + constraints]
6. Platform: [summary]
7. Success: [summary]

Is this correct? Can I proceed to the product brief?
```

**Do not save anything until the user confirms.**

---

## Phase 2 — Product Brief

Generate `PRODUCT_BRIEF.md` in the project root with:

```markdown
# Product Brief — {{PROJECT_NAME}}

## Problem
[1 paragraph: problem, who, frequency]

## Target users
[specific description]

## V1 Features (priority)
1. [feature] — [1 sentence]
2. [feature] — [1 sentence]
3. [feature] — [1 sentence]

## Out of scope (V1)
- [item]
- [item]

## Technical stack
| Layer | Technology | Why |
|---|---|---|
| [layer] | [tech] | [1 sentence] |

## Platform
[platform(s)]

## Success criteria (30 days)
- [measurable criterion]
- [measurable criterion]

## Open questions
- [if any, otherwise "None"]
```

Also save the requirements in `.hermes/requirements.json`:

```json
{
  "project_name": "{{PROJECT_NAME}}",
  "collected_at": "[ISO timestamp]",
  "answers": {
    "problem": "...",
    "users": "...",
    "features_v1": ["...", "...", "..."],
    "out_of_scope": ["...", "..."],
    "stack_preference": "...",
    "platform": "...",
    "success_criteria": "..."
  }
}
```

---

## Phase 3 — Choose Stack

Based on the answers (especially question 5 and 6), decide the stack:

### Mapping table

| Platform | Suggested stack | Corresponding preset |
|---|---|---|
| Mobile iOS/Android | Flutter + Dart | `flutter-app` |
| Web app (frontend) | React + TypeScript + Vite | `react-web` |
| API / Backend | Node + TypeScript + Express | `node-backend` |
| API / Backend (Python) | Python + FastAPI | `python-backend` |
| Full-stack web | React frontend + Node backend | `react-web` + `node-backend` |
| Desktop | Electron (React) or Flutter desktop | depends |
| CLI | Go, Rust, or pure Python | create new |

### Decision rules

1. If the user specified a stack → use their preference
2. If not specified → suggest based on the table above
3. If there's no corresponding preset → warn that a new one will be created via `skill-creator`
4. Present the decision:

```
Decided stack: [stack]
Preset: [preset name or "will be created new"]

Has front-end? [YES/NO]
```

---

## Phase 4 — Design Phase (conditional)

**Ask:** "Does this project have a visual interface? If so, do you want to define the design system now?"

### If YES → direct to `/design-phase`

Explain the options:
1. **"I have Figma"** → `/design-phase` will extract tokens from the link
2. **"I want you to create it"** → `/design-phase` will generate a design system from scratch
3. **"Later"** → skip, can run `/design-phase` at any time

### If NO → skip to preset apply

---

## Phase 5 — Kit Apply

After design phase (or if skipped), apply the preset:

```bash
# If the preset exists
[BOOTSTRAP_AI_DIR]/bin/bootstrap-ai apply [preset-name] [project-dir] --project-name "[PROJECT_NAME]"

# If it doesn't exist, create first
[BOOTSTRAP_AI_DIR]/bin/bootstrap-ai create [preset-name] --from "[stack description]"
[BOOTSTRAP_AI_DIR]/bin/bootstrap-ai apply [preset-name] [project-dir] --project-name "[PROJECT_NAME]"
```

---

## Final summary

After everything is complete, show:

```
Project initialized: {{PROJECT_NAME}}
────────────────────────────────
Product Brief: PRODUCT_BRIEF.md
Requirements: .hermes/requirements.json
Applied preset: [preset-name]
Design system: [YES - docs/ai/DESIGN_SYSTEM.md | NO]

Next steps:
1. /plan — create first technical plan
2. /jarvis-plan — generate plan with built-in perspectives (manual)
3. Implement plan
4. /ship — delivery checklist
```

## Pitfalls

- Do not skip questions. 7 questions, all answered.
- Do not propose a technical solution during clarify. Redirect: "Let's finish requirements first."
- If the user can't answer, mark as `[OPEN QUESTION: ...]` — do not invent.
- Do not create a new preset without first checking if an existing one fits. Use `analyze` to confirm.
- Existing DESIGN_SYSTEM.md (from design phase) should NOT be overwritten by the generic preset.
