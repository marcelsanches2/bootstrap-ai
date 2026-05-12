---
description: Valida uma alteração em React Web executando lint, typecheck, testes, build e gerando relatório.
---

# /test-flow

Valida uma alteração em React Web. Argumento opcional: `flow_id` (ex.: `user-login`, `product-list`, `checkout-flow`).

## Sequência obrigatória

0. **Avaliar tamanho da task**
   - Inspecionar `git diff --stat HEAD` e a natureza dos arquivos tocados em `src/`, `public/`, `package.json`, `tsconfig.json`.
   - **GRANDE** (rodar pipeline completo, etapas 1-8): nova página/rota, novo componente de feature, mudança em estado global, integração de API nova, mudança em design system, formulário complexo, mudança que afeta fluxo do usuário ponta a ponta.
   - **PEQUENA** (pular para etapa 7): typo, ajuste de CSS isolado, comentário, ajuste fino em componente sem mudança de comportamento, refactor sem mudança observável.
   - **Em dúvida**: perguntar ao usuário. Não chutar.
   - Reportar a classificação numa linha antes de prosseguir.

1. **Determinar o `flow_id`**
   - Se foi passado como argumento, usar.
   - Se não, inferir pelo `git diff --name-only HEAD`. Mapear `src/pages/<X>/` ou `src/features/<X>/` -> `<X>_*` flow. Se ambíguo, perguntar.

2. **Inventariar massa (mocks determinísticos)**
   - Localizar mocks em `src/mocks/`, `src/__mocks__/`, `msw/handlers/`, `test/fixtures/`.
   - Validar que os dados esperados existem e cobrem o flow_id.
   - Se faltar massa, criar mock/handler determinístico seguindo `docs/ai/TESTING_GUIDE.md`. Sem dados aleatórios, sem chamada de rede real.
   - Garantir que testes usam mock da API (MSW, jest.mock, etc) e não chamam backend real.

3. **Inventariar teste**
   - Procurar `src/**/<flow_id>*.test.{ts,tsx}` ou `test/**/<flow_id>*.test.{ts,tsx}` que cubra o flow.
   - Verificar se existe relatório de revisão do `/jarvis-revisor`. Se existir, extrair cenários sugeridos como requisitos mínimos.
   - Se não existir teste, criar seguindo `docs/ai/TESTING_GUIDE.md` com o runner configurado (jest/vitest/testing-library).
   - Validar cobertura: caminho feliz, loading states, error states, empty states, validação de formulário, navegação.

4. **Executar o pipeline**
   - Detectar package manager por lockfile: `pnpm-lock.yaml` -> pnpm, `yarn.lock` -> yarn, `bun.lockb` -> bun, senão npm.
   - `[pkg-manager] install` (se houve mudança em dependencies)
   - `[pkg-manager] run lint` (se existir)
   - `tsc --noEmit` ou `[pkg-manager] run typecheck` (se existir)
   - `[pkg-manager] test` (unit + component tests)
   - `[pkg-manager] run test:e2e` (se existir e2e tests, ex: Playwright/Cypress)
   - `[pkg-manager] run build` (production build) — bloqueia se quebrar
   - Lighthouse/axe audit, se configurado
   - **Se qualquer comando falhar, entrar no loop de diagnóstico (etapa 4a).** Não maquiar.

4a. **Loop de diagnóstico e correção** (acionado quando algo na etapa 4 falha)
   - **Diagnosticar**: ler a saída de erro completa. Classificar a causa:
     - `ambiente`: Node version, node_modules, dependência ausente, cache corrompido.
     - `mock/massa`: dado faltando, divergência entre mock e assertion, handler MSW não cobre endpoint.
     - `teste`: assertion inválida, seletor quebrado, act() warning, async sem waitFor, snapshot desatualizado.
     - `código`: regressão real, contrato quebrado, componente não renderiza, hook com dependência errada.
     - `tipagem`: erro de tipo que expõe bug de props/interface.
     - `build`: import não resolvido, chunk error, env variable faltando.
   - **Planejar**: 1-3 frases: causa-raiz, correção mínima, arquivo afetado.
   - **Corrigir**: aplicar correção mínima. Sem refactor adicional.
   - **Re-rodar**: executar de novo o(s) comando(s) que falhou(aram).
   - **Limite de 3 tentativas por causa-raiz**. Se reaparecer ao 3º ciclo, escalar.
   - **Parar imediatamente se**: correção exige modificar `docs/ai/*`, criar feature fora do escopo, ou indica problema de infra.

5. **Gerar relatório**
   - Escrever ou atualizar `docs/test_report_<flow_id>.md` com:
     - Data, branch, classificação (GRANDE/PEQUENA), package manager detectado
     - Comandos executados (tabela: comando, resultado)
     - Mocks/massa criada ou validada
     - Fluxo validado (tabela: etapa, validação)
     - Problemas encontrados / correções (tabela: causa, correção)
     - Status final: **PASSOU**, **PASSOU PARCIALMENTE**, ou **FALHOU**
     - Arquivos criados/modificados
     - Como rodar de novo

6. **Encerrar**
   - Reportar uma linha de resumo + caminho do relatório em `docs/`.

7. **Commit**
   - Executar `git add src/ public/ docs/ package.json [lockfile]`.
   - Se nada foi staged, pular o commit.
   - Mensagem:
     - **PEQUENA**: `chore: <descrição curta>`.
     - **GRANDE + PASSOU**: `feat|fix|refactor: <descrição> + test <flow_id>`.
     - **GRANDE + FALHOU/PARCIALMENTE**: NÃO commitar.
   - Se pre-commit hooks existem, deixe-os rodar. NÃO usar `--no-verify`.

8. **Push**
   - Só executar se etapa 7 criou commit.
   - Verificar upstream. Se não existe, `git push -u origin HEAD`. Senão, `git push`.
   - NUNCA `--force` sem pedido explícito. Nunca force em `master`/`main`.
   - Se divergência com remoto, parar e perguntar.

## Restrições obrigatórias

- Não criar feature/página/componente novo fora do escopo.
- Não modificar arquivos em `docs/ai/`.
- Não hardcodar credenciais, API keys ou secrets.
- Não pular etapas (exceto via classificação PEQUENA -> direto etapa 7).
- Não remover assertion ou maquiar teste.
- Não aprovar build quebrado.
- Se o fluxo exige backend real indisponível, registrar divergência e propor mock.
- Respeitar hierarquia: 1) CLAUDE.md, 2) ARCHITECTURE.md, 3) CODING_STANDARDS.md, 4) FEATURE_GUIDE.md, 5) DESIGN_SYSTEM.md, 6) TESTING_GUIDE.md.
