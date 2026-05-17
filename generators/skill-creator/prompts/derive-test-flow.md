# derive-jarvis-test-flow.md

Gere o `jarvis-test-flow.md` específico para a stack.

## Input

- **Stack**: `{{DESCRIPTION}}`
- **Nome dO preset**: `{{PRESET_NAME}}`
- **Tipo**: backend / frontend / mobile (inferir pela descrição)

## Referência

Leia os jarvis-test-flow dos presets existentes antes de gerar:

- `presets/flutter-app/.claude/commands/jarvis-test-flow.md` (~11k chars, mobile com Figma validation)
- `presets/python-backend/.claude/commands/jarvis-test-flow.md` (~9k chars, backend com pytest/ruff/mypy/alembic)
- `presets/react-web/.claude/commands/jarvis-test-flow.md` (~9.5k chars, frontend com testing-library/MSW/tsc)
- `presets/node-backend/.claude/commands/jarvis-test-flow.md` (~9.6k chars, backend com jest|vitest/tsc/prisma)

## Estrutura obrigatória

O jarvis-test-flow DEVE seguir esta estrutura (mesma dos presets existentes):

```
0. Avaliar tamanho da task (GRANDE/PEQUENA)
1. Determinar flow_id
2. Inventariar massa (fixtures/mocks deterministicos)
3. Inventariar teste (com cross-ref ao jarvis-plan)
4. Executar pipeline (lint → typecheck → test → migration → build → healthcheck)
4a. Loop de diagnóstico e correcao (classifica causa, planeja, corrige, max 3 tentativas)
5. Gerar relatório em docs/test_report_{flow_id}.md
6. Encerrar
7. Commit (so se PASSOU, nunca --no-verify)
8. Push (nunca force, pergunta antes de rebase)
+ Restrições obrigatórias
```

## Adaptações por tipo

### Backend

Pipeline:
- Package manager / dependency install
- Linter (ruff/eslint/revive/etc)
- Typechecker (mypy/pyright/tsc/etc)
- Test runner (pytest/jest/vitest/go test/etc)
- Migration validation (alembic/prisma/goose/typeorm/etc)
- Production build
- Healthcheck local

Causas de diagnóstico: ambiente, fixture/massa, teste, código, migration, contrato API, tipagem

Diretórios monitorados no Stop hook: `src/`, `app/`, `tests/`, `test/`, migrations dir, config files

### Frontend

Pipeline:
- Package manager install
- Linter (eslint/stylelint/etc)
- Typechecker (tsc)
- Test runner (jest/vitest + testing-library)
- E2E tests (Playwright/Cypress, se existir)
- Production build
- Lighthouse/axe audit (se configurado)

Causas de diagnóstico: ambiente, mock/massa, teste, código, tipagem, build, acessibilidade

Diretórios monitorados: `src/`, `public/`, `package.json`, `tsconfig.json`

### Mobile

Pipeline:
- Dependency install (pub get/pod install/gradle)
- Analyzer (flutter analyze / swiftlint / ktlint)
- Test runner (flutter test / XCTest / instrumentation)
- Integration test no device/simulator
- Production build

Causas de diagnóstico: ambiente, mock/massa, teste, código, design (Figma comparison)

Diretórios monitorados: `lib/`, `integration_test/`, `pubspec.yaml`, etc.

## Qualidade mínima

- **Barra de qualidade = presets existentes** (~9000+ chars). Se ficou mais curto, está incompleto.
- Pipeline com **comandos reais da stack** (ex: `ruff check . --fix`, `flutter test --coverage`, `npx prisma migrate status`) — nunca genéricos
- Loop de diagnóstico com causas específicas da stack e exemplos concretos de correção
- Commit/push com as mesmas regras duras dos presets existentes
- Restrições obrigatórias completas
- Incluir tabela de classificação de causas com ação para cada tipo

## Exemplo de conteúdo stack-specific

**RUIM:**
```
4. Execute test runner
   Se falhar, verifique o erro e corrija.
```

**BOM:**
```
4. Executar pipeline

```bash
cd $ROOT
# 1. Lint
ruff check . --fix --unsafe-fixes
# 2. Typecheck  
mypy src/ --strict
# 3. Tests
pytest tests/ -x --tb=short --cov=src --cov-report=term-missing
# 4. Migration check
alembic check
alembic upgrade head
# 5. Build
docker build -t $PROJECT_NAME:test .
# 6. Healthcheck
curl -sf http://localhost:8000/health || echo "FAIL"
```
```
