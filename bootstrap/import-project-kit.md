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

### 4. Analisar stack e cobertura

Antes de importar qualquer coisa, rode:

```bash
"$PROJECT_KITS_DIR/bin/kit" analyze "$ROOT"
```

Isso detecta tecnologias centrais e bibliotecas estruturais por arquivos reais do projeto: `pubspec.yaml`, `pyproject.toml`, `requirements.txt`, `package.json`, `go.mod`, `Gemfile`, configs de framework, dependências e sinais de banco. Exemplos: `dio`, `riverpod`, `go_router`, `sqlalchemy`, `alembic`, `prisma`, `tanstack-query`, `sidekiq`, `chi`, `pgx`.

### 5. Selecionar ou criar kit específico

```bash
KIT="$($PROJECT_KITS_DIR/bin/kit select "$ROOT" --create-missing --print-kit)"
printf 'Kit selecionado: %s
' "$KIT"
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

### 7. Aplicar kit

```bash
"$PROJECT_KITS_DIR/bin/kit" apply "$KIT" "$ROOT" --refresh
```

Não use `--force`.

### 8. Verificar importação

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

### 9. Resposta final

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
