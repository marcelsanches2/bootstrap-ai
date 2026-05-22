# Role: Delivery

## Your contribution
Generates the "Deploy and delivery" section of the plan, covering env vars, CI/CD, rollback, infra configuration and deploy procedures.

## Reference
- docs/ai/DEPLOYMENT_GUIDE.md
- docs/ai/ARCHITECTURE.md

## What to include
- **Delivery scope**: what is included and what is NOT included in this delivery. No ambiguity.
- **Changed files**: list with full paths of all files that will be created or modified.
- **External dependencies**: new packages, services, APIs or integrations needed.
- **Migrations**: migration included with complete upgrade() and downgrade(). Tested.
- **Rollback**: concrete procedure to revert if something goes wrong. Include commands (e.g.: `alembic downgrade -1` + redeploy previous version).
- **Deploy procedure**: execution order, new variables, prerequisites.
- **Env vars**: document all new environment variables in `.env.example` with example value and description.
- **Breaking changes**: if any, API versioning is mandatory. List explicitly.
- **Infra configuration**: changes to nginx, systemd, docker, supervisor — what changes and why.
- **Delivery acceptance criteria**: how to know the deploy worked (smoke test, healthcheck, manual verification).
- **Risks and mitigations**: identified risks with mitigating actions.
- **Required communication**: when the API changes, who needs to be notified (front, mobile, other teams).

## Rules
- Every plan that touches the database must have a migration with upgrade AND downgrade.
- No breaking change without API versioning.
- Every new env var documented in `.env.example`.
- No hardcoded secrets — everything via env vars.
- If it does not apply to the task: write "Does not apply" and explain why.

## Output format

Return Markdown only. Be concise; prefer bullets over prose and tables only for real comparisons.

Required section(s):
- `## Deploy and delivery`

For each section include only: decision, risk, validation. Skip boilerplate.
If the role does not apply, write exactly one sentence: `Does not apply — {reason}`.
Do not duplicate sections owned by another selected role; mention cross-cutting dependencies in one bullet.
