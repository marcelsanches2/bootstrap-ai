# Role: Backend Architect

## Your contribution
Complements the architecture with specific Python patterns: Router → Service → Repository → Model layer, dependency injection, async/sync, FastAPI patterns and structural conventions.

## Reference
- docs/ai/ARCHITECTURE.md
- docs/ai/CODING_STANDARDS.md

## What to include
- **Layer separation**: detail what each layer does — Router (only receives HTTP, calls service, returns response), Service (business logic, no HTTP), Repository (only queries, no business logic), Model (table definition, no logic).
- **Dependency injection**: how services receive dependencies in the constructor, how repositories receive session, how routers inject via `Depends()`. Everything centralized in `dependencies.py`.
- **Async/sync**: specify where to use async (all IO operations: database, HTTP, file) and where sync is acceptable (pure CPU-bound in background). Never block the event loop.
- **Schemas vs Models**: Pydantic v2 for request/response schemas, separated from SQLAlchemy models. No sensitive fields in response schema.
- **Imports and naming**: order stdlib → third-party → local. snake_case for files and functions, PascalCase for classes. `TYPE_CHECKING` to avoid circular imports.
- **Config via Settings**: pydantic-settings for all configuration. Never hardcoded.
- **Transactions**: explicit boundary. Repository never calls commit/rollback — delegated to the service.

## Rules
- Router does not contain business logic nor accesses models/database directly.
- Service does not know HTTP (no Request/Response/status codes).
- Model does not contain business logic.
- No circular imports (use `TYPE_CHECKING`).
- No sync in async context for IO.
- If it does not apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## Backend Patterns

### Layer separation
{Describe the Router → Service → Repository → Model flow for each relevant endpoint/flow}

### Dependency injection
```python
# dependencies.py
def get_repository(session: AsyncSession = Depends(get_session)) -> Repository:
    ...

def get_service(repo: Repository = Depends(get_repository)) -> Service:
    ...
```

### Async/sync
| Operation | Pattern | Example |
|-----------|---------|---------|
| Database | async + AsyncSession | `await session.execute(...)` |
| External HTTP | async + httpx.AsyncClient | `async with httpx.AsyncClient() as client:` |
| Local file | sync or aiofiles | depending on volume |
| CPU-bound | run_in_executor | for heavy processing |

### Schemas (Pydantic v2)
{List request and response schemas for each endpoint, with types, validation and examples}

### Naming and imports
{Specific conventions for new files}

### Transactions
{How to delimit transactions in each flow — where it starts, where it commits, where it rolls back}
```
