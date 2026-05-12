# Skill filha: localizar-plano

Localize o plano técnico em `plans/` sem alterar arquivos.

## Ordem de busca

1. Se o usuário informou arquivo, valide que existe e está em `plans/` ou foi explicitamente permitido.
2. Se não informou, tente o último plano tocado pelo git:
   `git log -1 --name-only -- plans/`
3. Fallback: arquivo mais recente por mtime em `plans/*.md`.
4. Se houver empate ou ambiguidade, liste candidatos e pare pedindo escolha.
5. Se nenhum plano existir, reporte e pare.

## Saída obrigatória

```md
Plano localizado: `<arquivo>`
Método usado: usuário | git | mtime
```

## Regra dura

Não revise código solto como se fosse plano. Se não há plano, a revisão deve falhar cedo.
