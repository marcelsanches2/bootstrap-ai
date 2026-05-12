# CLAUDE.md

Contrato principal para Claude Code neste projeto React Web.

## Stack padrão

React, TypeScript, Vite/Next quando aplicável, testes unit/component/e2e conforme projeto.

## Leitura sob demanda

| Tipo de tarefa | Documento(s) |
|---|---|
| Arquitetura frontend | `docs/ai/ARCHITECTURE.md` |
| UI/design | `docs/ai/DESIGN_SYSTEM.md` |
| Acessibilidade | `docs/ai/ACCESSIBILITY_GUIDE.md` |
| Performance | `docs/ai/PERFORMANCE_GUIDE.md` |
| Testes | `docs/ai/TESTING_GUIDE.md` |
| Deploy | `docs/ai/DEPLOYMENT_GUIDE.md` |

## Processo obrigatório

1. Criar plano em `plans/`.
2. Rodar `/jarvis-revisor`.
3. Sanar BLOCKER/MAJOR.
4. Implementar somente o plano revisado.
5. Rodar `/test-flow`.
6. Rodar `/ship`.

## Regras obrigatórias

- UI precisa cobrir loading, empty, error e success quando aplicável.
- Não hardcodar design se existir token/componente.
- Acessibilidade não é opcional.
- Build quebrado bloqueia conclusão.
