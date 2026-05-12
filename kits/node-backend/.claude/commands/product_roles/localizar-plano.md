# Skill filha: localizar-plano

Localize o plano técnico em `plans/`.

1. Se o usuário informou arquivo, valide que existe.
2. Se não informou, tente `git log -1 --name-only -- plans/`.
3. Fallback: arquivo mais recente por mtime em `plans/*.md`.
4. Se nenhum plano existir, reporte e pare.

Saída: `Plano localizado: <arquivo>` e método usado.
