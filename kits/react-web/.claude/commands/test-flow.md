# /test-flow

Valida uma alteração em React Web.

## Sequência obrigatória

0. Classificar task: PEQUENA ou GRANDE via `git diff --stat HEAD`.
1. Detectar package manager por lockfile: pnpm, yarn, npm ou bun.
2. Detectar scripts reais em `package.json`.
3. Rodar, quando existirem:
   - install/check de dependências
   - lint
   - typecheck
   - unit/component tests
   - e2e tests
   - production build
4. Em falha, diagnosticar causa: ambiente, teste, código, design, acessibilidade, build.
5. Corrigir só o mínimo e reexecutar.
6. Gerar relatório em `docs/test_report_<slug>.md`.
7. Commitar somente se PASSOU; nunca usar `--no-verify`.
