# Testing Guide

Padrões de teste para Python backend com pytest.

## Framework

pytest com fixtures async via pytest-asyncio.

```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
addopts = "-v --tb=short"
```

## Estrutura de diretórios

```
tests/
├── conftest.py             # Fixtures globais
├── unit/                   # Testes unitários (service, utils)
│   ├── test_user_service.py
│   └── test_security.py
├── integration/            # Testes de integração (API + DB real)
│   ├── test_users_api.py
│   └── test_auth_api.py
└── e2e/                    # Testes end-to-end
    └── test_order_flow.py
```

## Convenções

- Arquivo: `test_<module>.py`
- Classe: `Test<Feature>` (opcional, agrupar relacionados)
- Função: `test_<acao>_<cenario>_<resultado_esperado>()`

```python
class TestUserService:
    async def test_create_user_with_valid_data_returns_user(self):
        ...

    async def test_create_user_with_duplicate_email_raises_conflict(self):
        ...

    async def test_create_user_with_invalid_email_raises_validation(self):
        ...
```

## Fixtures

### conftest.py

```python
import pytest
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from httpx import AsyncClient, ASGITransport

from app.main import app
from app.models.base import Base

TEST_DATABASE_URL = "postgresql+asyncpg://test:test@localhost/test_db"

@pytest.fixture(scope="session")
async def engine():
    eng = create_async_engine(TEST_DATABASE_URL, echo=False)
    async with eng.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield eng
    async with eng.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await eng.dispose()

@pytest.fixture
async def db_session(engine):
    async with async_sessionmaker(engine, class_=AsyncSession)() as session:
        yield session
        await session.rollback()

@pytest.fixture
async def client(db_session):
    # Override dependency
    async def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c
    app.dependency_overrides.clear()

@pytest.fixture
def sample_user_payload():
    return {"name": "Test User", "email": "test@example.com", "password": "secret123"}
```

## Testes por camada

### Unit (service)

```python
async def test_create_user_hashes_password(db_session):
    service = UserService(db_session)
    user = await service.create(UserCreate(
        name="Test",
        email="test@example.com",
        password="secret123",
    ))
    assert user.password_hash != "secret123"
    assert verify_password("secret123", user.password_hash)
```

### Integration (API)

```python
async def test_create_user_returns_201(client, sample_user_payload):
    response = await client.post("/api/v1/users", json=sample_user_payload)
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == sample_user_payload["email"]
    assert "password" not in data
    assert "id" in data

async def test_create_duplicate_email_returns_409(client, sample_user_payload):
    await client.post("/api/v1/users", json=sample_user_payload)
    response = await client.post("/api/v1/users", json=sample_user_payload)
    assert response.status_code == 409

async def test_list_users_returns_paginated(client, db_session):
    # Seed 25 users
    for i in range(25):
        await client.post("/api/v1/users", json={
            "name": f"User {i}", "email": f"user{i}@test.com", "password": "secret123"
        })

    response = await client.get("/api/v1/users?skip=0&limit=10")
    assert response.status_code == 200
    data = response.json()
    assert len(data["items"]) == 10
    assert data["total"] == 25
```

## Massa de dados

### Factories

```python
# tests/factories.py
from app.models import User

async def create_user(session: AsyncSession, **overrides) -> User:
    defaults = {
        "name": "Test User",
        "email": f"user-{uuid4().hex[:8]}@test.com",
        "password_hash": hash_password("secret123"),
        "is_active": True,
    }
    defaults.update(overrides)
    user = User(**defaults)
    session.add(user)
    await session.commit()
    await session.refresh(user)
    return user
```

### Regras de massa

- Dados determinísticos: mesmo teste, mesmo resultado.
- Email único por teste: usar UUID ou timestamp.
- Não usar dados aleatórios (random, faker em teste que quebra).
- Não depender de ordem de execução.
- Limpar estado entre testes (rollback no fixture).

## Mocks

### Quando mockar

- Serviços externos (email, payment gateway, SMS).
- Time e datas específicas.
- File system.

### Quando NÃO mockar

- Banco de dados (usar DB de teste real).
- Validação Pydantic (testar com input real).
- Próprio código sendo testado.

```python
from unittest.mock import AsyncMock, patch

async def test_send_welcome_email_called_on_create(client, sample_user_payload):
    with patch("app.services.users.EmailService.send_welcome", new_callable=AsyncMock) as mock_email:
        response = await client.post("/api/v1/users", json=sample_user_payload)
        assert response.status_code == 201
        mock_email.assert_called_once()
```

## Cobertura

```bash
pytest --cov=app --cov-report=term-missing
```

Mínimo esperado:
- Services: 80%
- Repositories: 70%
- Routers: 80%
- Utils: 90%
- Global: 75%

## Anti-patterns

- Não testar implementação, testar comportamento.
- Não usar `sleep` para esperar async — usar `await`.
- Não criar arquivo temporário sem cleanup.
- Não depender de ordem de testes.
- Não usar `mock.patch` em código que não é externo.
- Não pular teste com `@pytest.skip` sem issue registrada.

## Comandos

```bash
pytest                              # Todos
pytest tests/unit/                  # Unitários
pytest tests/integration/           # Integração
pytest -x                           # Parar no primeiro falho
pytest --lf                         # Repetir últimos falhos
pytest tests/unit/test_user_service.py -k "create"  # Filtro
pytest --cov=app --cov-report=html  # Coverage com HTML
```

## Regras duras

- Não remover assertion para fazer teste passar.
- Não usar `assert True` ou `pass` como teste.
- Não usar dados aleatórios em teste determinístico.
- Não chamar serviço externo real em teste.
- Não depender de ordem de execução.
- Não commitar sem pelo menos testes unitários da mudança.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Não weaken assertions**: Não remover assertion para fazer teste passar.
- **Sem teste vazio**: Não usar `assert True` ou `pass` como corpo de teste.
- **Dados determinísticos**: Não usar dados aleatórios (`random`, `faker`) em teste determinístico.
- **Sem serviço externo real**: Não chamar serviço externo real em teste; usar mock.
- **Independência de ordem**: Testes não podem depender de ordem de execução.
- **Testes unitários obrigatórios**: Não commitar sem pelo menos testes unitários da mudança.
- **Não mockar DB**: Banco de dados em teste deve ser real (DB de teste), não mockado.
- **Não mockar validação Pydantic**: Testar Pydantic com input real, não com mock.
- **Não usar `sleep` para async**: Usar `await`, nunca `sleep` para esperar operação assíncrona.
- **Cleanup de arquivos temporários**: Não criar arquivo temporário sem cleanup.
- **Skip com issue**: Não pular teste com `@pytest.skip` sem issue registrada.
