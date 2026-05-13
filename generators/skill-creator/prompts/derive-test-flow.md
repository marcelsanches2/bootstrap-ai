# derive-test-flow.md

Gere o `test-flow.md` específico para a stack.

## Input

- **Stack**: `{{DESCRIPTION}}`
- **Nome do kit**: `{{KIT_NAME}}`
- **Tipo**: backend / frontend / mobile (inferir pela descrição)

## Referência

Leia os test-flow dos kits existentes antes de gerar:

- `kits/flutter-app/.claude/commands/test-flow.md` (~11k chars, mobile com Figma validation)
- `kits/python-backend/.claude/commands/test-flow.md` (~9k chars, backend com pytest/ruff/mypy/alembic)
- `kits/react-web/.claude/commands/test-flow.md` (~9.5k chars, frontend com testing-library/MSW/tsc)
- `kits/node-backend/.claude/commands/test-flow.md` (~9.6k chars, backend com jest|vitest/tsc/prisma)

## Estrutura obrigatória

O test-flow DEVE seguir esta estrutura (mesma dos kits existentes):

```
0. Avaliar tamanho da task (GRANDE/PEQUENA)
1. Determinar flow_id
2. Inventariar massa (fixtures/mocks deterministicos)
3. Inventariar teste (com cross-ref ao jarvis-revisor)
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

- Mínimo 200 linhas (~9000+ chars).
- Pipeline com comandos reais da stack (não genéricos).
- Loop de diagnóstico com causas específicas da stack.
- Commit/push com as mesmas regras duras dos kits existentes.
- Restrições obrigatórias completas.
