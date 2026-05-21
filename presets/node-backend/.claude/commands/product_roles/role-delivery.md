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

```markdown
## Deploy and delivery

### Changed/created files
- `{full/file/path}` — {what it does}

### External dependencies
| Package/Service | Version | Reason |
|----------------|---------|--------|
| {name} | {version} | {reason} |

### Migrations
- **Up**: {command or description}
- **Down**: {command or description}
- **Data rollback**: {how to revert if needed}

### New env vars
| Name | Type | Default | Description |
|------|------|---------|-------------|
| {NAME} | {type} | {default} | {description} |

### Deploy procedure
1. {step}
2. {step}
3. {step}

### Rollback
1. {step}
2. {step}

### Breaking changes
{None / list with versioning}

### Delivery acceptance criteria
- [ ] {criterion}
- [ ] {criterion}

### Risks and mitigations
| Risk | Probability | Mitigation |
|------|------------|-----------|
| {risk} | {high/medium/low} | {action} |
```
