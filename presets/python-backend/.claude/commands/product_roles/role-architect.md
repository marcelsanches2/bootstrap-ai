# Role: Architect

## Your contribution
Generates the "Proposed architecture" section and the "Incremental plan" of the plan, defining layers, dependencies, dependency injection, configuration and directory structure.

## Reference
- docs/ai/ARCHITECTURE.md

## What to include
- **Boundaries**: describe the separation of responsibilities between layers (API/router, domain/service, data/repository, infra). Indicate which responsibilities belong in each layer and why.
- **Dependency direction**: show that dependencies point inward (domain does not depend on external details). Identify points where this could be violated.
- **Names and structure**: propose file, module and class names that clearly indicate their responsibility. Avoid generic names like `utils.py` or `helpers.py`.
- **Pragmatic extensibility**: explain how the solution allows growing for the next likely case without premature abstraction. No parallel framework or abstraction without real use.
- **Technical validation**: indicate which forms of validation (test, build, lint) are coherent with the risk of the change.
- **Incremental plan**: list the implementation steps in order, indicating dependencies between them. Each step must be independently implementable and testable on its own.

## Rules
- No layer may skip another (e.g.: router does not access database directly).
- Domain never imports framework, ORM, HTTP client or external SDK.
- Do not create abstraction before at least one real use exists.
- Configuration via Settings (pydantic-settings), never hardcoded.
- Transactions must have explicit boundaries.
- If it does not apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## Proposed architecture

### Layers
| Layer | Responsibility | Examples |
|-------|---------------|----------|
| API/Router | Receives HTTP, validates edge, calls service, returns response | routers/*.py |
| Service/Domain | Business logic, orchestration, transactions | services/*.py |
| Repository/Data | Queries, database access, ORM mapping | repositories/*.py |
| Infra | Config, DI, logging, external clients | core/, dependencies.py |
| Models | Table definitions, no logic | models/*.py |
| Schemas | Pydantic contracts (request/response), separated from models | schemas/*.py |

### Dependencies (direction)
{Diagram or textual list showing that dependencies point inward}

### Dependency injection
{How dependencies are injected: constructors, FastAPI Depends, factories}

### Configuration
{Which Settings, env vars, how it is loaded}

### Directory structure
```
app/
├── core/
├── models/
├── schemas/
├── repositories/
├── services/
├── routers/
└── dependencies.py
```

## Incremental plan

### Step 1: {name}
- **What**: {description}
- **Files**: {list}
- **Validation**: {how to test}

### Step 2: {name}
- **Depends on**: Step 1
- **What**: {description}
- **Files**: {list}
- **Validation**: {how to test}

{... subsequent steps}
```
