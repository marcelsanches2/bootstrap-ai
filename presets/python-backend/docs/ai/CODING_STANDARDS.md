# Coding Standards

Code standards for Python backend.

## Formatting and linting

### Tools

- **Formatter**: `ruff format` (replaces black)
- **Linter**: `ruff check` (replaces flake8, isort, pyupgrade)
- **Type checker**: `mypy --strict` or `pyright`

### pyproject.toml

```toml
[tool.ruff]
target-version = "py312"
line-length = 120

[tool.ruff.lint]
select = ["E", "F", "I", "N", "UP", "B", "SIM", "C4", "DTZ", "T20", "RUF"]
ignore = ["E501"]

[tool.ruff.lint.isort]
known-first-party = ["app"]

[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
disallow_untyped_defs = true
```

### Commands

```bash
ruff check . --fix
ruff format .
mypy app/
```

Run before every commit.

## Typing

Always type public functions:

```python
async def get_user(user_id: int) -> User | None:
    ...

users: list[User] = []
config: dict[str, Any] = {}
```

Modern type hints (3.12+): `X | Y` instead of `Union[X, Y]`.

Never use `Any` without documented justification.

Use `from __future__ import annotations` for forward refs.

## Naming

| Element | Convention | Example |
|---|---|---|
| Module/file | snake_case | user_service.py |
| Class | PascalCase | UserService |
| Function/method | snake_case | create_user() |
| Constant | UPPER_SNAKE | MAX_RETRIES |
| Boolean | is_/has_/can_ | is_active, has_permission |
| Enum | PascalCase class | UserRole.admin |
| Pydantic schema | PascalCase + suffix | UserCreate, UserResponse |
| SQL table | plural snake_case | user_profiles |
| SQL column | snake_case | created_at |

## Error handling

Custom exception hierarchy:

```python
class AppError(Exception):
    def __init__(self, code: str, message: str, status: int):
        self.code = code
        self.message = message
        self.status = status

class NotFoundError(AppError):
    def __init__(self, resource: str, id: int | str):
        super().__init__(code="NOT_FOUND", message=f"{resource} not found", status=404)
```

Rules:
- Never `except Exception: pass`.
- Raise AppError for business errors.
- Log before converting to response.
- Let unexpected exceptions escape to global handler.

## Logging

Structured logging with structlog:

```python
logger = structlog.get_logger()
logger.info("user_created", user_id=user.id, email=user.email)
logger.error("payment_failed", order_id=order.id, error=str(e))
```

Levels: DEBUG (dev), INFO (business events), WARNING (recoverable anomaly), ERROR (attention), CRITICAL (inoperable).

**Never log**: passwords, tokens, PII, complete bodies in production.

## Comments

Comment the "why", not the "what".

```python
# ✓ Good: explains decision
# Pessimistic lock here due to race condition on balance (incident #123)
await session.execute(select(Account).where(...).with_for_update())

# ✗ Bad: repeats code
# select account
await session.execute(select(Account).where(...))
```

Do not comment dead code — delete and use git.

## Imports

Order: stdlib → third-party → local. Separated by blank line.

```python
from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends
from sqlalchemy import select

from app.schemas.users import UserCreate
from app.services.users import UserService
```

Rules:
- One import per line for `from ... import ...`.
- Never `from app.models import *`.
- Never circular import — use TYPE_CHECKING.

## Async

Always async for IO:

```python
result = await session.execute(query)
response = await http_client.post(url, json=data)
```

Never block the event loop:

```python
import requests  # ❌ in async, use httpx
time.sleep(5)    # ❌ in async, use asyncio.sleep
```

Database always async:

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
engine = create_async_engine("postgresql+asyncpg://...")
```

## Prohibitions

- `from app.models import *`
- `except Exception: pass`
- `time.sleep()` in async
- `requests` in async (use `httpx`)
- `os.environ["KEY"]` directly (use Settings)
- `eval()`, `exec()`
- `pickle` for serialization
- `subprocess` with user input
- `# noqa` without justification

## Hard rules

- Do not commit without passing ruff + mypy.
- Do not use `Any` without documenting why.
- Do not log sensitive data.
- Do not use sync IO in async code.
- Do not import with `*`.
- Do not leave `except: pass`.
- Do not hardcode configuration.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Mandatory pre-commit lint**: Do not commit without passing `ruff check` + `ruff format` + `mypy`.
- **Documented `Any`**: Do not use `Any` without documented justification.
- **Do not log sensitive data**: Never log passwords, tokens, PII or complete bodies in production.
- **Async without blocking**: Do not use sync IO (`requests`, `time.sleep`) in async code.
- **No wildcard import**: Do not use `from ... import *`.
- **No `except: pass`**: Never use `except Exception: pass`.
- **Config via Settings**: Do not use `os.environ["KEY"]` directly; use Settings.
- **No `eval`/`exec`**: Prohibited `eval()`, `exec()`.
- **No `pickle` for serialization**: Prohibited `pickle` for serialization.
- **No `subprocess` with user input**: Prohibited `subprocess` with unsanitized input.
- **No `# noqa` without justification**: Every `# noqa` must have documented reason.
- **No commented dead code**: Delete and use git; do not comment dead code.
