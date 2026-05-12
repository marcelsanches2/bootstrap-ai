# CLAUDE.md

Contrato principal para Claude Code neste backend Node.js/TypeScript.

## Stack padrão

Node.js LTS, TypeScript, Fastify/Express/Nest quando aplicável, PostgreSQL/SQLite, migrations, testes automatizados.

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

- Não commitar secrets.
- Não logar dados sensíveis.
- Endpoints precisam contrato de erro previsível.
- Migrations precisam rollback quando a ferramenta suportar.
- Testes devem ser determinísticos.
