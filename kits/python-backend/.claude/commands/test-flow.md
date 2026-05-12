---
description: Valida uma alteração em backend Python executando lint, typecheck, testes, migrations e gerando relatório.
---

# /test-flow

Valida uma alteração em backend Python. Argumento opcional: `flow_id` (ex.: `user-registration`, `order-checkout`).

## Sequência obrigatória

0. **Avaliar tamanho da task**
   - Inspecionar `git diff --stat HEAD` e a natureza dos arquivos tocados em `src/`, `app/`, `tests/`, `alembic/`, `pyproject.toml`.
   - **GRANDE** (rodar pipeline completo, etapas 1-8): novo endpoint, nova entidade/model, mudança em migration, integração externa, mudança em schema/serializer, novo service/usecase, refatoração de arquitetura.
   - **PEQUENA** (pular para etapa 7): typo, ajuste de log, formatação, comentário, ajuste fino em config, refactor sem mudança de comportamento observável.
   - **Em dúvida**: perguntar ao usuário antes de classificar (uma frase: "task X — pequena ou grande?"). Não chutar.
   - Reportar a classificação numa linha antes de prosseguir (ex: `task: PEQUENA — só ajuste de log em service.py`).

1. **Determinar o `flow_id`**
   - Se foi passado como argumento, usar.
   - Se não, inferir pelo `git diff --name-only HEAD` (qual módulo/feature foi tocada). Mapear `src/<module>/` ou `app/<module>/` -> `<module>_*` flow. Se ambíguo, perguntar ao usuário antes de seguir.

2. **Inventariar massa (fixtures determinísticos)**
   - Localizar fixtures em `tests/conftest.py`, `tests/fixtures/`, `tests/factories/`.
   - Validar que os dados esperados existem e cobrem o flow_id.
   - Se faltar massa, criar fixture/factory seguindo `docs/ai/TESTING_GUIDE.md` e `docs/ai/ARCHITECTURE.md`. Sem dados aleatórios (usar factory determinística ou valores fixos), sem chamada de rede real.
   - Garantir que testes usam banco de teste (SQLite in-memory ou test database) e não o banco de produção/desenvolvimento.

3. **Inventariar teste**
   - Procurar `tests/**/test_<flow_id>*.py` ou `tests/**/test_<module>*.py` que cubra o flow.
   - Verificar se existe um relatório de revisão (`plans/*_revisao.md` ou similar) gerado pelo `/jarvis-revisor` para o mesmo fluxo. Se existir, extrair os **Cenários de teste sugeridos** da seção correspondente e considerá-los como requisitos mínimos de cobertura.
   - Se não existir teste, criar seguindo `docs/ai/TESTING_GUIDE.md`. Usar `pytest` com fixtures determinísticas.
   - Validar que o teste cobre: caminho feliz, cenários de erro, validação de input, status codes corretos.

4. **Executar o pipeline**
   - `ruff format --check .` (ou `black --check .` se o projeto usa Black)
   - `ruff check .` (ou `flake8` se configurado)
   - `mypy .` (ou `pyright` se configurado)
   - `pytest` — com coverage se configurado (`--cov`)
   - `alembic check` ou validação de migration, se Alembic existir
   - Healthcheck local, se houver comando documentado (ex: `make healthcheck`, `curl localhost:8000/health`)
   - **Se qualquer comando falhar, entrar no loop de diagnóstico (etapa 4a) antes de prosseguir.** Não maquiar, não silenciar warning, não remover assertion.

4a. **Loop de diagnóstico e correção** (acionado quando algo na etapa 4 falha)
   - **Diagnosticar**: ler atentamente a saída de erro completa. Classificar a causa em uma das categorias:
     - `ambiente`: Python version, venv não ativado, dependência ausente, cache corrompido.
     - `fixture/massa`: dado determinístico faltando, divergência entre fixture e assertion, factory mal configurada.
     - `teste`: assertion inválida, mock mal configurado, fixture com escopo errado, teste acoplado a estado externo.
     - `código`: regressão real introduzida pela mudança, contrato quebrado, exception, lógica errada.
     - `migration`: schema divergente, constraint violada, dado existente incompatível com novo schema.
   - **Planejar**: escrever 1-3 frases descrevendo: (a) qual é a causa-raiz hipotética, (b) qual a correção mínima proposta, (c) qual arquivo será tocado. Não começar a editar sem isso.
   - **Corrigir**: aplicar somente a correção mínima planejada. Sem refactor adicional, sem "limpar de quebra".
   - **Re-rodar**: executar de novo o(s) comando(s) que falhou(aram), na mesma ordem da etapa 4.
   - **Limite de 3 tentativas por causa-raiz**. Se a mesma causa reaparecer ao 3º ciclo, parar e escalar para o usuário com: causa observada, o que foi tentado, próxima hipótese.
   - **Critérios para parar e escalar imediatamente**:
     - A correção exigiria modificar `docs/ai/*`.
     - A correção exigiria criar feature/endpoint fora do escopo do flow_id.
     - O erro indica problema de infraestrutura (banco não sobe, dependência não instala).
   - Registrar todas as causas e correções tentadas na tabela "Problemas encontrados / correções" do report (etapa 5).

5. **Gerar relatório**
   - Escrever ou atualizar `docs/test_report_<flow_id>.md` com:
     - Data, branch, classificação (GRANDE/PEQUENA)
     - Comandos executados (tabela: comando, resultado)
     - Fixtures/massa criada ou validada
     - Fluxo validado (tabela: etapa, validação)
     - Problemas encontrados / correções (tabela: causa, correção)
     - Coverage (se disponível)
     - Status final: **PASSOU**, **PASSOU PARCIALMENTE**, ou **FALHOU**
     - Arquivos criados/modificados
     - Como rodar de novo

6. **Encerrar**
   - Reportar uma linha de resumo + caminho do relatório em `docs/`.

7. **Commit**
   - Executar `git add src/ app/ tests/ alembic/ docs/ pyproject.toml requirements*.txt`.
   - Se nada foi staged (`git diff --cached --quiet`), pular o commit.
   - Mensagem do commit:
     - **PEQUENA**: `chore: <descrição curta>` (ex: `chore: ajusta log level no order service`).
     - **GRANDE + PASSOU**: `feat|fix|refactor: <descrição> + test <flow_id>` conforme natureza da mudança.
     - **GRANDE + PASSOU PARCIALMENTE / FALHOU**: NÃO commitar. Reportar e devolver para correção.
   - Se o projeto tem pre-commit hooks, deixe-os rodar. Se quebrar, entrar no loop de diagnóstico (etapa 4a). NÃO usar `--no-verify`.

8. **Push**
   - Só executar se a etapa 7 efetivamente criou um novo commit.
   - Confirmar que a branch atual tem upstream. Se não, usar `git push -u origin HEAD`. Caso contrário, `git push`.
   - NUNCA usar `--force` ou `--force-with-lease` aqui. Push force só com pedido explícito do usuário e nunca em `master`/`main`.
   - Se o push falhar por divergência com o remoto, parar, reportar e perguntar antes de qualquer rebase/merge.

## Restrições obrigatórias

- Não criar feature/endpoint novo fora do escopo do flow.
- Não modificar arquivos em `docs/ai/`.
- Não hardcodar credenciais ou secrets.
- Não pular etapas dentro de uma execução completa (1-6) mesmo se "parecer simples". A única forma legítima de pular é via etapa 0 (classificada PEQUENA), que vai direto para a etapa 7.
- Não remover assertion ou maquiar teste só para passar.
- Se o fluxo exigir serviço externo indisponível, registrar a divergência claramente e propor mock/stub.
- Respeitar a hierarquia de prioridade do `CLAUDE.md`: 1) CLAUDE.md, 2) ARCHITECTURE.md, 3) CODING_STANDARDS.md, 4) API_GUIDE.md, 5) TESTING_GUIDE.md.
