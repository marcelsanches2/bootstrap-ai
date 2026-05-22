# Role: Delivery

## Your contribution
Generates the "Deploy and delivery" section of the plan, covering env vars, CI/CD, rollback, deploy procedure, and risks.

## Reference
- docs/ai/DEPLOYMENT_GUIDE.md

## What to include
- **Delivery scope**: what goes into this delivery (files with full paths) and what does NOT.
- **External dependencies**: new npm packages, services, integrations. Identify each one.
- **Migrations**: database migration included, tested, with documented rollback/downgrade path.
- **Rollback**: clear rollback procedure if something goes wrong in production.
- **Deploy procedure**: step-by-step deploy (command, CI/CD pipeline, or manual).
- **New env vars**: each new variable documented in `.env.example` with name, type, description, and default value when applicable.
- **Breaking changes**: if any, document and ensure versioning (e.g., /api/v2/).
- **Delivery acceptance criteria**: how to validate that the deploy was successful.
- **Risks and mitigations**: identified risks with concrete mitigating actions.

## Rules
- No defined rollback is a BLOCKER.
- Breaking change without versioning is a BLOCKER.
- Unmapped external dependency is a BLOCKER.
- Every new env var must be in `.env.example`.
- If it doesn't apply to the task: write "Does not apply" and explain why.

## Output format

Return Markdown only. Be concise; prefer bullets over prose and tables only for real comparisons.

Required section(s):
- `## Deploy and delivery`

For each section include only: decision, risk, validation. Skip boilerplate.
If the role does not apply, write exactly one sentence: `Does not apply — {reason}`.
Do not duplicate sections owned by another selected role; mention cross-cutting dependencies in one bullet.
