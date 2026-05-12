# /test-flow

Valida uma alteração em backend Python.

## Sequência obrigatória

0. Classificar task: PEQUENA ou GRANDE via `git diff --stat HEAD`.
1. Detectar comandos disponíveis: `Makefile`, `pyproject.toml`, `pytest.ini`, `alembic.ini`.
2. Rodar, quando aplicável:
   - `ruff format --check .`
   - `ruff check .`
   - `mypy .`
   - `pytest`
   - `alembic check` ou validação equivalente, se Alembic existir
   - healthcheck local, se houver comando documentado
3. Em falha, diagnosticar causa: ambiente, fixture/massa, teste, código, migration, contrato API.
4. Corrigir só o mínimo necessário e reexecutar o comando que falhou.
5. Limite: 3 tentativas por causa raiz.
6. Gerar relatório em `docs/e2e_report_<flow_id>.md` ou `docs/test_report_<slug>.md`.
7. Commitar somente se PASSOU; nunca usar `--no-verify`.
