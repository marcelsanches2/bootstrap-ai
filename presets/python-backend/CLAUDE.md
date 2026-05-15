# CLAUDE.md

Contrato principal para Claude Code neste backend Python.

## Projeto

{{PROJECT_NAME}} é um backend Python para APIs e serviços de domínio, com foco em arquitetura simples, contratos explícitos, segurança operacional e evolução incremental.

Stack padrão:

- Python 3.12+
- FastAPI quando houver API HTTP
- Pydantic v2 para schemas e validação de borda
- SQLAlchemy 2.x para persistência
- Alembic para migrations
- PostgreSQL em produção; SQLite apenas para desenvolvimento/testes quando adequado
- pytest para testes
- ruff para lint/format
- mypy quando configurado

## Leitura sob demanda

Os arquivos em `docs/ai/` devem ser lidos conforme o tipo da tarefa. Não leia todos automaticamente — carregue apenas os relevantes.

| Tipo de tarefa | Documento(s) a ler |
|---|---|
| Arquitetura, boundaries, DI, config ou dependências | `docs/ai/ARCHITECTURE.md` |
| Endpoint, status code, schema, OpenAPI, paginação ou contrato HTTP | `docs/ai/API_GUIDE.md` |
| Modelos, migrations, índices, constraints ou queries | `docs/ai/DATABASE_GUIDE.md` |
| Auth, autorização, secrets, PII, rate limit ou validação sensível | `docs/ai/SECURITY_GUIDE.md` |
| Logs, métricas, tracing, healthcheck ou incidentes | `docs/ai/OBSERVABILITY_GUIDE.md` |
| Escala, concorrência, performance backend, filas, cache, pool, carga ou produção crítica | `docs/ai/SCALABILITY_GUIDE.md` |
| Deploy, env vars, systemd, nginx, CI/CD, release ou rollback | `docs/ai/DEPLOYMENT_GUIDE.md` |
| Código, refactor ou testes | `docs/ai/CODING_STANDARDS.md`, `docs/ai/TESTING_GUIDE.md` |
| Feature completa | `docs/ai/FEATURE_GUIDE.md` + documentos das áreas afetadas |

## Prioridade atual

1. contrato de API estável
2. domínio isolado do framework
3. migrations seguras
4. testes determinísticos
5. observabilidade mínima para debug em produção
6. deploy recuperável
7. escala em produção sem adivinhar gargalo

## Regras obrigatórias

- Não alterar schema sem migration e caminho de rollback/downgrade documentado.
- Não commitar secrets, tokens, dumps, `.env` real ou credenciais de banco.
- Não logar token, senha, Authorization header, cookie ou PII sem mascaramento.
- Funções públicas precisam de type hints.
- Endpoints precisam de contrato de erro previsível.
- DTO/schema de API não é entidade de domínio.
- Domínio não importa FastAPI, SQLAlchemy, requests/httpx, boto ou SDK externo.
- Transações devem ter fronteira explícita.
- Testes não podem depender de produção, relógio real sem controle ou rede externa sem mock.
- Não criar abstração antes de existir pelo menos um uso real.
- Plano que toca caminho crítico, banco crescente, fila ou integração externa precisa tratar escala, limites e diagnóstico.

## Depois de alterar

- Rode `ruff check .` e `ruff format --check .` quando ruff existir.
- Rode `mypy .` quando configurado.
- Rode `pytest` para lógica, API, migrations ou regressão.
- Se mexeu em dependências, rode o instalador/lockfile do projeto.
- Informe arquivos alterados, comandos executados e pendências reais.

## Princípio de decisão

Prefira código explícito, testável e operacionalmente simples. Backend bom é aquele que falha com erro diagnosticável, preserva dados e permite rollback às 3 da manhã.
