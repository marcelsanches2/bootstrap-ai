#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"
ROOT="$(cd "$TARGET" && (git rev-parse --show-toplevel 2>/dev/null || pwd))"

log() { printf '[project-kit-import] %s\n' "$*"; }
fail() { printf '[project-kit-import] erro: %s\n' "$*" >&2; exit 1; }

# Nomes aceitos: novo (ai-project-kits) e antigo (project-kits)
_KIT_NAMES=("ai-project-kits" "project-kits")

find_project_kits() {
  # 1. Variável de ambiente explícita
  if [ -n "${PROJECT_KITS_PATH:-}" ] && [ -x "${PROJECT_KITS_PATH}/bin/kit" ]; then
    printf '%s\n' "$PROJECT_KITS_PATH"
    return 0
  fi

  # 2. Workspaces comuns do usuário
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
    # Direto na raiz da workspace (testa ambos os nomes)
    for name in "${_KIT_NAMES[@]}"; do
      if [ -x "$ws/$name/bin/kit" ]; then
        printf '%s\n' "$ws/$name"
        return 0
      fi
    done
    # Um nível mais fundo (ex: workspace/group/ai-project-kits)
    if [ -d "$ws" ]; then
      local found
      for name in "${_KIT_NAMES[@]}"; do
        found=$(find "$ws" -maxdepth 2 -path "*/$name/bin/kit" -executable -print -quit 2>/dev/null | sed 's|/bin/kit$||')
        if [ -n "$found" ]; then
          printf '%s\n' "$found"
          return 0
        fi
      done
    fi
  done

  # 3. Locais padrão (ambos os nomes)
  for name in "${_KIT_NAMES[@]}"; do
    for d in "$HOME/.local/share/$name" "$HOME/$name"; do
      if [ -x "$d/bin/kit" ]; then
        printf '%s\n' "$d"
        return 0
      fi
    done
  done

  return 1
}

find_workspace_dir() {
  # Procura workspace existente na ordem de preferência
  for d in "$HOME/workspace" "$HOME/code" "$HOME/projects" "$HOME/dev" "$HOME/work" "$HOME/repos" "$HOME/development" "$HOME/sources" "$HOME/src"; do
    if [ -d "$d" ]; then
      printf '%s\n' "$d"
      return 0
    fi
  done
  # Cria workspace padrão se não existir nenhuma
  mkdir -p "$HOME/workspace"
  printf '%s\n' "$HOME/workspace"
}

detect_project_name() {
  # Tenta detectar o nome do projeto alvo para substituição de placeholders
  local root="$1"
  # 1. package.json "name"
  if [ -f "$root/package.json" ]; then
    local name
    name=$(python3 -c "import json,sys; print(json.load(open('$root/package.json')).get('name',''))" 2>/dev/null)
    if [ -n "$name" ]; then printf '%s\n' "$name"; return 0; fi
  fi
  # 2. pubspec.yaml "name"
  if [ -f "$root/pubspec.yaml" ]; then
    local name
    name=$(grep -m1 '^name:' "$root/pubspec.yaml" 2>/dev/null | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'")
    if [ -n "$name" ]; then printf '%s\n' "$name"; return 0; fi
  fi
  # 3. pyproject.toml [project] name
  if [ -f "$root/pyproject.toml" ]; then
    local name
    name=$(grep -m1 '^name[[:space:]]*=' "$root/pyproject.toml" 2>/dev/null | sed 's/^name[[:space:]]*=[[:space:]]*//' | tr -d '"' | tr -d "'")
    if [ -n "$name" ]; then printf '%s\n' "$name"; return 0; fi
  fi
  # 4. Fallback: nome do diretório
  printf '%s\n' "$(basename "$root")"
}

if PROJECT_KITS_DIR="$(find_project_kits)"; then
  log "project-kits encontrado: $PROJECT_KITS_DIR"
else
  WORKSPACE_DIR="$(find_workspace_dir)"
  PROJECT_KITS_DIR="$WORKSPACE_DIR/ai-project-kits"
  log "clonando ai-project-kits em $PROJECT_KITS_DIR"
  if command -v gh >/dev/null 2>&1; then
    gh repo clone marcelsanches2/ai-project-kits "$PROJECT_KITS_DIR"
  else
    git clone https://github.com/marcelsanches2/ai-project-kits.git "$PROJECT_KITS_DIR"
  fi
fi

log "raiz do projeto alvo: $ROOT"
log "atualizando ai-project-kits"
git -C "$PROJECT_KITS_DIR" pull --ff-only

log "analisando stack e cobertura do kit"
"$PROJECT_KITS_DIR/bin/kit" analyze "$ROOT"
KIT="$($PROJECT_KITS_DIR/bin/kit select "$ROOT" --create-missing --print-kit)"
log "kit selecionado: $KIT"

log "diff não destrutivo"
"$PROJECT_KITS_DIR/bin/kit" diff "$KIT" "$ROOT"

# Detecta nome do projeto para substituir placeholders
PROJECT_NAME="$(detect_project_name "$ROOT")"
log "nome do projeto detectado: $PROJECT_NAME"

log "aplicando kit sem --force"
"$PROJECT_KITS_DIR/bin/kit" apply "$KIT" "$ROOT" --refresh --project-name "$PROJECT_NAME"

log "verificando arquivos principais"
test -f "$ROOT/CLAUDE.md" || fail "CLAUDE.md ausente"
test -f "$ROOT/.claude/commands/plan.md" || fail "plan.md ausente"
test -f "$ROOT/.claude/commands/jarvis-plan-revisor.md" || fail "jarvis-plan-revisor.md ausente"
test -f "$ROOT/.claude/commands/refactor.md" || fail "refactor.md ausente"
test -f "$ROOT/.claude/commands/jarvis-test-flow.md" || fail "jarvis-test-flow.md ausente"
test -d "$ROOT/docs/ai" || fail "docs/ai ausente"
test -f "$ROOT/.project-kit.lock" || fail ".project-kit.lock ausente"

CONFLICTS="$(find "$ROOT" -name '*.kit-new*' -type f 2>/dev/null | wc -l | tr -d ' ')"
log "import concluído"
log "conflitos .kit-new: $CONFLICTS"
log "próximo passo: /refactor para projeto existente; /plan para projeto novo"
