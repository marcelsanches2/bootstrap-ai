---
description: Valida um fluxo E2E garantindo massa deterministica, testes de componente, verificacao de acessibilidade e relatorio atualizado.
---

# /jarvis-test-flow

Valida um fluxo end-to-end do app React Web {{PROJECT_NAME}}. Argumento opcional: `flow_id` (ex.: `user_login`, `product_list`, `checkout_flow`).

## Sequencia obrigatoria

0. **Avaliar tamanho da task**
   - Inspecionar `git diff --stat HEAD` e a natureza dos arquivos tocados em `src/`, `public/`, `package.json`, `tsconfig.json`, `*.config.*`.
   - **GRANDE** (rodar pipeline completo, etapas 1-8): nova pagina/rota, novo componente de feature, mudanca em estado global, integracao de API nova, mudanca em design system, formulario complexo, mudanca que afeta fluxo do usuario ponta a ponta.
   - **PEQUENA** (pular para etapa 7): typo, ajuste de CSS isolado, comentario, ajuste fino em componente sem mudanca de comportamento, refactor sem mudanca de comportamento observavel, ajuste de copia/texto.
   - **Em duvida**: perguntar ao usuario antes de classificar (uma frase: "task X — pequena ou grande?"). Nao chutar.
   - Reportar a classificacao numa linha antes de prosseguir (ex: `task: PEQUENA — so ajuste de cor no botao`).

1. **Determinar o `flow_id`**
   - Se foi passado como argumento, usar.
   - Se nao, inferir pelo `git diff --name-only HEAD` (qual pagina/feature foi tocada). Mapear `src/pages/<X>/` ou `src/features/<X>/` -> `<X>_*` flow. Se ambiguo, perguntar ao usuario antes de seguir.

2. **Inventariar massa (mocks deterministicos)**
   - Localizar mocks/handlers que cobrem o flow_id:
     - `src/mocks/*.ts`
     - `src/__mocks__/*.ts`
     - `msw/handlers/*.ts` ou `src/mocks/handlers/*.ts`
     - `test/fixtures/*.ts`
     - `test/factories/*.ts`
   - Validar que os dados esperados existem (cruzar com asserts dos testes em `src/` e `test/`).
   - Se faltar massa, criar mock/handler deterministico seguindo `docs/ai/TESTING_GUIDE.md` e `docs/ai/ARCHITECTURE.md`. Sem random (usar valores fixos), sem chamada de rede real, sem `setTimeout` em teste.
   - Garantir que testes usam mock da API (MSW, jest.mock, etc) e nunca chamam backend real.
   - Garantir que environment vars estao sobrescritas para ambiente de teste se necessario.

3. **Inventariar teste**
   - Procurar `src/**/{flow_id}*.test.{ts,tsx}` ou `test/**/{flow_id}*.test.{ts,tsx}` que cubra o flow.
   - Verificar se existe um relatorio de revisao (`plans/*_revisao.md`, `docs/revisao_*.md` ou similar) gerado pelo `/jarvis-plan-revisor` para o mesmo fluxo. Se existir, extrair os **Cenarios E2E sugeridos** da secao correspondente e considera-los como requisitos minimos de cobertura alem dos cenarios proprios do test-flow.
   - Se nao existir, prosseguir normalmente.
   - Se nao existir teste, criar seguindo `docs/ai/TESTING_GUIDE.md` com o runner configurado (jest, vitest) e Testing Library. Usar mocks deterministicos. Teste deve cobrir: caminho feliz, loading states, error states, empty states, validacao de formulario, navegacao.
   - Validar que o teste cobre as etapas criticas e usa os dados deterministicos da massa.

4. **Executar o pipeline**
   - Detectar package manager por lockfile: `pnpm-lock.yaml` -> pnpm, `yarn.lock` -> yarn, `bun.lockb` -> bun, senao npm.
   - Detectar scripts disponiveis em `package.json`.
   - Rodar na seguinte ordem:
     - `[pkg-manager] install` (se houve mudanca em dependencies no `package.json`).
     - `[pkg-manager] run lint` (se existir script lint) — bloqueia se introduzir erros novos.
     - `npx tsc --noEmit` ou `[pkg-manager] run typecheck` (se existir) — bloqueia se introduzir erros de tipo novos.
     - `[pkg-manager] test` (unit + component tests) — bloqueia se quebrar.
     - `[pkg-manager] run test:e2e` (se existirem testes e2e com Playwright/Cypress) — bloqueia se quebrar.
     - `[pkg-manager] run build` (production build) — bloqueia se quebrar.
     - Lighthouse/axe audit, se configurado — nao bloqueia mas reporta warnings.
   - **Se qualquer comando falhar, entrar no loop de diagnostico (etapa 4a) antes de prosseguir.** Nao maquiar, nao silenciar warning, nao remover assertion.

4a. **Loop de diagnostico e correcao** (acionado quando algo na etapa 4 ou no pre-commit hook da etapa 7 falha)
   - **Diagnosticar**: ler atentamente a saida de erro completa. Classificar a causa em uma das categorias:
     - `ambiente`: Node version incorreta, node_modules corrompido, dependencia ausente, cache corrompido, navegador/Playwright nao instalado.
     - `mock/massa`: dado deterministico faltando, divergencia entre mock e assertion, handler MSW nao cobre endpoint esperado, mock desatualizado vs contrato real da API.
     - `teste`: assertion invalida, seletor quebrado (data-testid removido), `act()` warning, async sem `waitFor`, snapshot desatualizado, teste dependente de ordem, cleanup incompleto.
     - `codigo`: regressao real introduzida pela mudanca da task, componente nao renderiza, hook com dependencia errada, estado inconsistente, prop faltando.
     - `tipagem`: `any` onde nao deveria, `@ts-ignore` escondendo bug, interface de props desatualizada, tipo assertion insegura (`as`).
     - `build`: import nao resolvido, chunk error, env variable faltando no build, circular dependency, CSS module quebrado.
     - `acessibilidade`: contraste insuficiente, label faltando em input, aria attribute incorreto, foco perdido em modal/dialog.
   - **Planejar**: escrever 1-3 frases descrevendo: (a) qual e a causa-raiz hipotetica, (b) qual a correcao minima proposta, (c) qual arquivo sera tocado. Nao comecar a editar sem isso.
   - **Corrigir**: aplicar somente a correcao minima planejada. Sem refactor adicional, sem "limpar de quebra".
   - **Re-rodar**: executar de novo o(s) comando(s) que falhou(aram), na mesma ordem da etapa 4.
   - **Limite de 3 tentativas por causa-raiz**. Se a mesma causa reaparecer ao 3 ciclo, ou se a correcao exigir mudancas fora do escopo da task original (ex.: refatorar estado global, criar pagina nova), parar e escalar para o usuario com: causa observada, o que foi tentado, proxima hipotese.
   - **Criterios para parar e escalar imediatamente** (sem esperar 3 tentativas):
     - A correcao exigiria modificar `docs/ai/*` ou outro arquivo proibido pelas restricoes.
     - A correcao exigiria criar pagina/componente/rota fora do escopo do flow_id.
     - O erro indica problema de infraestrutura (build tool quebrado, dependencia nao instala).
     - Tentativas anteriores divergem (causa muda a cada rodada -> sinal de que o diagnostico esta raso).
   - Registrar todas as causas e correcoes tentadas na tabela "Problemas encontrados / correcoes" do report (etapa 5), inclusive em caso de PASSOU.

5. **Gerar relatorio**
   - Escrever ou atualizar `docs/test_report_{flow_id}.md` com:
     - Data, branch, classificacao (GRANDE/PEQUENA), estrategia, package manager detectado
     - Ferramentas detectadas (linter, typechecker, test runner, e2e runner, build tool)
     - Massa criada/validada (tabela com mocks, handlers, dados usados)
     - Comandos executados (tabela: comando, resultado)
     - Fluxo validado (tabela: etapa, validacao)
     - Problemas encontrados / correcoes (tabela: causa, correcao)
     - Status final: **PASSOU**, **PASSOU PARCIALMENTE**, ou **FALHOU**
     - Arquivos criados/modificados
     - Como rodar de novo

6. **Encerrar**
   - Reportar uma linha de resumo + caminho do relatorio em `docs/`.

7. **Commit**
   - Executar `git add src/ public/ docs/ package.json tsconfig.json [pnpm-lock.yaml|yarn.lock|bun.lockb|package-lock.json]`.
   - Se nada foi staged (`git diff --cached --quiet`), pular o commit.
   - Mensagem do commit:
     - **PEQUENA**: `chore: <descricao curta da mudanca>` (ex: `chore: ajusta cor do botao no header`).
     - **GRANDE + PASSOU**: `feat|fix|refactor: <descricao> + test {flow_id}` conforme natureza da mudanca.
     - **GRANDE + PASSOU PARCIALMENTE / FALHOU**: NAO commitar. Reportar e devolver para correcao.
   - O commit pode disparar pre-commit hooks (lint, typecheck, test). Se quebrar, NAO usar `--no-verify` — entrar no loop de diagnostico (etapa 4a), corrigir, e tentar o commit de novo.

8. **Push**
   - So executar se a etapa 7 efetivamente criou um novo commit. Se foi pulada (nada staged) ou bloqueada (GRANDE + falha), NAO empurrar.
   - Confirmar que a branch atual tem upstream: se `git rev-parse --abbrev-ref --symbolic-full-name @{u}` falhar, usar `git push -u origin HEAD`. Caso contrario, `git push`.
   - NUNCA usar `--force` ou `--force-with-lease` aqui. Push de force so com pedido explicito do usuario e nunca em `master`/`main`.
   - Se o push falhar por divergencia com o remoto (`non-fast-forward`), parar, reportar e perguntar antes de qualquer rebase/merge.

## Restricoes obrigatorias

- Nao criar feature/pagina/componente novo fora do escopo do flow.
- Nao modificar arquivos em `docs/ai/`.
- Nao hardcodar credenciais, API keys ou secrets.
- Nao pular etapas dentro de uma execucao completa (1-6) mesmo se "parecer simples". A unica forma legitima de pular e via etapa 0 (classificada PEQUENA), que vai direto para a etapa 7.
- Nao remover assertion ou maquiar teste so para passar.
- Nao aprovar build quebrado.
- Se o fluxo exige backend real indisponivel, registrar divergencia e propor mock/handler deterministico.
- Respeitar a hierarquia de prioridade do `CLAUDE.md`: 1) CLAUDE.md, 2) ARCHITECTURE.md, 3) CODING_STANDARDS.md, 4) FEATURE_GUIDE.md, 5) DESIGN_SYSTEM.md, 6) TESTING_GUIDE.md.
