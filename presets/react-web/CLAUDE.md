# CLAUDE.md

Contrato principal para Claude Code neste projeto React Web.

## Projeto

{{PROJECT_NAME}} é uma aplicação web React/TypeScript. O foco é UX consistente, componentes previsíveis, acessibilidade real, performance suficiente e entrega verificável.

Stack padrão:

- React
- TypeScript
- Vite ou Next.js quando aplicável
- React Router/roteador do framework quando aplicável
- TanStack Query/Axios quando houver data fetching relevante
- Zustand/Redux apenas quando estado global for necessário
- Vitest/Jest para unit/component
- Playwright/Cypress para E2E quando o fluxo justificar

## Leitura sob demanda

| Tipo de tarefa | Documento(s) a ler |
|---|---|
| Arquitetura, boundaries, estado, rotas ou data fetching | `docs/ai/ARCHITECTURE.md` |
| Tela, componente, layout, cor, tipografia ou UX | `docs/ai/DESIGN_SYSTEM.md` |
| Acessibilidade, teclado, foco, labels ou semântica | `docs/ai/ACCESSIBILITY_GUIDE.md` |
| Performance, bundle, renderização, imagens ou Web Vitals | `docs/ai/PERFORMANCE_GUIDE.md` |
| Deploy, env, build, cache ou rollback | `docs/ai/DEPLOYMENT_GUIDE.md` |
| Código/refactor | `docs/ai/CODING_STANDARDS.md` |
| Testes | `docs/ai/TESTING_GUIDE.md` |
| Feature completa | `docs/ai/FEATURE_GUIDE.md` + documentos das áreas afetadas |

## Prioridade atual

1. UX clara e consistente
2. componentes pequenos e testáveis
3. acessibilidade mínima desde o início
4. estado/data fetching sem mágica
5. build production confiável
6. performance sem otimização prematura

## Regras obrigatórias

- Não misturar regra de negócio pesada dentro de componente visual.
- Não espalhar chamada HTTP em componente quando existe camada de API/hook.
- Não criar estado global para estado local.
- Não usar `any` para fugir de tipagem em contrato público.
- Não quebrar navegação por teclado.
- Não usar cor/espaçamento hardcoded quando existir token/componente.
- Não criar componente genérico antes de existir repetição real.
- Não depender de layout só por pixel perfeito em uma largura.
- Não deixar loading/error/empty state sem decisão.
- Não commitar `.env` real.



- Rode typecheck/lint quando existirem scripts.
- Rode testes afetados.
- Rode build production para mudanças relevantes de app/rotas/deps.
- Para UI relevante, valide responsividade, foco e estados visuais.
- Informe arquivos alterados, comandos executados e pendências.
