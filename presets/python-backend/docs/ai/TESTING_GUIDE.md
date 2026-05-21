# Testing Guide

Testing standards for Python backend with pytest.

## Framework

pytest with async fixtures via pytest-asyncio.

```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]
addopts = "-v --tb=short"
```

## Directory structure

```
tests/
├── conftest.py             # Global fixtures
├── unit/                   # Unit tests (service, utils)
│   ├── test_user_service.py
│   └── test_security.py
├── integration/            # Integration tests (API + real DB)
│   ├── test_users_api.py
│   └── test_auth_api.py
└── e2e/                    # End-to-end tests
    └── test_order_flow.py
```

## Conventions

- File: `test_<module>.py`
- Class: `Test<Feature>` (optional, group related tests)
- Function: `test_<action>_<scenario>_<expected_result>()`

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

## Tests by layer

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

## Test data

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

### Data rules

- Deterministic data: same test, same result.
- Unique email per test: use UUID or timestamp.
- Do not use random data (random, faker in tests that break).
- Do not depend on execution order.
- Clear state between tests (rollback in fixture).

## Mocks

### When to mock

- External services (email, payment gateway, SMS).
- Specific time and dates.
- File system.

### When NOT to mock

- Database (use real test DB).
- Pydantic validation (test with real input).
- The code being tested itself.

```python
from unittest.mock import AsyncMock, patch

async def test_send_welcome_email_called_on_create(client, sample_user_payload):
    with patch("app.services.users.EmailService.send_welcome", new_callable=AsyncMock) as mock_email:
        response = await client.post("/api/v1/users", json=sample_user_payload)
        assert response.status_code == 201
        mock_email.assert_called_once()
```

## Coverage

```bash
pytest --cov=app --cov-report=term-missing
```

Expected minimums:
- Services: 80%
- Repositories: 70%
- Routers: 80%
- Utils: 90%
- Global: 75%

## Anti-patterns

- Do not test implementation, test behavior.
- Do not use `sleep` to wait for async — use `await`.
- Do not create temporary file without cleanup.
- Do not depend on test order.
- Do not use `mock.patch` on code that is not external.
- Do not skip test with `@pytest.skip` without a registered issue.

## Commands

```bash
pytest                              # All
pytest tests/unit/                  # Unit
pytest tests/integration/           # Integration
pytest -x                           # Stop at first failure
pytest --lf                         # Repeat last failures
pytest tests/unit/test_user_service.py -k "create"  # Filter
pytest --cov=app --cov-report=html  # Coverage with HTML
```

## Hard rules

- Do not remove assertions to make tests pass.
- Do not use `assert True` or `pass` as a test.
- Do not use random data in deterministic tests.
- Do not call real external services in tests.
- Do not depend on execution order.
- Do not commit without at least unit tests for the change.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Do not weaken assertions**: Do not remove assertions to make tests pass.
- **No empty test**: Do not use `assert True` or `pass` as test body.
- **Deterministic data**: Do not use random data (`random`, `faker`) in deterministic tests.
- **No real external service**: Do not call real external services in tests; use mocks.
- **Order independence**: Tests cannot depend on execution order.
- **Mandatory unit tests**: Do not commit without at least unit tests for the change.
- **Do not mock DB**: Database in tests should be real (test DB), not mocked.
- **Do not mock Pydantic validation**: Test Pydantic with real input, not with mocks.
- **Do not use `sleep` for async**: Use `await`, never `sleep` to wait for async operations.
- **Temporary file cleanup**: Do not create temporary files without cleanup.
- **Skip with issue**: Do not skip test with `@pytest.skip` without a registered issue.
