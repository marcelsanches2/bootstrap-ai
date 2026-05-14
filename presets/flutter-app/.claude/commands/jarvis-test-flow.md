---
description: Validar um fluxo E2E garantindo massa deterministica, integration test, comparacao visual com Figma e relatorio atualizado.
---

# /jarvis-test-flow

Valida um fluxo end-to-end do app {{PROJECT_NAME}}. Argumento opcional: `flow_id` (ex.: `home_guest_location_zones`).

## Sequencia obrigatoria

0. **Avaliar tamanho da task**
   - Inspecionar `git diff --stat HEAD` e a natureza dos arquivos tocados em `lib/`, `integration_test/`, `pubspec.yaml`.
   - **GRANDE** (rodar pipeline completo, etapas 1-8): nova feature, nova tela/page, mudanca de router/navigation, novo datasource ou repository, mudanca em entity/value object, integracao de package, mudanca que afeta fluxo do usuario ponta a ponta.
   - **PEQUENA** (pular para etapa 7): typo, troca de log (`print` -> `AppLogger`), formatacao, comentario, ajuste fino em widget existente sem mudanca de comportamento, refactor sem mudanca de comportamento observavel, ajuste de assets/copia.
   - **Em duvida**: perguntar ao usuario antes de classificar (uma frase: "task X — pequena ou grande?"). Nao chutar.
   - Reportar a classificacao numa linha antes de prosseguir (ex: `task: PEQUENA — so print->AppLogger em dio_client.dart`).

1. **Determinar o `flow_id`**
   - Se foi passado como argumento, usar.
   - Se nao, inferir pelo `git diff --name-only HEAD` (qual feature foi tocada). Mapear `lib/features/<X>/` -> `<X>_*` flow. Se ambiguo, perguntar ao usuario antes de seguir.

2. **Inventariar massa (mocks deterministicos)**
   - Localizar os datasource mocks que cobrem o flow_id (`lib/features/**/data/datasources/*_mock.dart`).
   - Validar que os dados esperados existem (cruzar com asserts do test em `integration_test/`).
   - Se faltar massa, criar mock(s) deterministico(s) seguindo `docs/ai/CODING_STANDARDS.md` e `docs/ai/ARCHITECTURE.md`. Sem random, sem `Future.delayed`, sem chamada de rede.
   - Garantir que `lib/app/config/app_config.dart` tem `useMockBackend: true` em `AppConfig.dev()` OU que o teste sobrescreve os providers de datasource via `ProviderScope.overrides`.

3. **Inventariar teste**
   - Procurar `integration_test/{flow_id}_test.dart` ou `integration_test/app_test.dart` que cubra o flow.
   - Verificar se existe um relatorio de revisao (`docs/revisao_*.md`, `plans/*_revisao.md` ou similar) gerado pelo `/jarvis-plan-revisor` para o mesmo fluxo. Se existir, extrair os **Cenarios E2E sugeridos** da secao correspondente e considera-los como requisitos minimos de cobertura alem dos cenarios proprios do test-flow.
   - Se nao existir, prosseguir normalmente.
   - Se nao existir teste de integracao, criar com `package:integration_test`. Mockar `LocationService` via `ProviderScope.overrides` (sem tapar dialogos nativos). `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` no inicio.
   - Validar que o teste cobre as etapas criticas e usa os dados deterministicos da massa.

4. **Executar o pipeline**
   - `flutter clean`
   - `flutter pub get`
   - `flutter analyze` — bloqueia se introduzir warnings novos (warnings pre-existentes em `dio_client.dart` por `avoid_print` sao aceitaveis).
   - `flutter test` (unit/widget) — bloqueia se quebrar.
   - `flutter test integration_test/<arquivo>.dart -d <UDID>` no iPhone 16 Plus simulator (UDID `71063C1A-B3F2-4F3E-83C6-FE2E689989BA`). Se outro device for desejado ou o simulator nao estiver disponivel, perguntar.
   - **Se qualquer comando falhar, entrar no loop de diagnostico (etapa 4a) antes de prosseguir.** Nao maquiar, nao silenciar warning, nao remover assertion.

4a. **Loop de diagnostico e correcao** (acionado quando algo na etapa 4, 4b ou no pre-commit hook da etapa 7 falha)
   - **Diagnosticar**: ler atentamente a saida de erro completa. Classificar a causa em uma das categorias:
     - `ambiente`: Flutter SDK, simulator nao bootado, dependencia ausente, cache corrompido.
     - `mock/massa`: dado deterministico faltando, divergencia entre mock e assercao do teste, override de provider mal configurado.
     - `teste`: assercao invalida, seletor inexistente, race condition (`pump`/`pumpAndSettle`), expectativa errada para o estado atual.
     - `codigo`: regressao real introduzida pela mudanca da task, contrato quebrado, exception, logica errada.
     - `design`: divergencia visual entre implementacao e Figma (cores, tipografia, espacamento, componentes, estados).
   - **Planejar**: escrever 1-3 frases descrevendo: (a) qual e a causa-raiz hipotetica, (b) qual a correcao minima proposta, (c) qual arquivo sera tocado. Nao comecar a editar sem isso.
   - **Corrigir**: aplicar somente a correcao minima planejada. Sem refactor adicional, sem "limpar de quebra".
   - **Re-rodar**: executar de novo o(s) comando(s) que falhou(aram), na mesma ordem da etapa 4 (e 4b se aplicavel).
   - **Limite de 3 tentativas por causa-raiz**. Se a mesma causa reaparecer ao 3 ciclo, ou se a correcao exigir mudancas fora do escopo da task original (ex.: refatorar arquitetura, criar feature nova), parar e escalar para o usuario com: causa observada, o que foi tentado, proxima hipotese.
   - **Criterios para parar e escalar imediatamente** (sem esperar 3 tentativas):
     - A correcao exigiria modificar `docs/ai/*` ou outro arquivo proibido pelas restricoes.
     - A correcao exigiria criar feature/tela/datasource fora do escopo do flow_id.
     - O erro indica problema de infraestrutura (simulator quebrado, `flutter doctor` reclamando de toolchain).
     - Tentativas anteriores divergem (causa muda a cada rodada -> sinal de que o diagnostico esta raso).
   - Registrar todas as causas e correcoes tentadas na tabela "Problemas encontrados / correcoes" do report (etapa 5), inclusive em caso de PASSOU.

4b. **Validacao visual contra Figma (criterio de aceite)**
   - Apenas para tasks **GRANDES** que envolvam tela/page nova ou alteracao visual significativa.
   - NUNCA rodar automaticamente ao salvar .dart. Sobre demanda explicita do usuario.
   - **4b.1. Detectar emulador**
     - Executar `flutter devices` e parsear o output.
     - Se 1 device conectado: capturar o device ID (coluna do meio) e usar automaticamente.
     - Se multiplos: listar numerados e perguntar qual usar, ou usar o primeiro avisando qual foi escolhido.
     - Se nenhum: instruir iniciar um emulador e parar.
     - Filtros opcionais: `--ios` ou `--android` filtram a lista antes de escolher.
   - **4b.2. Exportar frame do Figma**
     - Verificar se o plano mais recente em `plans/` contem um link do Figma (`figma.com/design/...`) e/ou node ID.
     - Se houver link do Figma:
       1. Extrair `fileKey` e `nodeId` do URL.
       2. Usar o MCP Figma (`get_screenshot`) para exportar o frame informado para `/tmp/figma_design.png`.
       3. Ajustar a escala do Figma para bater com a densidade do device (iOS @3x, Android @2x/@3x etc.) antes do diff. Passar o fator via `--scale-figma=X`.
     - Se o frame/node ID nao for informado, perguntar ao usuario.
     - Se o MCP Figma estiver indisponivel, pedir ao usuario para colocar manualmente a imagem em `/tmp/figma_design.png`.
   - **4b.3. Tirar screenshot do app**
     - Executar: `flutter screenshot --device-id=<id> --out=/tmp/flutter_screen.png`
     - Se falhar, aguardar 2s e tentar novamente uma vez.
     - Fallback Android se falhar: `adb exec-out screencap -p > /tmp/flutter_screen.png`
     - Fallback iOS se falhar: `xcrun simctl io booted screenshot /tmp/flutter_screen.png --type=png`
   - **4b.4. Comparacao visual**
     - Executar:
       `python3 .claude/scripts/compare_design.py /tmp/figma_design.png /tmp/flutter_screen.png /tmp/design_comparison.png --scale-figma=<fator>`
     - Mostrar o caminho da imagem gerada no terminal.
   - **4b.5. Analise**
     - Descrever diferencas de: layout, cores (hex aproximado), tipografia, espacamentos, elementos faltantes/sobrando, proporcoes.
     - Sugerir ajustes concretos no codigo Dart/Flutter (valores de padding, Theme colors, fontSize, etc.).
   - **4b.6. Decisao**
     - Se houver divergencia visivel: entrar no loop de diagnostico (etapa 4a) classificando como `design`.
     - Corrigir os arquivos da feature ate ficar 1:1 com o Figma.
     - Re-rodar etapa 4 (integration test) e etapa 4b (comparacao visual).
     - Limite de 3 tentativas para ajustes de design.
     - Só prosseguir para etapa 5 se a implementacao estiver 1:1 com o Figma.
   - Se nao houver link do Figma no plano, pular esta etapa e prosseguir normalmente.

5. **Gerar relatorio**
   - Escrever ou atualizar `docs/e2e_report_{flow_id}.md` com:
     - Data, branch, device, estrategia
     - Massa criada (tabela com IDs, nomes, lat/lng, status, paces)
     - Comandos executados (tabela: comando, resultado)
     - Fluxo validado (tabela: etapa, validacao)
     - Comparacao visual (se aplicavel): caminho da imagem, escala usada, divergencias encontradas, ajustes sugeridos
     - Problemas encontrados / correcoes (tabela: causa, correcao)
     - Status final: **PASSOU**, **PASSOU PARCIALMENTE**, ou **FALHOU**
     - Arquivos criados/modificados
     - Como rodar de novo

6. **Encerrar**
   - Reportar uma linha de resumo + caminho do relatorio em `docs/`.

7. **Commit**
   - Executar `git add lib/ integration_test/ docs/ pubspec.yaml pubspec.lock`.
   - Se nada foi staged (`git diff --cached --quiet`), pular o commit.
   - Mensagem do commit:
     - **PEQUENA**: `chore: <descricao curta da mudanca>` (ex: `chore: substitui prints por AppLogger no dio_client`).
     - **GRANDE + PASSOU**: `feat|fix|refactor: <descricao> + e2e {flow_id}` conforme natureza da mudanca.
     - **GRANDE + PASSOU PARCIALMENTE / FALHOU**: NAO commitar. Reportar e devolver para correcao.
   - O commit dispara o `.githooks/pre-commit` (analyze + unit/widget tests). Se quebrar, NAO usar `--no-verify` — entrar no loop de diagnostico (etapa 4a), corrigir, e tentar o commit de novo.

8. **Push**
   - So executar se a etapa 7 efetivamente criou um novo commit. Se foi pulada (nada staged) ou bloqueada (GRANDE + falha), NAO empurrar.
   - Confirmar que a branch atual tem upstream: se `git rev-parse --abbrev-ref --symbolic-full-name @{u}` falhar, usar `git push -u origin HEAD`. Caso contrario, `git push`.
   - NUNCA usar `--force` ou `--force-with-lease` aqui. Push de force so com pedido explicito do usuario e nunca em `master`.
   - Se o push falhar por divergencia com o remoto (`non-fast-forward`), parar, reportar e perguntar antes de qualquer rebase/merge.

## Restricoes obrigatorias

- Nao criar feature nova fora do escopo do flow.
- Nao modificar arquivos em `docs/ai/`.
- Nao hardcodar credenciais ou secrets.
- Nao pular etapas dentro de uma execucao completa (1-6) mesmo se "parecer simples". A unica forma legitima de pular e via etapa 0 (classificada PEQUENA), que vai direto para a etapa 7.
- Nao remover assercao ou maquiar teste so para passar.
- Se o fluxo exigir backend real e ele nao existir, registrar a divergencia claramente e propor o menor ajuste tecnico (ex.: mock in-app).
- Respeitar a hierarquia de prioridade do `CLAUDE.md`: 1) CLAUDE.md, 2) ARCHITECTURE.md, 3) CODING_STANDARDS.md, 4) FEATURE_GUIDE.md, 5) DESIGN_SYSTEM.md.
