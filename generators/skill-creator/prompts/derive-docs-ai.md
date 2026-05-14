# derive-docs-ai.md

Gere os guias em `docs/ai/` específicos para a stack descrita.

## Input

- **Stack**: `{{DESCRIPTION}}`
- **Nome dO preset**: `{{KIT_NAME}}`
- **Tipo**: backend / frontend / mobile (inferir pela descrição)

## Referência

Leia os docs/ai dos presets existentes antes de gerar:

- `presets/python-backend/docs/ai/` — backend com API, DB, security, observability, scalability
- `presets/react-web/docs/ai/` — frontend com design system, accessibility, performance
- `presets/node-backend/docs/ai/` — mesmo padrão python-backend adaptado para Node/TypeScript
- `presets/flutter-app/docs/ai/` — mobile com feature guide, design system

## Guias obrigatórios (toda stack)

### ARCHITECTURE.md (~150+ linhas)

Estrutura de diretórios da stack com:
- Visão geral da arquitetura
- Árvore de diretórios com descrição de cada pasta
- Camadas e responsabilidades
- Fluxo de dados (request → response)
- Padrões de injeção de dependência
- Convenções de nomenclatura
- O que NÃO fazer (anti-patterns específicos)

### CODING_STANDARDS.md (~120+ linhas)

Padrões de código com:
- Linting e formatação (ferramenta + config)
- Tipagem (quando aplicável)
- Nomenclatura (arquivos, classes, funções, variáveis, constantes)
- Tratamento de erros
- Logging
- Comentários e documentação
- Imports e organização
- Proibições específicas da stack

### TESTING_GUIDE.md (~120+ linhas)

Padrões de teste com:
- Framework de teste
- Estrutura de diretórios de teste
- Convenções de nomenclatura (test files, describe, it)
- Fixtures/factories/mocks
- Cobertura mínima esperada
- O que testar por camada
- Anti-patterns de teste
- Comando para rodar testes

## Guias por tipo de stack

### Backend (gerar TODOS)

- **API_GUIDE.md** (~120+ linhas): convenções REST/GraphQL, versionamento, payload, status codes, paginação, errors, documentação automática, rate limiting
- **DATABASE_GUIDE.md** (~120+ linhas): ORM/query builder, migrations, índices, N+1, transações, constraints, seeds, conexões/pool
- **SECURITY_GUIDE.md** (~100+ linhas): auth, autorização, PII, criptografia, input validation, CORS, headers, secrets
- **OBSERVABILITY_GUIDE.md** (~100+ linhas): structured logging, métricas, healthcheck, tracing, alertas, incident response
- **SCALABILITY_GUIDE.md** (~150+ linhas): concorrência, cache, filas, limites, pool, bulkhead, circuit breaker, graceful shutdown
- **DEPLOYMENT_GUIDE.md** (~80+ linhas): env vars, build, deploy, rollback, healthcheck, monitoring

### Frontend (gerar TODOS)

- **DESIGN_SYSTEM.md** (~120+ linhas): tokens, componentes, temas, estados, responsividade, iconografia
- **ACCESSIBILITY_GUIDE.md** (~100+ linhas): semântica, ARIA, contraste, teclado, screen readers, formulários
- **PERFORMANCE_GUIDE.md** (~100+ linhas): bundle, code splitting, lazy loading, imagens, cache, Web Vitals
- **DEPLOYMENT_GUIDE.md** (~80+ linhas): build, env vars, CDN, rollback, preview deploy

### Mobile (gerar TODOS)

- **DESIGN_SYSTEM.md** (~120+ linhas): tokens, componentes, temas, estados, plataformas
- **FEATURE_GUIDE.md** (~100+ linhas): feature-first, clean architecture, DI, state management, navegação

## Regras de qualidade

- Cada guia deve ter seções numeradas ou com headers claros.
- Incluir exemplos de código específicos da stack (não genéricos).
- Incluir anti-patterns com "Não faça X, faça Y".
- Referenciar as ferramentas reais da stack (não abstrações).
- Mínimo 80 linhas por guia. Ideal 120+.
