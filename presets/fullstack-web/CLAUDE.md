# CLAUDE.md

Contrato principal para Claude Code neste projeto fullstack web.

## Projeto

{{PROJECT_NAME}} é uma aplicação fullstack web (Next.js/Remix) com React frontend e Node.js backend no mesmo repositório. Foco: contratos de API estáveis, UX consistente, componentes testáveis, migrations seguras, observabilidade mínima e deploy recuperável.

Stack padrão:

- Node.js LTS
- TypeScript
- Next.js ou Remix (App Router / nested routes)
- React para UI
- Prisma ou Drizzle para persistência
- PostgreSQL em produção; SQLite para dev/test quando adequado
- TanStack Query / Axios para data fetching
- Zustand / Redux apenas quando estado global for necessário
- Zod para validação (boundaries do frontend E input do backend)
- Vitest / Jest para testes
- Playwright / Cypress para E2E

## Leitura sob demanda

Arquivos em `docs/ai/` devem ser lidos conforme o tipo da tarefa. Não leia todos automaticamente.

| Tipo de tarefa | Documento(s) a ler |
|---|---|
| Arquitetura, boundaries, estado, rotas, data flow, DI | `docs/ai/ARCHITECTURE.md` |
| Tela, componente, layout, cor, tipografia, UX | `docs/ai/DESIGN_SYSTEM.md` |
| Acessibilidade, teclado, foco, labels, semântica | `docs/ai/ACCESSIBILITY_GUIDE.md` |
| Performance, bundle, renderização, imagens, Web Vitals | `docs/ai/PERFORMANCE_GUIDE.md` |
| Endpoint, status code, schema, OpenAPI, paginação | `docs/ai/API_GUIDE.md` |
| Modelos, migrations, índices, constraints, queries | `docs/ai/DATABASE_GUIDE.md` |
| Auth, autorização, secrets, PII, rate limit, headers | `docs/ai/SECURITY_GUIDE.md` |
| Logs, métricas, tracing, healthcheck, incidentes | `docs/ai/OBSERVABILITY_GUIDE.md` |
| Escala, concorrência, performance backend, filas, cache, pool | `docs/ai/SCALABILITY_GUIDE.md` |
| Deploy, env, build, cache, CI/CD, rollback | `docs/ai/DEPLOYMENT_GUIDE.md` |
| Código / refactor | `docs/ai/CODING_STANDARDS.md` |
| Testes | `docs/ai/TESTING_GUIDE.md` |
| Feature completa | `docs/ai/FEATURE_GUIDE.md` + docs das áreas afetadas |

## Prioridade atual

1. Contrato de API estável
2. UX clara e consistente
3. Componentes pequenos e testáveis
4. Migrations seguras com rollback
5. Observabilidade mínima para debug em produção
6. Deploy recuperável
7. Performance sem otimização prematura

## Regras obrigatórias

**Frontend:**

- Não misturar regra de negócio pesada dentro de componente visual.
- Não espalhar chamada HTTP em componente quando existe camada de API/hook.
- Não criar estado global para estado local.
- Não usar `any` para fugir de tipagem em contrato público.
- Não quebrar navegação por teclado.
- Não usar cor/espaçamento hardcoded quando existir token/componente.
- Não criar componente genérico antes de existir repetição real.
- Não depender de layout só por pixel perfeito em uma largura.
- Não deixar loading/error/empty state sem decisão.

**Backend:**

- Não alterar schema sem migration e caminho de rollback documentado.
- Não commitar secrets, tokens, dumps, `.env` real ou credenciais de banco.
- Não logar token, senha, Authorization header, cookie ou PII sem mascaramento.
- Funções públicas precisam de tipos explícitos.
- Endpoints precisam de contrato de erro previsível.
- DTO/schema não é entidade de domínio.
- Domínio não importa framework, ORM, fetch/axios ou SDK externo.
- Transações devem ter fronteira explícita.
- Testes não podem depender de produção, relógio real sem controle ou rede externa sem mock.

## Depois de alterar

- Rode typecheck/lint quando existirem scripts.
- Rode testes afetados.
- Rode build production para mudanças em rotas/deps.
- Rode `prisma generate` se schema foi alterado.
- Para UI relevante, valide responsividade, foco e estados visuais.
- Informe arquivos alterados, comandos executados e pendências.

## Princípio de decisão

Código fullstack bom falha com erro diagnosticável, preserva dados e permite rollback às 3 da manhã. Frontend reflete estado do backend, valida para UX não para segurança. Backend é operacionalmente simples e explícito.
