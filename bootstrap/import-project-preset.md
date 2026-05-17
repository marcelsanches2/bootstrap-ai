---
name: import-project-preset
description: Importa o bootstrap-ai correto para o projeto atual de forma não destrutiva.
---

# /import-project-preset

Importa o preset correto do repositório `marcelsanches2/bootstrap-ai` para dentro do projeto atual.

Este arquivo é feito para ser copiado sozinho para um projeto novo/existente em:

```txt
.claude/commands/import-project-preset.md
```

Depois rode no Claude Code:

```txt
/import-project-preset
```

## Objetivo

1. Encontrar a raiz do projeto atual.
2. Garantir que o repo `bootstrap-ai` existe localmente.
3. Atualizar o repo `bootstrap-ai`.
4. Analisar a stack real do projeto.
5. Validar se algum preset cobre todas as tecnologias centrais detectadas.
6. Se faltar cobertura, criar um preset novo específico para o cenário do projeto.
7. Mostrar diff do que será importado.
8. Aplicar o preset em modo não destrutivo.
9. Verificar se os arquivos principais entraram.

## Regras duras

- Nunca sobrescrever arquivos existentes silenciosamente.
- Não usar `--force`.
- Se houver conflito, aceitar criação de `.kit-new`.
- Não commitar automaticamente.
- Não modificar código de produção.
- Não rodar `/refactor` automaticamente; apenas explicar que ele é o próximo passo opcional.

## Procedimento obrigatório

### 0. Usar source embutido (se existir)

Este arquivo pode conter o path absoluto do repo `bootstrap-ai` de onde foi instalado. Procure por `<!-- BOOTSTRAP_AI_SOURCE:` no final deste arquivo.

Se existir:

```bash
# Extrair source embutido
EMBEDDED_SOURCE=$(grep -oP '<!-- BOOTSTRAP_AI_SOURCE: \K[^>]+' "$0" 2>/dev/null || true)
if [ -n "$EMBEDDED_SOURCE" ] && [ -x "$EMBEDDED_SOURCE/bin/bootstrap-ai" ]; then
  BOOTSTRAP_AI_DIR="$EMBEDDED_SOURCE"
  printf 'Source embutido encontrado: %s\n' "$BOOTSTRAP_AI_DIR"
fi
```

Se o source embutido for válido, pule para o passo 3 (atualizar). Caso contrário, continue no passo 2.

### 1. Resolver raiz do projeto e detectar estado

Execute:

```bash
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
printf 'Project root: %s\n' "$ROOT"
```

**Detectar se é pasta vazia (projeto do zero):**

```bash
# Contar arquivos relevantes (excluindo .git e ocultos)
FILE_COUNT=$(find "$ROOT" -maxdepth 1 -type f ! -name '.*' | wc -l)
DIR_COUNT=$(find "$ROOT" -maxdepth 1 -type d ! -name '.*' ! -name "$(basename "$ROOT")" | wc -l)
HAS_STACK=false
for f in pubspec.yaml package.json pyproject.toml requirements.txt go.mod Gemfile Cargo.toml pom.xml build.gradle; do
  if [ -f "$ROOT/$f" ]; then HAS_STACK=true; break; fi
done

if [ "$FILE_COUNT" -eq 0 ] && [ "$DIR_COUNT" -eq 0 ] && [ "$HAS_STACK" = false ]; then
  printf 'Pasta vazia detectada. Este é um projeto novo.\n'
  printf 'Direcionando para /kickoff (onboarding completo).\n\n'
  printf 'Carregue o command /kickoff do preset e execute-o.\n'
  printf 'O /kickoff vai:\n'
  printf '  1. Coletar requisitos (7 perguntas)\n'
  printf '  2. Gerar PRODUCT_BRIEF.md\n'
  printf '  3. Decidir a stack\n'
  printf '  4. Oferecer design phase (se tem front)\n'
  printf '  5. Aplicar o preset correto\n\n'
  printf 'Após o /kickoff completar, este command já terá sido executado.\n'
  # STOP HERE — não continue os passos abaixo
  return
fi
```

Se a pasta **não** está vazia, continue normalmente com o passo 2.

### 2. Localizar ou clonar `bootstrap-ai`

Procure nesta ordem (teste ambos os nomes `bootstrap-ai` e `bootstrap-ai`):

```bash
# 1. Variável de ambiente explícita
$BOOTSTRAP_AI_PATH

# 2. Workspace comum do usuário (onde ele provavelmente clonou)
$HOME/workspace/bootstrap-ai
$HOME/workspace/bootstrap-ai
$HOME/code/bootstrap-ai
$HOME/code/bootstrap-ai
$HOME/projects/bootstrap-ai
$HOME/projects/bootstrap-ai
$HOME/dev/bootstrap-ai
$HOME/dev/bootstrap-ai
$HOME/work/bootstrap-ai
$HOME/work/bootstrap-ai
$HOME/repos/bootstrap-ai
$HOME/repos/bootstrap-ai
$HOME/development/bootstrap-ai
$HOME/development/bootstrap-ai
$HOME/sources/bootstrap-ai
$HOME/sources/bootstrap-ai
$HOME/src/bootstrap-ai
$HOME/src/bootstrap-ai

# 3. Local padrão
$HOME/.local/share/bootstrap-ai
$HOME/.local/share/bootstrap-ai
$HOME/bootstrap-ai
$HOME/bootstrap-ai
```

Use esta função de busca:

```bash
find_bootstrap_ai() {
  # Nomes aceitos
  local names=("bootstrap-ai" "bootstrap-ai")

  # 1. Variável de ambiente
  if [ -n "${BOOTSTRAP_AI_PATH:-}" ] && [ -x "${BOOTSTRAP_AI_PATH}/bin/bootstrap-ai" ]; then
    printf '%s\n' "$BOOTSTRAP_AI_PATH"
    return 0
  fi

  # 2. Buscar em workspaces comuns do usuário
  local workspace_dirs=(
    "$HOME/workspace"
    "$HOME/code"
    "$HOME/projects"
    "$HOME/dev"
    "$HOME/work"
    "$HOME/repos"
    "$HOME/development"
    "$HOME/sources"
    "$HOME/src"
  )

  for ws in "${workspace_dirs[@]}"; do
    for name in "${names[@]}"; do
      if [ -x "$ws/$name/bin/bootstrap-ai" ]; then
        printf '%s\n' "$ws/$name"
        return 0
      fi
    done
    # Buscar um nível mais fundo
    if [ -d "$ws" ]; then
      local found
      for name in "${names[@]}"; do
        found=$(find "$ws" -maxdepth 2 -path "*/$name/bin/bootstrap-ai" -executable -print -quit 2>/dev/null | sed 's|/bin/bootstrap-ai$||')
        if [ -n "$found" ]; then
          printf '%s\n' "$found"
          return 0
        fi
      done
    fi
  done

  # 3. Locais padrão
  for name in "${names[@]}"; do
    for d in "$HOME/.local/share/$name" "$HOME/$name"; do
      if [ -x "$d/bin/bootstrap-ai" ]; then
        printf '%s\n' "$d"
        return 0
      fi
    done
  done

  return 1
}
```

Se não existir em nenhum local, clone:

```bash
# Determinar workspace preferida do usuário
WORKSPACE_DIR=""
for d in "$HOME/workspace" "$HOME/code" "$HOME/projects" "$HOME/dev" "$HOME/work" "$HOME/repos"; do
  if [ -d "$d" ]; then
    WORKSPACE_DIR="$d"
    break
  fi
done

# Fallback para workspace
if [ -z "$WORKSPACE_DIR" ]; then
  WORKSPACE_DIR="$HOME/workspace"
  mkdir -p "$WORKSPACE_DIR"
fi

printf 'Clonando bootstrap-ai em %s\n' "$WORKSPACE_DIR/bootstrap-ai"
if command -v gh >/dev/null 2>&1; then
  gh repo clone marcelsanches2/bootstrap-ai "$WORKSPACE_DIR/bootstrap-ai"
else
  git clone https://github.com/marcelsanches2/bootstrap-ai.git "$WORKSPACE_DIR/bootstrap-ai"
fi
```

### 3. Atualizar `bootstrap-ai`

```bash
cd "$BOOTSTRAP_AI_DIR"
git pull --ff-only
```

Se `git pull --ff-only` falhar, pare e reporte. Não faça merge/rebase automático.

### 4. Analisar stack e cobertura

Antes de importar qualquer coisa, rode:

```bash
"$BOOTSTRAP_AI_DIR/bin/bootstrap-ai" analyze "$ROOT"
```

Isso detecta tecnologias centrais e bibliotecas estruturais por arquivos reais do projeto: `pubspec.yaml`, `pyproject.toml`, `requirements.txt`, `package.json`, `go.mod`, `Gemfile`, configs de framework, dependências e sinais de banco. Exemplos: `dio`, `riverpod`, `go_router`, `sqlalchemy`, `alembic`, `prisma`, `tanstack-query`, `sidekiq`, `chi`, `pgx`.

### 5. Selecionar ou criar preset específico

```bash
KIT="$( $BOOTSTRAP_AI_DIR/bin/bootstrap-ai select "$ROOT" --create-missing --print-preset )"
printf 'Preset selecionado: %s\n' "$KIT"
```

Regra:

- se um preset existente cobre a stack e as bibliotecas estruturais → use esse preset
- se a stack ou biblioteca estrutural não for coberta → crie novo preset via `generators/skill-creator/prompts/create-new-preset.md`
- exemplos que criam preset novo: Rails, Go, Python+React no mesmo repo, React+Node API no mesmo repo, stack híbrida sem cobertura

Ao criar um preset novo, siga rigorosamente os padrões de nomenclatura:
- **Roles** (pessoas): `role-<disciplina>.md` ou `role-<stack>-<disciplina>.md`
- **Reviews** (óticas técnicas): `review-<dominio>.md`
- **Docs**: `UPPER_SNAKE_CASE.md` — guias com `_GUIDE`, referências sem sufixo
- **Separação de responsabilidades**: cada arquivo faz UMA coisa

### 6. Mostrar diff

```bash
"$BOOTSTRAP_AI_DIR/bin/bootstrap-ai" diff "$KIT" "$ROOT"
```

Explique que:

- `Would create` = arquivos que serão criados
- `Would skip identical` = já iguais
- `Would conflict` = serão criados como `.kit-new`

### 7. Aplicar preset com substituição de placeholders

Detecte o nome do projeto antes de aplicar:

```bash
# Detectar nome do projeto
PROJECT_NAME=""
if [ -f "$ROOT/package.json" ]; then
  PROJECT_NAME=$(python3 -c "import json; print(json.load(open('$ROOT/package.json')).get('name',''))" 2>/dev/null)
elif [ -f "$ROOT/pubspec.yaml" ]; then
  PROJECT_NAME=$(grep -m1 '^name:' "$ROOT/pubspec.yaml" | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'")
elif [ -f "$ROOT/pyproject.toml" ]; then
  PROJECT_NAME=$(grep -m1 '^name[[:space:]]*=' "$ROOT/pyproject.toml" | sed 's/^name[[:space:]]*=[[:space:]]*//' | tr -d '"' | tr -d "'")
fi
PROJECT_NAME="${PROJECT_NAME:-$(basename "$ROOT")}"
printf 'Project name: %s\n' "$PROJECT_NAME"

"$BOOTSTRAP_AI_DIR/bin/bootstrap-ai" apply "$KIT" "$ROOT" --refresh --project-name "$PROJECT_NAME"
```

Isso substitui `{{PROJECT_NAME}}` em todos os arquivos `.md`, `.yaml`, `.yml`, `.txt`, `.json`, `.toml` do preset pelo nome real do projeto.

Não use `--force`.

### 8. Verificar importação

Verifique se existem:

```txt
$ROOT/CLAUDE.md
$ROOT/.claude/commands/jarvis-plan.md
$ROOT/.claude/commands/refactor.md
$ROOT/.claude/commands/jarvis-test-flow.md
$ROOT/docs/ai/
$ROOT/plans/
$ROOT/.bootstrap-ai.lock
```

Execute:

```bash
test -f "$ROOT/.claude/commands/refactor.md" && echo "refactor OK"
test -f "$ROOT/.bootstrap-ai.lock" && echo "lock OK"
```

### 8.5. Sincronizar Design System com o projeto

**Objetivo:** Se o projeto já tem tokens visuais (cores, tipografia, espaçamento), reescrever `docs/ai/DESIGN_SYSTEM.md` para refletir a identidade real do projeto em vez do template genérico.

**Quando executar:** Sempre que o preset aplicar um `DESIGN_SYSTEM.md`. Não executar para backends (node-backend, python-backend) pois não têm UI.

#### 8.5.1. Detectar tokens existentes por stack

Escanee os arquivos abaixo na raiz do projeto. Se encontrar valores reais, extraia.

**Flutter** — procure em:

```
lib/app/theme/app_colors.dart
lib/app/theme/app_theme.dart
lib/app/theme/app_text_styles.dart
lib/app/theme/app_spacing.dart
pubspec.yaml (google_fonts dependency)
```

Extraia:

- **Cores:** valores `Color(0xFF...)`, `ColorScheme(…)` com `primary`, `secondary`, `surface`, `error`, `onPrimary`, etc.
- **Tipografia:** fontes via `GoogleFonts.*`, `TextStyle(fontFamily: ...)`
- **Espaçamento:** constantes numéricas em classes de spacing/radius

**React/Web** — procure em:

```
tailwind.config.ts / tailwind.config.js
src/theme/colors.ts / src/styles/theme.ts
src/theme/typography.ts
src/styles/tokens.ts
src/app/globals.css (CSS custom properties: --color-*, --font-*, --space-*)
```

Extraia:

- **Cores:** valores do `theme.colors` no Tailwind, ou `var(--color-*)` em CSS
- **Tipografia:** `theme.fontFamily`, Google Fonts imports, CSS `font-family`
- **Espaçamento:** `theme.spacing`, `theme.borderRadius`

**Outras stacks:** pule este passo.

#### 8.5.2. Decisão baseada no resultado do scan

| Resultado | Ação |
|---|---|
| **Encontrou tokens completos** (cores + tipografia + espaçamento) | Reescreva `docs/ai/DESIGN_SYSTEM.md` substituindo as seções genéricas pelos valores reais do projeto. Mantenha a estrutura do documento (seções, regras, componentes), apenas troque os valores. Adicione nota: "Tokens sincronizados do design system existente em `[arquivo_fonte]`". |
| **Encontrou parcial** (ex: tem cores mas sem tipografia) | Reescreva apenas as seções onde encontrou valores. Deixe genérico onde não achou. Adicione nota indicando o que foi sincronizado e o que ainda é template. |
| **Não encontrou nada** | Mantenha o `DESIGN_SYSTEM.md` genérico do preset. Pergunte ao usuário: "Seu projeto não tem design system definido. Quer personalizar as cores e tipografia agora? (s/n)". Se sim, rode `/design-phase` no modo "extract". |

#### 8.5.3. Formato da reescrita

Ao reescrever, mantenha:

- A mesma estrutura de seções do template original
- Os mesmos nomes de tokens semânticos (primary, secondary, surface, etc.)
- As regras e boas práticas do template
- A linguagem (pt-BR ou en) do template original

Substitua apenas:

- Valores hex/RGB de cores pelos valores reais
- Nomes de fontes pelas fontes reais
- Valores de espaçamento/radius pelos valores reais
- Exemplos de código que referenciam cores/fontes específicas

#### 8.5.4. Exemplo de saída

```txt
🎨 Design System sincronizado:
   Cores: 12 tokens extraídos de lib/app/theme/app_colors.dart
   Tipografia: 3 fontes de GoogleFonts (Inter, Saira, Tourney)
   Espaçamento: 6 tokens de app_spacing.dart
   Arquivo reescrito: docs/ai/DESIGN_SYSTEM.md
```

Ou:

```txt
🎨 Design System: nenhum token encontrado no projeto.
   Template genérico mantido em docs/ai/DESIGN_SYSTEM.md.
   Para personalizar, rode /design-phase.
```

### 8.6. Customizar guides com bibliotecas detectadas

**Objetivo:** As bibliotecas estruturais detectadas no passo 4 (analyze) devem refletir nos guides aplicados. Um preset genérico fala de "state management" sem dizer qual — se o projeto usa Riverpod, os guides devem mencionar Riverpod especificamente.

**Quando executar:** Sempre, tanto para projetos existentes quanto para projetos novos (após /kickoff definir a stack). Funciona em TODOS os presets.

#### 8.6.1. Fonte dos dados

Use as libs detectadas pelo `bin/bootstrap-ai analyze` no passo 4. O analyze retorna uma lista de bibliotecas estruturais encontradas no projeto.

Para projetos novos (via /kickoff), use as libs que o /kickoff definiu ao selecionar/inicializar a stack.

#### 8.6.2. Mapeamento lib → guide → customização

Para cada lib detectada, identifique quais guides devem ser customizados e o que injetar:

**State Management:**

| Lib detectada | Guides afetados | O que customizar |
|---|---|---|
| Riverpod | ARCHITECTURE, CODING_STANDARDS | Padrão de DI: `Provider`, `Notifier`, `AsyncNotifier`, `ref.read/watch`. Nomenclatura de providers: `*Provider`, `*Notifier`. AsyncValue handling. |
| BLoC | ARCHITECTURE, CODING_STANDARDS | Padrão: `Bloc`, `Event`, `State`, `BlocBuilder`. Nomenclatura: `*Bloc`, `*Event`, `*State`. |
| GetX | ARCHITECTURE, CODING_STANDARDS | Padrão: `GetxController`, `obx`, `Get.find()`. |
| Zustand | ARCHITECTURE, CODING_STANDARDS | Store creation: `create()`, actions, selectors. |
| Redux | ARCHITECTURE, CODING_STANDARDS | Padrão: actions, reducers, selectors, middleware. |

**Data Fetching:**

| Lib detectada | Guides afetados | O que customizar |
|---|---|---|
| TanStack Query | FEATURE_GUIDE, ARCHITECTURE | Query keys, `useQuery`, `useMutation`, cache invalidation, optimistic updates, stale time. |
| Dio | ARCHITECTURE, CODING_STANDARDS | Interceptors, error handling, retry, base URL config, auth headers. |
| httpx | ARCHITECTURE, CODING_STANDARDS | Client config, interceptors, error handling. |

**ORM / Database:**

| Lib detectada | Guides afetados | O que customizar |
|---|---|---|
| Prisma | DATABASE_GUIDE, ARCHITECTURE | Schema.prisma, migrations (`prisma migrate`), query patterns, transactions. |
| Drizzle | DATABASE_GUIDE, ARCHITECTURE | Schema definition, migrations, query builder patterns. |
| SQLAlchemy | DATABASE_GUIDE, ARCHITECTURE | Models, sessions, Alembic migrations, query patterns, relationships. |
| TypeORM | DATABASE_GUIDE, ARCHITECTURE | Entities, migrations, repositories, query builder. |
| Mongoose | DATABASE_GUIDE, ARCHITECTURE | Schemas, models, middleware hooks, queries. |

**Validação:**

| Lib detectada | Guides afetados | O que customizar |
|---|---|---|
| Zod | CODING_STANDARDS, API_GUIDE | Schema definitions, `.parse()`, `.safeParse()`, error formatting. |
| Pydantic | CODING_STANDARDS, API_GUIDE | BaseModel, validators, schema generation, error handling. |
| class-validator | CODING_STANDARDS, API_GUIDE | Decorators, validation pipes, error responses. |

**Routing:**

| Lib detectada | Guides afetados | O que customizar |
|---|---|---|
| GoRouter | ARCHITECTURE | Route structure, guards, deep linking, redirect logic, shell routes. |
| React Router | ARCHITECTURE | Route config, loaders, nested routes, params. |

**Testing:**

| Lib detectada | Guides afetados | O que customizar |
|---|---|---|
| Vitest | TESTING_GUIDE | Config, `describe/it/expect`, mocks, coverage. |
| Jest | TESTING_GUIDE | Config, `describe/it/expect`, mocks, coverage. |
| pytest | TESTING_GUIDE | Fixtures, conftest, markers, parametrize, coverage. |
| Playwright | TESTING_GUIDE | E2E: page objects, selectors, assertions, test config. |
| Cypress | TESTING_GUIDE | E2E: cy commands, custom commands, assertions. |

#### 8.6.3. Processo de customização

Para cada lib detectada que tem mapeamento acima:

1. **Identifique** os guides afetados pela lib
2. **Localize** no guide a seção genérica relevante (ex: "State Management" no ARCHITECTURE.md)
3. **Injete** padrões específicos da lib logo após a seção genérica, com formato:

```md
### Biblioteca detectada: {LIB_NAME}

{Padrões específicos da lib — convenções de naming, uso, anti-patterns}

*Detectado em: {arquivo_onde_foi_encontrado}*
```

4. Se o guide não tem seção sobre o tópico (ex: ARCHITECTURE.md não menciona "validation"), **adicione** uma nova seção no final.
5. **Não remova** conteúdo genérico existente — apenas complemente com specifics da lib.

#### 8.6.4. Exemplo de saída

```txt
📚 Guides customizados com libs detectadas:
   ARCHITECTURE.md + Riverpod (DI pattern, providers, AsyncValue)
   ARCHITECTURE.md + GoRouter (routing structure, guards)
   CODING_STANDARDS.md + Riverpod (naming conventions, anti-patterns)
   CODING_STANDARDS.md + Dio (error handling, interceptors)
   DATABASE_GUIDE.md + Prisma (schema, migrations, queries)
   TESTING_GUIDE.md + Vitest (config, mocks, coverage)
   6 arquivos atualizados com 6 bibliotecas.
```

Ou:

```txt
📚 Guides: nenhuma lib estrutural adicional detectada.
   Templates genéricos mantidos.
```

#### 8.6.5. Projetos novos (via /kickoff)

Quando o fluxo vem do `/kickoff`, as libs já foram definidas na seleção de stack. Aplique este passo com as libs que o /kickoff configurou no projeto (lidas de `pubspec.yaml`, `package.json`, `pyproject.toml` ou `requirements.txt` após a inicialização).

### 9. Resposta final

Reporte:

```txt
Preset aplicado: <preset>
Bootstrap AI usado: <path>
Project name: <nome do projeto>
Arquivos criados: <n>
Conflitos .kit-new: <n>
Design System: sincronizado / template genérico
Libs detectadas: <lista>
Guides customizados: <n> arquivos com <n> libs
Próximo passo sugerido:
  - Projeto existente: /refactor (alinha código real com os padrões do preset)
  - Projeto novo: /plan (começa o ciclo de desenvolvimento)
```

## Próximos passos

Projeto novo:

```txt
/plan
```

Projeto existente:

```txt
/refactor
```