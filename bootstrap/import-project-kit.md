---
name: import-project-kit
description: Importa o project-kits correto para o projeto atual de forma não destrutiva.
---

# /import-project-kit

Importa o kit correto do repositório `marcelsanches2/project-kits` para dentro do projeto atual.

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
2. Garantir que o repo `project-kits` existe localmente.
3. Atualizar o repo `project-kits`.
4. Detectar o kit correto para o projeto atual.
5. Mostrar diff do que será importado.
6. Aplicar o kit em modo não destrutivo.
7. Verificar se os arquivos principais entraram.

## Regras duras

- Nunca sobrescrever arquivos existentes silenciosamente.
- Não usar `--force`.
- Se houver conflito, aceitar criação de `.kit-new`.
- Não commitar automaticamente.
- Não modificar código de produção.
- Não rodar `/refactor` automaticamente; apenas explicar que ele é o próximo passo opcional.

## Procedimento obrigatório

### 1. Resolver raiz do projeto

Execute:

```bash
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
printf 'Project root: %s\n' "$ROOT"
```

Use `$ROOT` como projeto alvo.

### 2. Localizar ou clonar `project-kits`

Procure nesta ordem:

```bash
$PROJECT_KITS_PATH
$HOME/repos/project-kits
$HOME/project-kits
$HOME/.local/share/project-kits
```

Se não existir, clone:

```bash
mkdir -p "$HOME/.local/share"
gh repo clone marcelsanches2/project-kits "$HOME/.local/share/project-kits"
```

Se `gh` não estiver disponível, use git HTTPS:

```bash
git clone https://github.com/marcelsanches2/project-kits.git "$HOME/.local/share/project-kits"
```

### 3. Atualizar `project-kits`

```bash
cd "$PROJECT_KITS_DIR"
git pull --ff-only
```

Se `git pull --ff-only` falhar, pare e reporte. Não faça merge/rebase automático.

### 4. Detectar kit

```bash
"$PROJECT_KITS_DIR/bin/kit" detect "$ROOT"
```

Se a detecção for ambígua ou falhar, pergunte ao usuário qual kit usar:

- `flutter-app`
- `python-backend`
- `react-web`
- `node-backend`

### 5. Mostrar diff

```bash
"$PROJECT_KITS_DIR/bin/kit" diff auto "$ROOT"
```

Explique que:

- `Would create` = arquivos que serão criados
- `Would skip identical` = já iguais
- `Would conflict` = serão criados como `.kit-new`

### 6. Aplicar kit

```bash
"$PROJECT_KITS_DIR/bin/kit" apply auto "$ROOT" --refresh
```

Não use `--force`.

### 7. Verificar importação

Verifique se existem:

```txt
$ROOT/CLAUDE.md
$ROOT/.claude/commands/plan.md
$ROOT/.claude/commands/jarvis-revisor.md
$ROOT/.claude/commands/refactor.md
$ROOT/.claude/commands/test-flow.md
$ROOT/docs/ai/
$ROOT/plans/
$ROOT/.project-kit.lock
```

Execute:

```bash
test -f "$ROOT/.claude/commands/refactor.md" && echo "refactor OK"
test -f "$ROOT/.project-kit.lock" && echo "lock OK"
```

### 8. Resposta final

Reporte:

```txt
Kit aplicado: <kit>
Project-kits usado: <path>
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
