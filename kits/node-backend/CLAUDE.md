# CLAUDE.md

Contrato principal para Claude Code neste backend Node.js/TypeScript.

## Projeto

{{PROJECT_NAME}} é um backend Node.js/TypeScript para APIs e serviços de domínio, com foco em arquitetura simples, contratos explícitos, segurança operacional e evolução incremental.

Stack padrão:

- Node.js LTS
- TypeScript
- Fastify, Express ou Nest quando aplicável
- Zod/class-validator para validação de borda quando aplicável
- Prisma ou Drizzle para persistência quando aplicável
- PostgreSQL em produção; SQLite apenas para desenvolvimento/testes quando adequado
- Vitest/Jest para testes
- ESLint/Prettier conforme projeto

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
- Funções públicas precisam de tipos explícitos.
- Endpoints precisam de contrato de erro previsível.
- DTO/schema de API não é entidade de domínio.
- Domínio não importa Express/Fastify/Nest, ORM, fetch/axios ou SDK externo.
- Transações devem ter fronteira explícita.
- Testes não podem depender de produção, relógio real sem controle ou rede externa sem mock.
- Não criar abstração antes de existir pelo menos um uso real.
- Plano que toca caminho crítico, banco crescente, fila ou integração externa precisa tratar escala, limites e diagnóstico.

## Processo obrigatório para mudanças não triviais

1. Criar plano em `plans/` com escopo, arquivos, riscos e testes.
2. Rodar `/jarvis-plan-revisor`.
3. Sanar `BLOCKER` e `MAJOR`.
4. Implementar somente o plano revisado, em passos pequenos.
5. Rodar `/jarvis-test-flow`.
6. Rodar `/ship`.

## Depois de alterar

- Rode `npm run lint` quando existir.
- Rode `npm run typecheck` quando configurado.
- Rode `npm test` para lógica, API, migrations ou regressão.
- Se mexeu em dependências, rode o instalador/lockfile do projeto.
- Informe arquivos alterados, comandos executados e pendências reais.

## Princípio de decisão

Prefira código explícito, testável e operacionalmente simples. Backend bom é aquele que falha com erro diagnosticável, preserva dados e permite rollback às 3 da manhã.
