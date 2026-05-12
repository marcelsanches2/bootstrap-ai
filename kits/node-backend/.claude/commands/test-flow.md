# /test-flow

Valida uma alteração em backend Node.js/TypeScript.

## Sequência obrigatória

0. Classificar task: PEQUENA ou GRANDE via `git diff --stat HEAD`.
1. Detectar package manager por lockfile: pnpm, yarn, npm ou bun.
2. Detectar scripts reais em `package.json`.
3. Rodar, quando existirem:
   - lint
   - typecheck
   - unit tests
   - integration tests
   - migration validation, se existir
   - production build
   - healthcheck local, se houver comando documentado
4. Em falha, diagnosticar causa: ambiente, fixture/massa, teste, código, migration, contrato API.
5. Corrigir só o mínimo necessário e reexecutar.
6. Gerar relatório em `docs/test_report_<slug>.md`.
7. Commitar somente se PASSOU; nunca usar `--no-verify`.
