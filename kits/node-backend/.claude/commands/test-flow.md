---
description: Valida uma alteração em backend Node.js/TypeScript executando lint, typecheck, testes, build e gerando relatório.
---

# /test-flow

Valida uma alteração em backend Node.js/TypeScript. Argumento opcional: `flow_id` (ex.: `user-auth`, `order-processing`).

## Sequência obrigatória

0. **Avaliar tamanho da task**
   - Inspecionar `git diff --stat HEAD` e a natureza dos arquivos tocados em `src/`, `test/`, `package.json`, `tsconfig.json`.
   - **GRANDE** (rodar pipeline completo, etapas 1-8): novo endpoint, nova entidade/model, mudança em migration, integração externa, mudança em schema/interface, novo service/usecase, refatoração de arquitetura.
   - **PEQUENA** (pular para etapa 7): typo, ajuste de log, formatação, comentário, ajuste fino em config, refactor sem mudança de comportamento observável.
   - **Em dúvida**: perguntar ao usuário antes de classificar. Não chutar.
   - Reportar a classificação numa linha antes de prosseguir.

1. **Determinar o `flow_id`**
   - Se foi passado como argumento, usar.
   - Se não, inferir pelo `git diff --name-only HEAD`. Mapear `src/<module>/` -> `<module>_*` flow. Se ambíguo, perguntar.

2. **Inventariar massa (fixtures/seeds determinísticos)**
   - Localizar fixtures/seeds em `test/fixtures/`, `test/factories/`, `prisma/seed.ts`, `src/seed/`.
   - Validar que os dados esperados existem e cobrem o flow_id.
   - Se faltar massa, criar fixture/seed seguindo `docs/ai/TESTING_GUIDE.md`. Sem dados aleatórios, sem chamada de rede real.
   - Garantir que testes usam banco de teste e não o banco de produção/desenvolvimento.

3. **Inventariar teste**
   - Procurar `test/**/<flow_id>*.test.ts` ou `test/**/<module>*.test.ts` que cubra o flow.
   - Verificar se existe relatório de revisão do `/jarvis-revisor`. Se existir, extrair cenários de teste sugeridos como requisitos mínimos.
   - Se não existir teste, criar seguindo `docs/ai/TESTING_GUIDE.md` com o runner configurado (jest/vitest/mocha).
   - Validar cobertura: caminho feliz, cenários de erro, validação de input, status codes.

4. **Executar o pipeline**
   - Detectar package manager por lockfile: `pnpm-lock.yaml` -> pnpm, `yarn.lock` -> yarn, `bun.lockb` -> bun, senão npm.
   - `[pkg-manager] install` (se houve mudança em dependencies)
   - `[pkg-manager] run lint` (se existir script lint)
   - `tsc --noEmit` ou `[pkg-manager] run typecheck` (se existir)
   - `[pkg-manager] test` (unit + integration)
   - Validação de migration/ORM, se aplicável (ex: `prisma migrate status`, `npx typeorm migration:run`)
   - `[pkg-manager] run build` (production build)
   - Healthcheck local, se houver comando documentado
   - **Se qualquer comando falhar, entrar no loop de diagnóstico (etapa 4a).** Não maquiar.

4a. **Loop de diagnóstico e correção** (acionado quando algo na etapa 4 falha)
   - **Diagnosticar**: ler a saída de erro completa. Classificar a causa:
     - `ambiente`: Node version, node_modules corrompido, dependência ausente.
     - `fixture/massa`: dado faltando, divergência entre seed e assertion.
     - `teste`: assertion inválida, mock mal configurado, timeout, teste acoplado a estado.
     - `código`: regressão real, contrato quebrado, lógica errada.
     - `migration`: schema divergente, constraint violada.
     - `tipagem`: erro de tipo que expõe bug de lógica.
   - **Planejar**: 1-3 frases: causa-raiz, correção mínima, arquivo afetado.
   - **Corrigir**: aplicar correção mínima. Sem refactor adicional.
   - **Re-rodar**: executar de novo o(s) comando(s) que falhou(aram).
   - **Limite de 3 tentativas por causa-raiz**. Se reaparecer ao 3º ciclo, escalar.
   - **Parar imediatamente se**: correção exige modificar `docs/ai/*`, criar feature fora do escopo, ou indica problema de infra.

5. **Gerar relatório**
   - Escrever ou atualizar `docs/test_report_<flow_id>.md` com:
     - Data, branch, classificação (GRANDE/PEQUENA), package manager detectado
     - Comandos executados (tabela: comando, resultado)
     - Fixtures/massa criada ou validada
     - Fluxo validado (tabela: etapa, validação)
     - Problemas encontrados / correções (tabela: causa, correção)
     - Status final: **PASSOU**, **PASSOU PARCIALMENTE**, ou **FALHOU**
     - Arquivos criados/modificados
     - Como rodar de novo

6. **Encerrar**
   - Reportar uma linha de resumo + caminho do relatório em `docs/`.

7. **Commit**
   - Executar `git add src/ test/ docs/ package.json [pnpm-lock.yaml|yarn.lock|bun.lockb|package-lock.json]`.
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

- Não criar feature/endpoint novo fora do escopo.
- Não modificar arquivos em `docs/ai/`.
- Não hardcodar credenciais ou secrets.
- Não pular etapas (exceto via classificação PEQUENA -> direto etapa 7).
- Não remover assertion ou maquiar teste.
- Respeitar hierarquia: 1) CLAUDE.md, 2) ARCHITECTURE.md, 3) CODING_STANDARDS.md, 4) API_GUIDE.md, 5) TESTING_GUIDE.md.
