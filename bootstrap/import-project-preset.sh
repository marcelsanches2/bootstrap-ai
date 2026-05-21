#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"
ROOT="$(cd "$TARGET" && (git rev-parse --show-toplevel 2>/dev/null || pwd))"

log() { printf '[bootstrap-ai-import] %s\n' "$*"; }
fail() { printf '[bootstrap-ai-import] erro: %s\n' "$*" >&2; exit 1; }

# Accepted names: new (bootstrap-ai) and old (bootstrap-ai)
_KIT_NAMES=("bootstrap-ai" "bootstrap-ai")

find_bootstrap_ai() {
  # 1. Explicit environment variable
  if [ -n "${BOOTSTRAP_AI_PATH:-}" ] && [ -x "${BOOTSTRAP_AI_PATH}/bin/bootstrap-ai" ]; then
    printf '%s\n' "$BOOTSTRAP_AI_PATH"
    return 0
  fi

  # 2. Common user workspaces
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
    # Directly at workspace root (tests both names)
    for name in "${_KIT_NAMES[@]}"; do
      if [ -x "$ws/$name/bin/bootstrap-ai" ]; then
        printf '%s\n' "$ws/$name"
        return 0
      fi
    done
    # One level deeper (e.g.: workspace/group/bootstrap-ai)
    if [ -d "$ws" ]; then
      local found
      for name in "${_KIT_NAMES[@]}"; do
        found=$(find "$ws" -maxdepth 2 -path "*/$name/bin/bootstrap-ai" -executable -print -quit 2>/dev/null | sed 's|/bin/bootstrap-ai$||')
        if [ -n "$found" ]; then
          printf '%s\n' "$found"
          return 0
        fi
      done
    fi
  done

  # 3. Default locations (both names)
  for name in "${_KIT_NAMES[@]}"; do
    for d in "$HOME/.local/share/$name" "$HOME/$name"; do
      if [ -x "$d/bin/bootstrap-ai" ]; then
        printf '%s\n' "$d"
        return 0
      fi
    done
  done

  return 1
}

find_workspace_dir() {
  # Search for existing workspace in preference order
  for d in "$HOME/workspace" "$HOME/code" "$HOME/projects" "$HOME/dev" "$HOME/work" "$HOME/repos" "$HOME/development" "$HOME/sources" "$HOME/src"; do
    if [ -d "$d" ]; then
      printf '%s\n' "$d"
      return 0
    fi
  done
  # Create default workspace if none exists
  mkdir -p "$HOME/workspace"
  printf '%s\n' "$HOME/workspace"
}

detect_project_name() {
  # Try to detect the target project name for placeholder substitution
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
  # 4. Fallback: directory name
  printf '%s\n' "$(basename "$root")"
}

# If we already have a valid BOOTSTRAP_AI_DIR (passed via env or embedded source), skip search
if [ -n "${BOOTSTRAP_AI_DIR:-}" ] && [ -x "${BOOTSTRAP_AI_DIR}/bin/bootstrap-ai" ]; then
  log "usando BOOTSTRAP_AI_DIR pré-configurado: $BOOTSTRAP_AI_DIR"
elif BOOTSTRAP_AI_DIR="$(find_bootstrap_ai)"; then
  log "bootstrap-ai encontrado: $BOOTSTRAP_AI_DIR"
else
  WORKSPACE_DIR="$(find_workspace_dir)"
  BOOTSTRAP_AI_DIR="$WORKSPACE_DIR/bootstrap-ai"
  log "clonando bootstrap-ai em $BOOTSTRAP_AI_DIR"
  if command -v gh >/dev/null 2>&1; then
    gh repo clone marcelsanches2/bootstrap-ai "$BOOTSTRAP_AI_DIR"
  else
    git clone https://github.com/marcelsanches2/bootstrap-ai.git "$BOOTSTRAP_AI_DIR"
  fi
fi

log "raiz do projeto alvo: $ROOT"
log "atualizando bootstrap-ai"
git -C "$BOOTSTRAP_AI_DIR" pull --ff-only

log "analisando stack e cobertura do kit"
"$BOOTSTRAP_AI_DIR/bin/bootstrap-ai" analyze "$ROOT"
KIT="$($BOOTSTRAP_AI_DIR/bin/bootstrap-ai select "$ROOT" --create-missing --print-preset)"
log "kit selecionado: $KIT"

log "diff não destrutivo"
"$BOOTSTRAP_AI_DIR/bin/bootstrap-ai" diff "$KIT" "$ROOT"

# Detect project name to replace placeholders
PROJECT_NAME="$(detect_project_name "$ROOT")"
log "nome do projeto detectado: $PROJECT_NAME"

log "aplicando preset sem --force"
"$BOOTSTRAP_AI_DIR/bin/bootstrap-ai" apply "$KIT" "$ROOT" --refresh --project-name "$PROJECT_NAME"

log "verificando arquivos principais"
test -f "$ROOT/CLAUDE.md" || fail "CLAUDE.md ausente"
test -f "$ROOT/.claude/commands/plan.md" || fail "plan.md ausente"
test -f "$ROOT/.claude/commands/jarvis-plan-revisor.md" || fail "jarvis-plan-revisor.md ausente"
test -f "$ROOT/.claude/commands/refactor.md" || fail "refactor.md ausente"
test -f "$ROOT/.claude/commands/jarvis-test-flow.md" || fail "jarvis-test-flow.md ausente"
test -d "$ROOT/docs/ai" || fail "docs/ai ausente"
test -f "$ROOT/.bootstrap-ai.lock" || fail ".bootstrap-ai.lock ausente"

CONFLICTS="$(find "$ROOT" -name '*.kit-new*' -type f 2>/dev/null | wc -l | tr -d ' ')"
log "import concluído"
log "conflitos .kit-new: $CONFLICTS"
log "próximo passo: /refactor para projeto existente; /plan para projeto novo"
