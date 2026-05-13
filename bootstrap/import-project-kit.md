---
name: import-project-kit
description: Importa o project-kits correto para o projeto atual de forma não destrutiva.
---

# /import-project-kit

Importa o kit correto do repositório `marcelsanches2/ai-project-kits` para dentro do projeto atual.

Este arquivo é feito para ser copiado sozinho para um projeto novo/existente em:

```txt
.claude/commands/import-project-kit.md
```

Depois rode no Claude Code:

```txt
/import-project-kit
```

## Objetivo

1. Encontrar a raiz do projeto atual.
2. Garantir que o repo `ai-project-kits` existe localmente.
3. Atualizar o repo `ai-project-kits`.
4. Analisar a stack real do projeto.
5. Validar se algum kit cobre todas as tecnologias centrais detectadas.
6. Se faltar cobertura, criar um kit novo específico para o cenário do projeto.
7. Mostrar diff do que será importado.
8. Aplicar o kit em modo não destrutivo.
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

Este arquivo pode conter o path absoluto do repo `ai-project-kits` de onde foi instalado. Procure por `<!-- PROJECT_KITS_SOURCE:` no final deste arquivo.

Se existir:

```bash
# Extrair source embutido
EMBEDDED_SOURCE=$(grep -oP '<!-- PROJECT_KITS_SOURCE: \K[^>]+' "$0" 2>/dev/null || true)
if [ -n "$EMBEDDED_SOURCE" ] && [ -x "$EMBEDDED_SOURCE/bin/kit" ]; then
  PROJECT_KITS_DIR="$EMBEDDED_SOURCE"
  printf 'Source embutido encontrado: %s\n' "$PROJECT_KITS_DIR"
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
  printf 'Carregue o command /kickoff do kit e execute-o.\n'
  printf 'O /kickoff vai:\n'
  printf '  1. Coletar requisitos (7 perguntas)\n'
  printf '  2. Gerar PRODUCT_BRIEF.md\n'
  printf '  3. Decidir a stack\n'
  printf '  4. Oferecer design phase (se tem front)\n'
  printf '  5. Aplicar o kit correto\n\n'
  printf 'Após o /kickoff completar, este command já terá sido executado.\n'
  # STOP HERE — não continue os passos abaixo
  return
fi
```

Se a pasta **não** está vazia, continue normalmente com o passo 2.

### 2. Localizar ou clonar `ai-project-kits`

Procure nesta ordem (teste ambos os nomes `ai-project-kits` e `project-kits`):

```bash
# 1. Variável de ambiente explícita
$PROJECT_KITS_PATH

# 2. Workspace comum do usuário (onde ele provavelmente clonou)
$HOME/workspace/ai-project-kits
$HOME/workspace/project-kits
$HOME/code/ai-project-kits
$HOME/code/project-kits
$HOME/projects/ai-project-kits
$HOME/projects/project-kits
$HOME/dev/ai-project-kits
$HOME/dev/project-kits
$HOME/work/ai-project-kits
$HOME/work/project-kits
$HOME/repos/ai-project-kits
$HOME/repos/project-kits
$HOME/development/ai-project-kits
$HOME/development/project-kits
$HOME/sources/ai-project-kits
$HOME/sources/project-kits
$HOME/src/ai-project-kits
$HOME/src/project-kits

# 3. Local padrão
$HOME/.local/share/ai-project-kits
$HOME/.local/share/project-kits
$HOME/ai-project-kits
$HOME/project-kits
```

Use esta função de busca:

```bash
find_project_kits() {
  # Nomes aceitos
  local names=("ai-project-kits" "project-kits")

  # 1. Variável de ambiente
  if [ -n "${PROJECT_KITS_PATH:-}" ] && [ -x "${PROJECT_KITS_PATH}/bin/kit" ]; then
    printf '%s\n' "$PROJECT_KITS_PATH"
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
      if [ -x "$ws/$name/bin/kit" ]; then
        printf '%s\n' "$ws/$name"
        return 0
      fi
    done
    # Buscar um nível mais fundo
    if [ -d "$ws" ]; then
      local found
      for name in "${names[@]}"; do
        found=$(find "$ws" -maxdepth 2 -path "*/$name/bin/kit" -executable -print -quit 2>/dev/null | sed 's|/bin/kit$||')
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
      if [ -x "$d/bin/kit" ]; then
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

printf 'Clonando ai-project-kits em %s\n' "$WORKSPACE_DIR/ai-project-kits"
if command -v gh >/dev/null 2>&1; then
  gh repo clone marcelsanches2/ai-project-kits "$WORKSPACE_DIR/ai-project-kits"
else
  git clone https://github.com/marcelsanches2/ai-project-kits.git "$WORKSPACE_DIR/ai-project-kits"
fi
```

### 3. Atualizar `ai-project-kits`

```bash
cd "$PROJECT_KITS_DIR"
git pull --ff-only
```

Se `git pull --ff-only` falhar, pare e reporte. Não faça merge/rebase automático.

### 4. Analisar stack e cobertura

Antes de importar qualquer coisa, rode:

```bash
"$PROJECT_KITS_DIR/bin/kit" analyze "$ROOT"
```

Isso detecta tecnologias centrais e bibliotecas estruturais por arquivos reais do projeto: `pubspec.yaml`, `pyproject.toml`, `requirements.txt`, `package.json`, `go.mod`, `Gemfile`, configs de framework, dependências e sinais de banco. Exemplos: `dio`, `riverpod`, `go_router`, `sqlalchemy`, `alembic`, `prisma`, `tanstack-query`, `sidekiq`, `chi`, `pgx`.

### 5. Selecionar ou criar kit específico

```bash
KIT="$( $PROJECT_KITS_DIR/bin/kit select "$ROOT" --create-missing --print-kit )"
printf 'Kit selecionado: %s\n' "$KIT"
```

Regra:

- se um kit existente cobre a stack e as bibliotecas estruturais → use esse kit
- se a stack ou biblioteca estrutural não for coberta → crie novo kit via `kit create`
- exemplos que criam kit novo: Rails, Go, Python+React no mesmo repo, React+Node API no mesmo repo, stack híbrida sem cobertura

### 6. Mostrar diff

```bash
"$PROJECT_KITS_DIR/bin/kit" diff "$KIT" "$ROOT"
```

Explique que:

- `Would create` = arquivos que serão criados
- `Would skip identical` = já iguais
- `Would conflict` = serão criados como `.kit-new`

### 7. Aplicar kit com substituição de placeholders

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

"$PROJECT_KITS_DIR/bin/kit" apply "$KIT" "$ROOT" --refresh --project-name "$PROJECT_NAME"
```

Isso substitui `{{PROJECT_NAME}}` em todos os arquivos `.md`, `.yaml`, `.yml`, `.txt`, `.json`, `.toml` do kit pelo nome real do projeto.

Não use `--force`.

### 8. Verificar importação

Verifique se existem:

```txt
$ROOT/CLAUDE.md
$ROOT/.claude/commands/plan.md
$ROOT/.claude/commands/jarvis-plan-revisor.md
$ROOT/.claude/commands/refactor.md
$ROOT/.claude/commands/jarvis-test-flow.md
$ROOT/docs/ai/
$ROOT/plans/
$ROOT/.project-kit.lock
```

Execute:

```bash
test -f "$ROOT/.claude/commands/refactor.md" && echo "refactor OK"
test -f "$ROOT/.project-kit.lock" && echo "lock OK"
```

### 9. Resposta final

Reporte:

```txt
Kit aplicado: <kit>
Project-kits usado: <path>
Project name: <nome do projeto>
Arquivos criados: <n>
Conflitos .kit-new: <n>
Próximo passo sugerido: /refactor, se o projeto já existe; /plan, se projeto novo.
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