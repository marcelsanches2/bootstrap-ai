---
description: Valida um fluxo E2E fullstack garantindo massa deterministica, testes de componente, integracao de API, verificacao de contrato, migration e relatorio atualizado.
---

# /jarvis-test-flow

Valida um fluxo end-to-end do app fullstack {{PROJECT_NAME}} (React frontend + Node.js backend no mesmo repositório). Argumento opcional: `flow_id` (ex.: `user_auth`, `product_list`, `checkout_flow`, `webhook_handler`).

O pipeline cobre ambas as camadas — frontend (componente, a11y, UI) e backend (API, DB, contrato) — em uma execução unificada.

---

## Guard: greenfield

- Antes de iniciar a etapa 0, verificar se o projeto possui código-fonte relevante:
  - Checar existência de arquivos em `src/`, `app/`, `test/`, `prisma/`.
  - Se o projeto acabou de ser inicializado e **não possui arquivos de código-fonte**, **parar na etapa 0** e reportar:
    ```
    GREENFIELD — projeto sem código-fonte. Pipeline não aplicável.
    Commitar infrastructure e rodar test-flow após primeira feature.
    ```
  - Este guard previne execução do pipeline em projetos vazios onde todo comando falharia por falta de contexto.

---

## Sequência obrigatória

### 0. Avaliar tamanho da task

- Inspecionar `git diff --stat HEAD` e a natureza dos arquivos tocados.
- **Diretórios/arquivos monitorados**: `src/`, `public/`, `test/`, `prisma/`, `migrations/`, `package.json`, `tsconfig.json`, `*.config.*`.
- **GRANDE** (rodar pipeline completo, etapas 1-8):
  - Nova página/rota (frontend ou backend).
  - Novo componente de feature.
  - Novo endpoint de API.
  - Nova entidade/model.
  - Mudança em migration.
  - Integração de API nova (frontend consumindo novo endpoint ou backend integrando serviço externo).
  - Mudança em estado global.
  - Mudança em design system.
  - Formulário complexo.
  - Mudança em schema/interface que afeta contrato entre frontend e backend.
  - Novo service/usecase.
  - Mudança em regra de negócio.
  - Mudança que afeta fluxo do usuário ponta a ponta.
- **PEQUENA** (pular para etapa 7):
  - Typo.
  - Ajuste de CSS isolado.
  - Ajuste de log.
  - Formatação.
  - Comentário.
  - Ajuste fino em config sem mudança de comportamento.
  - Refactor sem mudança de comportamento observável.
  - Ajuste de cópia/texto.
  - Ajuste de tipos sem mudança de lógica.
- **Em dúvida**: perguntar ao usuário antes de classificar (uma frase: "task X — pequena ou grande?"). **Não chutar.**
- Reportar a classificação numa linha antes de prosseguir (ex: `task: PEQUENA — só ajuste de cor no botão`).

---

### 1. Determinar o `flow_id`

- Se foi passado como argumento, usar diretamente.
- Se não, inferir pelo `git diff --name-only HEAD` (qual página/feature/módulo foi tocado).
- **Mapeamento de caminhos**:
  - Frontend:
    - `src/features/<X>/` → `<X>_*` flow
    - `src/app/<X>/` → `<X>_*` flow
    - `app/<X>/` (Next.js App Router) → `<X>_*` flow
  - Backend:
    - `src/routes/<X>.ts` → `<X>_*` flow
    - `src/server/routes/<X>.ts` → `<X>_*` flow
    - `src/<module>/` → `<module>_*` flow
- **Se ambíguo** (touch em frontend E backend de módulos diferentes, ou múltiplos módulos), perguntar ao usuário antes de seguir. Não assumir.
- O `flow_id` será usado para:
  - Localizar massa/fixtures.
  - Localizar testes.
  - Nomear o relatório (`docs/test_report_{flow_id}.md`).
  - Compor mensagem de commit.

---

### 2. Inventariar massa (mocks + fixtures determinísticos)

- Localizar toda a massa de dados que cobre o `flow_id` — **união de frontend e backend**:
  - **Frontend (mock API)**:
    - `src/mocks/*.ts` — handlers MSW ou jest.mock
    - `src/__mocks__/*.ts` — mocks manuais
    - `msw/handlers/*.ts` ou `src/mocks/handlers/*.ts` — handlers MSW organizados
  - **Backend (test DB / fixtures)**:
    - `test/fixtures/*.ts` — dados estáticos para testes
    - `test/factories/*.ts` — factories de entidades
    - `prisma/seed.ts` — seed do banco
    - `src/seed/*.ts` — seeds alternativos
    - `test/**/helpers/*.ts` — helpers de setup/teardown
- **Validação cruzada**:
  - Cruzar dados esperados com asserts dos testes em `src/` e `test/`.
  - Garantir que os dados mockados no frontend são consistentes com o contrato real do backend (schema, tipos, campos).
- **Se faltar massa**:
  - Criar mock/handler/fixture determinístico seguindo `docs/ai/TESTING_GUIDE.md` e `docs/ai/ARCHITECTURE.md`.
  - Sem random (usar valores fixos e previsíveis).
  - Sem chamada de rede real.
  - Sem `setTimeout` em teste.
- **Garantias obrigatórias**:
  - Testes **frontend** usam mock da API (MSW, jest.mock, etc) e **nunca** chamam backend real.
  - Testes **backend** usam banco de teste (SQLite in-memory, test database, ou container efêmero) e **nunca** o banco de produção/desenvolvimento.
  - Environment vars sobrescritas para ambiente de teste: `NODE_ENV=test`, `DATABASE_URL=test_*`, etc.

---

### 3. Inventariar teste

- Procurar testes que cubram o `flow_id` — **união de frontend e backend**:
  - **Frontend**: `src/**/{flow_id}*.test.{ts,tsx}`
    - Deve cobrir: caminho feliz, loading states, error states, empty states, validação de formulário, navegação, acessibilidade (a11y).
  - **Backend**: `test/**/{flow_id}*.test.ts` ou `test/**/{module}*.test.ts`
    - Deve cobrir: caminho feliz, cenários de erro, validação de input, status codes corretos.
- **Verificar revisão prévia**:
  - Checar se existe relatório de revisão (`plans/*_revisao.md`, `docs/revisao_*.md` ou similar) gerado pelo `/jarvis-plan-revisor` para o mesmo fluxo.
  - Se existir, extrair os **Cenários E2E sugeridos** da seção correspondente e considerá-los como **requisitos mínimos de cobertura** além dos cenários próprios do test-flow.
  - Se não existir, prosseguir normalmente.
- **Se não existir teste**:
  - Criar seguindo `docs/ai/TESTING_GUIDE.md` com o runner configurado (jest, vitest).
  - Frontend: usar Testing Library + mocks determinísticos. Cobrir renderização, interação, estados de UI.
  - Backend: usar supertest ou equivalente + fixtures determinísticas. Cobrir endpoints, validação, erros.
- **Validação final**:
  - Confirmar que o teste cobre as etapas críticas do flow.
  - Confirmar que usa os dados determinísticos da massa inventariada.
  - Confirmar que não depende de estado externo (rede, relógio, ordem de execução).

---

### 4. Executar o pipeline (fullstack)

- **Detectar package manager** por lockfile:
  - `pnpm-lock.yaml` → pnpm
  - `yarn.lock` → yarn
  - `bun.lockb` → bun
  - Senão → npm
- **Detectar scripts** disponíveis em `package.json`.
- **Executar na seguinte ordem** (cada passo depende do anterior):

  | # | Comando | Condição | Falha bloqueia? |
  |---|---------|----------|-----------------|
  | 1 | `[pkg-manager] install` | Se houve mudança em `dependencies` no `package.json` | Sim |
  | 2 | `[pkg-manager] run lint` | Se existir script `lint` | Sim — bloqueia se introduzir erros novos |
  | 3 | `npx tsc --noEmit` ou `run typecheck` | Sempre (ou se existir script `typecheck`) | Sim — bloqueia se introduzir erros de tipo novos |
  | 4 | `npx vitest run` ou `[pkg-manager] test` | Sempre (unit + component tests) | Sim — bloqueia se quebrar |
  | 5 | `npx vitest run --config vitest.config.integration.ts` | Se existir config de integração, ou filtrar por suíte | Sim — bloqueia se quebrar |
  | 6 | `npx playwright test` ou `run test:e2e` | Se existirem testes E2E (Playwright/Cypress) | Sim — bloqueia se quebrar |
  | 7 | `npx prisma validate && npx prisma migrate status` | Se diretório `prisma/` existe | Sim — bloqueia se migration divergente |
  | 8 | `[pkg-manager] run build` | Sempre (production build) | Sim — bloqueia se quebrar |
  | 9 | `curl -sf http://localhost:3000/api/health` ou script documentado | Se houver server rodando | Não — reporta warning |

- **Regras de execução**:
  - Se qualquer comando falhar, entrar no **loop de diagnóstico (etapa 4a)** antes de prosseguir.
  - Não maquiar, não silenciar warning, não remover assertion.
  - Não pular steps intermediários mesmo se "parecer simples".
  - Registrar resultado de cada comando no relatório (etapa 5).

---

### 4a. Loop de diagnóstico e correção

Acionado quando algo na etapa 4 ou no pre-commit hook da etapa 7 falha.

#### Diagnóstico

- Ler atentamente a **saída de erro completa**.
- Classificar a causa em uma das categorias:

  | Categoria | Descrição | Exemplos |
  |-----------|-----------|----------|
  | `ambiente` | Infraestrutura local quebrada | Node version incorreta, `node_modules` corrompido, dependência ausente, cache corrompido, navegador/Playwright não instalado, Docker quebrado |
  | `mock/massa` | Dados de teste inconsistentes | Dado determinístico faltando, divergência entre mock/seed e assertion, handler MSW não cobre endpoint, mock desatualizado vs contrato real, factory mal configurada, fixture com side effect |
  | `teste` | Problema na estrutura do teste | Assertion inválida, seletor quebrado (`data-testid` removido), `act()` warning, async sem `waitFor`, mock no lugar errado, timeout, teste dependente de ordem, teardown/cleanup incompleto, snapshot desatualizado |
  | `código` | Regressão real na aplicação | Componente não renderiza, hook com dependência errada, estado inconsistente, prop faltando, contrato quebrado, exception não tratada, lógica errada, retorno inesperado |
  | `tipagem` | Erro de tipo TypeScript | `any` onde não deveria, `@ts-ignore` escondendo bug, interface desatualizada vs implementação, tipo assertion insegura (`as`) |
  | `build` | Falha no build de produção | Import não resolvido, chunk error, env variable faltando, circular dependency, CSS module quebrado |
  | `acessibilidade` | Violação de a11y | Contraste insuficiente, label faltando em input, aria attribute incorreto, foco perdido em modal/dialog |
  | `migration` | Problema no schema/ORM | Schema divergente entre models e banco, constraint violada, dado existente incompatível, migration faltando ou fora de ordem |
  | `contrato` | Inconsistência frontend↔backend | Payload divergindo entre test e implementação, status code errado, campo faltando na response, validação de input inconsistente |

#### Planejamento

- Escrever **1-3 frases** descrevendo:
  - (a) Qual é a causa-raiz hipotética.
  - (b) Qual a correção mínima proposta.
  - (c) Qual arquivo será tocado.
- **Não começar a editar sem isso.** Se não conseguir formular hipótese, escalar imediatamente.

#### Correção

- Aplicar **somente a correção mínima planejada**.
- Sem refactor adicional, sem "limpar de quebra", sem alteração cosmética.

#### Re-execução

- Executar de novo o(s) comando(s) que falhou(aram), na mesma ordem da etapa 4.
- Se passar, registrar no relatório e prosseguir.

#### Limites e escalação

- **Limite de 3 tentativas por causa-raiz**.
  - Se a mesma causa reaparecer ao 3º ciclo → parar e escalar.
  - Se a correção exigir mudanças fora do escopo da task original (refatorar estado global, criar página/endpoint novo) → parar e escalar.
- **Critérios para parar e escalar imediatamente** (sem esperar 3 tentativas):
  - A correção exigiria modificar `docs/ai/*` ou outro arquivo proibido pelas restrições.
  - A correção exigiria criar página/componente/endpoint/service/model fora do escopo do `flow_id`.
  - O erro indica problema de infraestrutura (build tool quebrado, banco não sobe, dependência não instala).
  - Tentativas anteriores divergem (causa muda a cada rodada → sinal de diagnóstico raso).
- **Ao escalar**, reportar: causa observada, o que foi tentado, próxima hipótese.

#### Registro

- Registrar **todas** as causas e correções tentadas na tabela "Problemas encontrados / correções" do report (etapa 5), **inclusive em caso de PASSOU**.
- Isso garante rastreabilidade: mesmo que passou, fica documentado o que foi corrigido.

---

### 5. Gerar relatório

- Escrever ou atualizar `docs/test_report_{flow_id}.md` com as seções:

  ```
  # Test Report: {flow_id}

  ## Meta
  - **Data**: <timestamp>
  - **Branch**: <git branch>
  - **Classificação**: GRANDE / PEQUENA
  - **Estratégia**: <descrição da abordagem>
  - **Package manager**: <detectado>

  ## Ferramentas detectadas
  | Ferramenta | Detectada? | Versão |
  |------------|-----------|--------|
  | Linter     |           |        |
  | Typechecker|           |        |
  | Test runner|           |        |
  | E2E runner |           |        |
  | ORM        |           |        |
  | Build tool |           |        |

  ## Massa criada/validada
  | Tipo | Arquivo | Status | Dados usados |
  |------|---------|--------|--------------|
  | Mock API (frontend) | ... | ... | ... |
  | Fixture (backend)   | ... | ... | ... |
  | Seed DB             | ... | ... | ... |

  ## Comandos executados
  | # | Comando | Resultado | Tempo |
  |---|---------|-----------|-------|
  | 1 | npm install | ✅ PASS | 12s |
  | 2 | npm run lint | ✅ PASS | 3s |
  | ... | ... | ... | ... |

  ## Fluxo validado
  | Etapa | Validação | Resultado |
  |-------|-----------|-----------|
  | Install | Dependencies instaladas | ✅ |
  | Lint    | Sem erros novos | ✅ |
  | Typecheck | Sem erros de tipo | ✅ |
  | Unit/Component | Testes passam | ✅ |
  | Integration | Testes passam | ✅ |
  | E2E | Testes passam | ✅ |
  | Migration | Schema válido | ✅ |
  | Build | Production build ok | ✅ |
  | Healthcheck | Server responde | ⚠️ |

  ## Problemas encontrados / correções
  | Causa | Correção | Tentativa | Resultado |
  |-------|----------|-----------|-----------|
  | (vazio se sem problemas) | | | |

  ## Status final
  **PASSOU** / **PASSOU PARCIALMENTE** / **FALHOU**

  ## Arquivos criados/modificados
  - `src/features/...`
  - `test/...`

  ## Como rodar de novo
  ```bash
  npm install && npm run lint && npx tsc --noEmit && npm test && npm run build
  ```
  ```

- O relatório deve ser **completo e honesto**. Não omitir falhas intermediárias.

---

### 6. Encerrar

- Reportar **uma linha de resumo** no formato:
  ```
  ✅ test-flow({flow_id}): PASSOU — 9 steps, 2 correções — docs/test_report_{flow_id}.md
  ```
  ou
  ```
  ⚠️ test-flow({flow_id}): PASSOU PARCIALMENTE — healthcheck falhou — docs/test_report_{flow_id}.md
  ```
  ou
  ```
  ❌ test-flow({flow_id}): FALHOU — build quebrou após 3 tentativas — docs/test_report_{flow_id}.md
  ```
- Incluir caminho do relatório para referência rápida.

---

### 7. Commit

- **Stage arquivos**:
  ```
  git add src/ public/ test/ prisma/ migrations/ docs/ package.json tsconfig.json [pnpm-lock.yaml|yarn.lock|bun.lockb|package-lock.json]
  ```
- **Se nada foi staged** (`git diff --cached --quiet`): **pular o commit**.
- **Mensagem do commit** (conforme classificação):
  - **PEQUENA**: `chore: <descrição curta>` (ex: `chore: ajusta cor do botão no header`).
  - **GRANDE + PASSOU**: `feat|fix|refactor: <descrição> + test {flow_id}` conforme natureza da mudança.
  - **GRANDE + PASSOU PARCIALMENTE / FALHOU**: **NÃO commitar**. Reportar e devolver para correção.
- **Pre-commit hooks**:
  - O commit pode disparar pre-commit hooks (lint, typecheck, test).
  - Se quebrar, **NÃO usar `--no-verify`** — entrar no loop de diagnóstico (etapa 4a), corrigir, e tentar o commit de novo.
  - Aplicam-se os mesmos limites de tentativas e escalação da etapa 4a.

---

### 8. Push

- **Pré-condição**: só executar se a etapa 7 efetivamente criou um novo commit.
  - Se foi pulada (nada staged) ou bloqueada (GRANDE + falha): **NÃO empurrar**.
- **Verificar upstream**:
  - Se `git rev-parse --abbrev-ref --symbolic-full-name @{u}` falhar: `git push -u origin HEAD`.
  - Caso contrário: `git push`.
- **Regras de força**:
  - **NUNCA** usar `--force` ou `--force-with-lease` aqui.
  - Push de force só com pedido explícito do usuário e **nunca** em `master`/`main`.
- **Se o push falhar por divergência** (`non-fast-forward`):
  - **Parar, reportar e perguntar** antes de qualquer rebase/merge.
  - Não assumir estratégia de resolução.

---

## Prioridade de referência

Ao resolver conflitos de orientação entre documentos, seguir esta hierarquia:

1. `CLAUDE.md` — contrato principal do projeto
2. `docs/ai/ARCHITECTURE.md` — estrutura e camadas
3. `docs/ai/CODING_STANDARDS.md` — padrões de código
4. `docs/ai/FEATURE_GUIDE.md` — guia de features
5. `docs/ai/API_GUIDE.md` — contratos de API
6. `docs/ai/DESIGN_SYSTEM.md` — sistema de design
7. `docs/ai/TESTING_GUIDE.md` — padrões de teste

Em caso de conflito, o documento de prioridade mais alta prevalece.

---

## Restrições obrigatórias

- **Não** criar feature/página/componente/endpoint novo fora do escopo do `flow_id`.
- **Não** modificar arquivos em `docs/ai/`.
- **Não** hardcodar credenciais, API keys ou secrets.
- **Não** pular etapas dentro de uma execução completa (1-6) mesmo se "parecer simples". A única forma legítima de pular é via etapa 0 (classificada PEQUENA), que vai direto para a etapa 7.
- **Não** remover assertion ou maquiar teste só para passar.
- **Não** aprovar build quebrado.
- Se o fluxo exige backend real indisponível, registrar divergência e propor mock/handler determinístico.
- Se o fluxo exige serviço externo indisponível, registrar a divergência e propor mock/stub determinístico.
- Respeitar a hierarquia de prioridade dos documentos de referência.
