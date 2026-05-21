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

```markdown
## Deploy and delivery

### Delivery scope
**Includes:**
- {Item 1}
- {Item 2}

**Does not include:**
- {Excluded item 1}

### Changed files
- `path/file1.py` — {what it does}
- `path/file2.py` — {what it does}

### External dependencies
| Dependency | Version | Usage |
|-----------|---------|-------|
| {package/service} | {version} | {for what} |

### Migrations
- `alembic/versions/xxx_description.py`
  - upgrade(): {what it does}
  - downgrade(): {what it does}
  - Tested: {yes/no + how}

### Rollback
1. {Step 1 — e.g.: `alembic downgrade -1`}
2. {Step 2 — e.g.: redeploy previous version}
3. {Step 3 — e.g.: verify healthcheck}

### Deploy procedure
1. {Step 1}
2. {Step 2}
3. ...

### New env vars
| Variable | Example | Description | Required? |
|----------|---------|-------------|-----------|
| `VAR_NAME` | `example_value` | {what it controls} | yes/no |

### Breaking changes
{None OR list with details and versioning}

### Infra configuration
- **nginx**: {change or "none"}
- **systemd**: {change or "none"}
- **docker**: {change or "none"}

### Delivery acceptance criteria
- [ ] {Verifiable criterion 1}
- [ ] {Verifiable criterion 2}

### Risks and mitigations
| Risk | Probability | Mitigation |
|------|------------|------------|
| {Risk} | {high/medium/low} | {Action} |

### Required communication
- {Who needs to be notified and about what}
```
