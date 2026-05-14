# Coding Standards

Padrões de código para Python backend.

## Formatação e linting

### Ferramentas

- **Formatter**: `ruff format` (substitui black)
- **Linter**: `ruff check` (substitui flake8, isort, pyupgrade)
- **Type checker**: `mypy --strict` ou `pyright`

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

### Comandos

```bash
ruff check . --fix
ruff format .
mypy app/
```

Rodar antes de todo commit.

## Tipagem

Sempre tipar funções públicas:

```python
async def get_user(user_id: int) -> User | None:
    ...

users: list[User] = []
config: dict[str, Any] = {}
```

Type hints modernos (3.12+): `X | Y` ao invés de `Union[X, Y]`.

Nunca usar `Any` sem justificativa documentada.

Usar `from __future__ import annotations` para forward refs.

## Nomenclatura

| Elemento | Convenção | Exemplo |
|---|---|---|
| Módulo/arquivo | snake_case | user_service.py |
| Classe | PascalCase | UserService |
| Função/método | snake_case | create_user() |
| Constante | UPPER_SNAKE | MAX_RETRIES |
| Booleano | is_/has_/can_ | is_active, has_permission |
| Enum | PascalCase class | UserRole.admin |
| Pydantic schema | PascalCase + sufixo | UserCreate, UserResponse |
| Tabela SQL | snake_case plural | user_profiles |
| Coluna SQL | snake_case | created_at |

## Tratamento de erros

Hierarquia de exceções customizadas:

```python
class AppError(Exception):
    def __init__(self, code: str, message: str, status: int):
        self.code = code
        self.message = message
        self.status = status

class NotFoundError(AppError):
    def __init__(self, resource: str, id: int | str):
        super().__init__(code="NOT_FOUND", message=f"{resource} não encontrado", status=404)
```

Regras:
- Nunca `except Exception: pass`.
- Levantar AppError para erros de negócio.
- Logar antes de converter para response.
- Deixar inesperados escaparem para handler global.

## Logging

Structured logging com structlog:

```python
logger = structlog.get_logger()
logger.info("user_created", user_id=user.id, email=user.email)
logger.error("payment_failed", order_id=order.id, error=str(e))
```

Níveis: DEBUG (dev), INFO (eventos de negócio), WARNING (anômalo recuperável), ERROR (atenção), CRITICAL (inoperante).

**Nunca logar**: senhas, tokens, PII, bodies completos em produção.

## Comentários

Comentar o "por quê", não o "quê".

```python
# ✓ Bom: explica decisão
# Pessimistic lock aqui por race condition no saldo (incidente #123)
await session.execute(select(Account).where(...).with_for_update())

# ✗ Ruim: repete código
# select account
await session.execute(select(Account).where(...))
```

Não comentar código morto — delete e use git.

## Imports

Ordem: stdlib → third-party → local. Separados por linha em branco.

```python
from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends
from sqlalchemy import select

from app.schemas.users import UserCreate
from app.services.users import UserService
```

Regras:
- Um import por linha para `from ... import ...`.
- Nunca `from app.models import *`.
- Nunca import circular — use TYPE_CHECKING.

## Async

Sempre async para IO:

```python
result = await session.execute(query)
response = await http_client.post(url, json=data)
```

Nunca bloquear o event loop:

```python
import requests  # ❌ em async, use httpx
time.sleep(5)    # ❌ em async, use asyncio.sleep
```

Banco sempre async:

```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
engine = create_async_engine("postgresql+asyncpg://...")
```

## Proibições

- `from app.models import *`
- `except Exception: pass`
- `time.sleep()` em async
- `requests` em async (use `httpx`)
- `os.environ["KEY"]` direto (use Settings)
- `eval()`, `exec()`
- `pickle` para serialização
- `subprocess` com input do usuário
- `# noqa` sem justificativa

## Regras duras

- Não commitar sem passar ruff + mypy.
- Não usar `Any` sem documentar por quê.
- Não logar dados sensíveis.
- Não usar sync IO em código async.
- Não importar com `*`.
- Não deixar `except: pass`.
- Não hardcodar configuração.
