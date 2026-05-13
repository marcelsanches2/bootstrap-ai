# /ship

Checklist final antes de encerrar uma mudança.

1. Ler o plano revisado em `plans/`.
2. Confirmar que `/jarvis-test-flow` foi executado ou justificar por que não se aplica.
3. Verificar `git diff --stat` e `git status`.
4. Garantir que não há secrets, logs sensíveis ou arquivos temporários.
5. Resumir arquivos alterados, comandos executados, riscos restantes e próximo passo.
6. Não fazer push force.
