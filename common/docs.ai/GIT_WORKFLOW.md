# Git Workflow

Fluxo Git comum para projetos usando bootstrap-ai.

## Princípios

- Commit pequeno com intenção clara.
- Diff revisável.
- Não commitar secrets, dumps, `.env` real, build output desnecessário ou arquivo gerado sem motivo.
- Branch/commit deve refletir escopo da mudança.

## Antes de editar

```bash
git status --short
git branch --show-current
```

Se houver alterações do usuário, não sobrescreva sem entender.

## Antes de commit

```bash
git diff --check
git diff --stat
```

Rode também o `/jarvis-test-flow` ou comandos equivalentes dO preset.

## Mensagem de commit

Use formato direto:

```txt
feat: add billing checkout validation
fix: handle expired session on webhook
refactor: isolate user repository
chore: update project preset docs
```

## Merge/deploy

- PR/diff deve mencionar testes executados.
- Mudança com migration precisa rollback/backup.
- Mudança operacional precisa plano de deploy.
