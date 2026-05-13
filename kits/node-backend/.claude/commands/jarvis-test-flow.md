---
description: Valida um fluxo E2E garantindo massa deterministica, testes de integracao, verificacao de contrato API e relatorio atualizado.
---

# /jarvis-test-flow

Valida um fluxo end-to-end do backend Node.js/TypeScript {{PROJECT_NAME}}. Argumento opcional: `flow_id` (ex.: `user_auth`, `order_processing`, `webhook_handler`).

## Sequencia obrigatoria

0. **Avaliar tamanho da task**
   - Inspecionar `git diff --stat HEAD` e a natureza dos arquivos tocados em `src/`, `test/`, `prisma/`, `migrations/`, `package.json`, `tsconfig.json`.
   - **GRANDE** (rodar pipeline completo, etapas 1-8): novo endpoint, nova entidade/model, mudanca em migration, integracao externa, mudanca em schema/interface, novo service/usecase, mudanca em regra de negocio, mudanca que afeta fluxo do usuario ponta a ponta.
   - **PEQUENA** (pular para etapa 7): typo, ajuste de log, formatacao, comentario, ajuste fino em config sem mudanca de comportamento, refactor sem mudanca de comportamento observavel, ajuste de tipos sem mudanca de logica.
   - **Em duvida**: perguntar ao usuario antes de classificar (uma frase: "task X — pequena ou grande?"). Nao chutar.
   - Reportar a classificacao numa linha antes de prosseguir (ex: `task: PEQUENA — so ajuste de log em service.ts`).

1. **Determinar o `flow_id`**
   - Se foi passado como argumento, usar.
   - Se nao, inferir pelo `git diff --name-only HEAD` (qual modulo/feature foi tocada). Mapear `src/<module>/` ou `src/routes/<X>.ts` -> `<X>_*` flow. Se ambiguo, perguntar ao usuario antes de seguir.

2. **Inventariar massa (fixtures/seeds deterministicos)**
   - Localizar fixtures/seeds que cobrem o flow_id:
     - `test/fixtures/*.ts`
     - `test/factories/*.ts`
     - `prisma/seed.ts`
     - `src/seed/*.ts`
     - `test/**/helpers/*.ts`
   - Validar que os dados esperados existem (cruzar com asserts dos testes em `test/`).
   - Se faltar massa, criar fixture/seed deterministico seguindo `docs/ai/TESTING_GUIDE.md` e `docs/ai/ARCHITECTURE.md`. Sem random (usar valores fixos), sem chamada de rede real, sem `setTimeout` em teste.
   - Garantir que testes usam banco de teste (SQLite in-memory, test database, ou container efemero) e nunca o banco de producao/desenvolvimento.
   - Garantir que env vars estao sobrescritas para ambiente de teste (`NODE_ENV=test`, `DATABASE_URL=test_*`, etc).

3. **Inventariar teste**
   - Procurar `test/**/{flow_id}*.test.ts` ou `test/**/{module}*.test.ts` que cubra o flow.
   - Verificar se existe um relatorio de revisao (`plans/*_revisao.md`, `docs/revisao_*.md` ou similar) gerado pelo `/jarvis-revisor` para o mesmo fluxo. Se existir, extrair os **Cenarios E2E sugeridos** da secao correspondente e considera-los como requisitos minimos de cobertura alem dos cenarios proprios do test-flow.
   - Se nao existir, prosseguir normalmente.
   - Se nao existir teste, criar seguindo `docs/ai/TESTING_GUIDE.md` com o runner configurado (jest, vitest, ou mocha). Usar fixtures deterministicas. Teste deve cobrir: caminho feliz, cenarios de erro, validacao de input, status codes corretos.
   - Validar que o teste cobre as etapas criticas e usa os dados deterministicos da massa.

4. **Executar o pipeline**
   - Detectar package manager por lockfile: `pnpm-lock.yaml` -> pnpm, `yarn.lock` -> yarn, `bun.lockb` -> bun, senao npm.
   - Detectar scripts disponiveis em `package.json`.
   - Rodar na seguinte ordem:
     - `[pkg-manager] install` (se houve mudanca em dependencies no `package.json`).
     - `[pkg-manager] run lint` (se existir script lint) — bloqueia se introduzir erros novos.
     - `npx tsc --noEmit` ou `[pkg-manager] run typecheck` (se existir) — bloqueia se introduzir erros de tipo novos.
     - `[pkg-manager] test` (unit + integration) — bloqueia se quebrar.
     - Validacao de migration/ORM, se aplicavel: `npx prisma migrate status` ou `npx typeorm migration:run` — bloqueia se migration estiver divergente.
     - `[pkg-manager] run build` (production build) — bloqueia se quebrar.
     - Healthcheck local, se houver comando documentado (ex: `npm run healthcheck`, `curl localhost:3000/health`).
   - **Se qualquer comando falhar, entrar no loop de diagnostico (etapa 4a) antes de prosseguir.** Nao maquiar, nao silenciar warning, nao remover assertion.

4a. **Loop de diagnostico e correcao** (acionado quando algo na etapa 4 ou no pre-commit hook da etapa 7 falha)
   - **Diagnosticar**: ler atentamente a saida de erro completa. Classificar a causa em uma das categorias:
     - `ambiente`: Node version incorreta, node_modules corrompido, dependencia ausente, cache corrompido, ferramenta nao instalada globalmente.
     - `fixture/massa`: dado deterministico faltando, divergencia entre seed e assertion, factory mal configurada, fixture com side effect entre testes.
     - `teste`: assertion invalida, mock mal configurado (`jest.mock` no lugar errado), timeout, teste dependente de ordem, teardown incompleto, snapshot desatualizado.
     - `codigo`: regressao real introduzida pela mudanca da task, contrato quebrado (interface, tipo), exception nao tratada, logica errada, retorno inesperado.
     - `migration`: schema divergente entre models e banco, constraint violada, dado existente incompativel com novo schema, migration faltando ou fora de ordem.
     - `tipagem`: `any` onde nao deveria, `@ts-ignore` escondendo bug, interface desatualizada vs implementacao, tipo assertion insegura (`as`).
     - `contrato`: payload divergindo entre test e implementacao, status code errado, campo faltando na response, validacao de input inconsistente.
   - **Planejar**: escrever 1-3 frases descrevendo: (a) qual e a causa-raiz hipotetica, (b) qual a correcao minima proposta, (c) qual arquivo sera tocado. Nao comecar a editar sem isso.
   - **Corrigir**: aplicar somente a correcao minima planejada. Sem refactor adicional, sem "limpar de quebra".
   - **Re-rodar**: executar de novo o(s) comando(s) que falhou(aram), na mesma ordem da etapa 4.
   - **Limite de 3 tentativas por causa-raiz**. Se a mesma causa reaparecer ao 3 ciclo, ou se a correcao exigir mudancas fora do escopo da task original (ex.: refatorar arquitetura, criar endpoint novo), parar e escalar para o usuario com: causa observada, o que foi tentado, proxima hipotese.
   - **Criterios para parar e escalar imediatamente** (sem esperar 3 tentativas):
     - A correcao exigiria modificar `docs/ai/*` ou outro arquivo proibido pelas restricoes.
     - A correcao exigiria criar endpoint/service/model fora do escopo do flow_id.
     - O erro indica problema de infraestrutura (banco nao sobe, dependencia nao instala, Docker quebrado).
     - Tentativas anteriores divergem (causa muda a cada rodada -> sinal de que o diagnostico esta raso).
   - Registrar todas as causas e correcoes tentadas na tabela "Problemas encontrados / correcoes" do report (etapa 5), inclusive em caso de PASSOU.

5. **Gerar relatorio**
   - Escrever ou atualizar `docs/test_report_{flow_id}.md` com:
     - Data, branch, classificacao (GRANDE/PEQUENA), estrategia, package manager detectado
     - Ferramentas detectadas (linter, typechecker, test runner, ORM, build tool)
     - Massa criada/validada (tabela com fixtures, seeds, dados usados)
     - Comandos executados (tabela: comando, resultado)
     - Fluxo validado (tabela: etapa, validacao)
     - Problemas encontrados / correcoes (tabela: causa, correcao)
     - Status final: **PASSOU**, **PASSOU PARCIALMENTE**, ou **FALHOU**
     - Arquivos criados/modificados
     - Como rodar de novo

6. **Encerrar**
   - Reportar uma linha de resumo + caminho do relatorio em `docs/`.

7. **Commit**
   - Executar `git add src/ test/ prisma/ migrations/ docs/ package.json tsconfig.json [pnpm-lock.yaml|yarn.lock|bun.lockb|package-lock.json]`.
   - Se nada foi staged (`git diff --cached --quiet`), pular o commit.
   - Mensagem do commit:
     - **PEQUENA**: `chore: <descricao curta da mudanca>` (ex: `chore: ajusta log level no order service`).
     - **GRANDE + PASSOU**: `feat|fix|refactor: <descricao> + test {flow_id}` conforme natureza da mudanca.
     - **GRANDE + PASSOU PARCIALMENTE / FALHOU**: NAO commitar. Reportar e devolver para correcao.
   - O commit pode disparar pre-commit hooks (lint, typecheck, test). Se quebrar, NAO usar `--no-verify` — entrar no loop de diagnostico (etapa 4a), corrigir, e tentar o commit de novo.

8. **Push**
   - So executar se a etapa 7 efetivamente criou um novo commit. Se foi pulada (nada staged) ou bloqueada (GRANDE + falha), NAO empurrar.
   - Confirmar que a branch atual tem upstream: se `git rev-parse --abbrev-ref --symbolic-full-name @{u}` falhar, usar `git push -u origin HEAD`. Caso contrario, `git push`.
   - NUNCA usar `--force` ou `--force-with-lease` aqui. Push de force so com pedido explicito do usuario e nunca em `master`/`main`.
   - Se o push falhar por divergencia com o remoto (`non-fast-forward`), parar, reportar e perguntar antes de qualquer rebase/merge.

## Restricoes obrigatorias

- Nao criar feature/endpoint novo fora do escopo do flow.
- Nao modificar arquivos em `docs/ai/`.
- Nao hardcodar credenciais ou secrets.
- Nao pular etapas dentro de uma execucao completa (1-6) mesmo se "parecer simples". A unica forma legitima de pular e via etapa 0 (classificada PEQUENA), que vai direto para a etapa 7.
- Nao remover assertion ou maquiar teste so para passar.
- Se o fluxo exigir servico externo indisponivel, registrar a divergencia claramente e propor mock/stub deterministico.
- Respeitar a hierarquia de prioridade do `CLAUDE.md`: 1) CLAUDE.md, 2) ARCHITECTURE.md, 3) CODING_STANDARDS.md, 4) API_GUIDE.md, 5) TESTING_GUIDE.md.
