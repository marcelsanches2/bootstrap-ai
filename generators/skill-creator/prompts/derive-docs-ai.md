# derive-docs-ai.md

Gere os guias em `docs/ai/` com conteúdo **específico para a stack** — não templates genéricos.

## Input

- **Stack**: `{{DESCRIPTION}}`
- **Nome do preset**: `{{PRESET_NAME}}`
- **Tipo**: backend / frontend / mobile (inferir pela descrição)

## Referência OBRIGATÓRIA

Leia os docs/ai dos presets existentes **antes** de gerar. Use como barra de qualidade:

- `presets/python-backend/docs/ai/` — backend com API, DB, security, observability, scalability
- `presets/react-web/docs/ai/` — frontend com design system, accessibility, performance
- `presets/node-backend/docs/ai/` — mesmo padrão python-backend adaptado para Node/TypeScript
- `presets/flutter-app/docs/ai/` — mobile com feature guide, design system

**Barra de qualidade = os presets existentes.** Se o conteúdo que você gerar for mais curto ou mais genérico do que o que existe nesses presets, você falhou.

## Regra #1: Stack-specific, não genérico

**RUIM (genérico):**
```markdown
## Nomenclatura
- Use nomes descritivos para variáveis.
- Funções devem ter nomes verbais.
```

**BOM (stack-specific):**
```markdown
## Nomenclatura
- Controllers: `<Recurso>Controller` (`UserController`, `OrderController`)
- Services: `<Recurso>Service` com métodos verbais (`findMany`, `create`, `update`)
- Repositories: `<Recurso>Repository` — nunca use `*Impl` ou `*DAO`
- Entidades Prisma: PascalCase no schema, camelCase nas queries
- DTOs: `<Recurso>CreateDTO`, `<Recurso>UpdateDTO` — never reuse create DTO for update
```

**Cada seção deve mencionar:**
- Ferramentas específicas da stack (Prisma, SQLAlchemy, Riverpod, etc.)
- Comandos específicos (não "rode os testes", mas `pytest --cov=src -x`)
- Anti-patterns com nome real (`N+1 no Prisma`, `god widget`, `setState cascade`)
- Convenções de arquivo específicas (`<feature>/`, `use_case/`, `repository/`)

## Guias obrigatórios (toda stack)

### ARCHITECTURE.md (~100-150 linhas)

Estrutura de diretórios da stack com:
- Visão geral da arquitetura (layers, boundaries)
- **Árvore de diretórios real** com descrição de cada pasta (ex: `controllers/`, `services/`, `repositories/`)
- Camadas e responsabilidades com exemplos de onde cada coisa mora
- Fluxo de dados (request → middleware → controller → service → repository → DB)
- Padrões de injeção de dependência **específicos da stack** (DI container, constructor injection, provider pattern)
- Convenções de nomenclatura de arquivos e pastas
- Anti-patterns com exemplos do que NÃO fazer

### CODING_STANDARDS.md (~80-120 linhas)

Padrões de código com:
- Linting e formatação: **ferramenta + config real** (ex: `ruff.toml`, `.eslintrc`, `analysis_options.yaml`)
- Tipagem: convenções específicas (ex: `strict=True` no mypy, `noUncheckedIndexedAccess` no tsconfig)
- Nomenclatura com exemplos **por tipo de artefato** (controller, service, model, DTO, test, etc.)
- Tratamento de erros: **padrão específico da stack** (ex: custom error classes, error middleware, Result type)
- Logging: **biblioteca + formato** (ex: structlog, winston, logger.setLevel)
- Comentários: o que documentar e o que não documentar
- Imports: ordem, aliasing, barrel exports
- Proibições específicas da stack (ex: "nunca use `any` em TypeScript", "nunca use `setState` com callback em Flutter")

### TESTING_GUIDE.md (~80-120 linhas)

Padrões de teste com:
- **Framework de teste + comando exato** (`pytest -x --cov`, `flutter test --coverage`, `vitest run`)
- Estrutura de diretórios de teste (co-location vs espelho)
- Convenções de nomenclatura (test files, describe blocks, test names)
- Fixtures/factories/mocks **específicos da stack** (ex: `factory_boy`, `msw`, `mocktail`)
- Cobertura mínima esperada e como medi-la
- O que testar por camada (unit → integration → E2E)
- Anti-patterns de teste específicos
- **Separação de responsabilidades**: este é o ÚNICO guide que fala de testes. Nenhum outro guide deve ter seções de teste.

## Guias por tipo de stack

### Backend (gerar TODOS)

- **API_GUIDE.md** (~80-120 linhas): convenções REST, versionamento, payload, status codes, paginação, errors, documentação automática (Swagger/OpenAPI), rate limiting — tudo com exemplos da stack
- **DATABASE_GUIDE.md** (~80-120 linhas): ORM/query builder **específico** (Prisma, SQLAlchemy, TypeORM), migrations, índices, N+1, transações, constraints, seeds, conexões/pool — com comandos reais
- **SECURITY_GUIDE.md** (~60-100 linhas): auth (JWT/session/OAuth), autorização (RBAC/ABAC), PII, criptografia, input validation, CORS, headers, secrets management — com bibliotecas da stack
- **OBSERVABILITY_GUIDE.md** (~60-100 linhas): structured logging **com biblioteca real**, métricas, healthcheck endpoint, tracing, alertas, incident response
- **SCALABILITY_GUIDE.md** (~80-120 linhas): concorrência (async/worker), cache (Redis/Memcached), filas, rate limiting, connection pool, bulkhead, circuit breaker, graceful shutdown — tudo específico da stack
- **DEPLOYMENT_GUIDE.md** (~60-80 linhas): env vars, build, deploy, rollback, healthcheck, monitoring — com ferramentas reais

### Frontend (gerar TODOS)

- **DESIGN_SYSTEM.md** (~80-120 linhas): tokens (cores, tipografia, espaçamento), componentes, temas, estados, responsividade, iconografia — com lib de CSS/componentes da stack
- **ACCESSIBILITY_GUIDE.md** (~60-100 linhas): semântica, ARIA, contraste, teclado, screen readers, formulários — com ferramentas de teste (axe, lighthouse)
- **PERFORMANCE_GUIDE.md** (~60-100 linhas): bundle analysis, code splitting, lazy loading, imagens, cache, Web Vitals — com ferramentas reais da stack
- **DEPLOYMENT_GUIDE.md** (~60-80 linhas): build, env vars, CDN, rollback, preview deploy

### Mobile (gerar TODOS)

- **DESIGN_SYSTEM.md** (~80-120 linhas): tokens, componentes, temas, estados, plataformas (iOS/Android)
- **FEATURE_GUIDE.md** (~80-100 linhas): feature-first, clean architecture, DI, state management, navegação — com lib específica (Riverpod, BLoC, etc.)

## Regras de qualidade

1. **Cada seção deve mencionar ferramentas/bibliotecas reais da stack** — nunca "framework de teste", mas "pytest com fixtures do factory_boy"
2. **Incluir comandos exatos** — não "rode os testes", mas `pytest --cov=src --cov-report=term-missing -x`
3. **Incluir anti-patterns com "Não faça X, faça Y"** — específicos da stack
4. **Mínimo 60 linhas por guia, ideal 80-120** — se ficou mais curto que os presets de referência, está incompleto
5. **Nenhum guia além de TESTING_GUIDE deve falar de testes** — separação de responsabilidades
6. **Usar `{{PROJECT_NAME}}`** onde o nome do projeto for referenciado
