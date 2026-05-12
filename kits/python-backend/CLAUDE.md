# CLAUDE.md

Contrato principal para Claude Code neste backend Python.

## Stack padrão

Python 3.12+, FastAPI quando aplicável, SQLAlchemy 2.x, Alembic, PostgreSQL/SQLite, pytest, ruff, mypy.

## Leitura sob demanda

| Tipo de tarefa | Documento(s) |
|---|---|
| Arquitetura | `docs/ai/ARCHITECTURE.md` |
| API | `docs/ai/API_GUIDE.md` |
| Banco/migrations | `docs/ai/DATABASE_GUIDE.md` |
| Segurança | `docs/ai/SECURITY_GUIDE.md` |
| Observabilidade | `docs/ai/OBSERVABILITY_GUIDE.md` |
| Deploy | `docs/ai/DEPLOYMENT_GUIDE.md` |
| Código/testes | `docs/ai/CODING_STANDARDS.md`, `docs/ai/TESTING_GUIDE.md` |

## Processo obrigatório para mudanças não triviais

1. Criar plano em `plans/`.
2. Rodar `/jarvis-revisor`.
3. Sanar BLOCKER/MAJOR.
4. Implementar somente o plano revisado.
5. Rodar `/test-flow`.
6. Rodar `/ship`.

## Regras obrigatórias

- Não alterar schema sem migration e rollback/downgrade.
- Não commitar secrets.
- Não logar dados sensíveis.
- Funções públicas com type hints.
- Endpoints precisam de contrato de erro previsível.
- Testes devem ser determinísticos.
