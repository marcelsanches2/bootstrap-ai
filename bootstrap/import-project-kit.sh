#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"
ROOT="$(cd "$TARGET" && (git rev-parse --show-toplevel 2>/dev/null || pwd))"

log() { printf '[project-kit-import] %s\n' "$*"; }
fail() { printf '[project-kit-import] erro: %s\n' "$*" >&2; exit 1; }

find_project_kits() {
  if [ -n "${PROJECT_KITS_PATH:-}" ] && [ -x "$PROJECT_KITS_PATH/bin/kit" ]; then
    printf '%s\n' "$PROJECT_KITS_PATH"; return 0
  fi
  for d in "$HOME/repos/project-kits" "$HOME/project-kits" "$HOME/.local/share/project-kits"; do
    if [ -x "$d/bin/kit" ]; then printf '%s\n' "$d"; return 0; fi
  done
  return 1
}

if PROJECT_KITS_DIR="$(find_project_kits)"; then
  log "project-kits encontrado: $PROJECT_KITS_DIR"
else
  PROJECT_KITS_DIR="$HOME/.local/share/project-kits"
  mkdir -p "$(dirname "$PROJECT_KITS_DIR")"
  log "clonando project-kits em $PROJECT_KITS_DIR"
  if command -v gh >/dev/null 2>&1; then
    gh repo clone marcelsanches2/project-kits "$PROJECT_KITS_DIR"
  else
    git clone https://github.com/marcelsanches2/project-kits.git "$PROJECT_KITS_DIR"
  fi
fi

log "raiz do projeto alvo: $ROOT"
log "atualizando project-kits"
git -C "$PROJECT_KITS_DIR" pull --ff-only

log "detectando kit"
"$PROJECT_KITS_DIR/bin/kit" detect "$ROOT" || fail "não consegui detectar kit automaticamente"

log "diff não destrutivo"
"$PROJECT_KITS_DIR/bin/kit" diff auto "$ROOT"

log "aplicando kit sem --force"
"$PROJECT_KITS_DIR/bin/kit" apply auto "$ROOT" --refresh

log "verificando arquivos principais"
test -f "$ROOT/CLAUDE.md" || fail "CLAUDE.md ausente"
test -f "$ROOT/.claude/commands/plan.md" || fail "plan.md ausente"
test -f "$ROOT/.claude/commands/jarvis-revisor.md" || fail "jarvis-revisor.md ausente"
test -f "$ROOT/.claude/commands/refactor.md" || fail "refactor.md ausente"
test -f "$ROOT/.claude/commands/test-flow.md" || fail "test-flow.md ausente"
test -d "$ROOT/docs/ai" || fail "docs/ai ausente"
test -f "$ROOT/.project-kit.lock" || fail ".project-kit.lock ausente"

CONFLICTS="$(find "$ROOT" -name '*.kit-new*' -type f 2>/dev/null | wc -l | tr -d ' ')"
log "import concluído"
log "conflitos .kit-new: $CONFLICTS"
log "próximo passo: /refactor para projeto existente; /plan para projeto novo"
