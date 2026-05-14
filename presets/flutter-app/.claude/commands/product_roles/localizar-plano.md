# Skill filha: localizar-plano

## Objetivo

Encontrar o plano técnico que será revisado.

## Relação com referências

Esta filha não valida conteúdo do plano e não depende diretamente dos documentos carregados por `product_roles/carregar-referencias.md`.

Mesmo assim, sua saída deve ser usada por todos os filhos posteriores junto com o conjunto de referências carregadas.

## Entrada

- Argumento opcional do usuário com caminho do plano, sempre busque pelo arquivo de plano mais recente.
- Diretório padrão: `~/.claude/plans/*.md`.

## Procedimento

1. Verifique se o diretório `plans/` existe.
2. Liste os arquivos dentro de `plans/`.
3. Se o usuário informou um arquivo:
   - Verifique se ele existe.
   - Se existir, use-o.
   - Se não existir, reporte erro e pare.
4. Se o usuário não informou arquivo:
   - Tente localizar o arquivo mais recente via Git:
     - `git log -1 --name-only -- plans/`
   - Se isso não retornar um plano válido, use:
     - `ls -t plans/ | head -1`
5. Se nenhum arquivo for encontrado:
   - Reporte: `Nenhum plano encontrado em plans/.`
   - Pare a execução.

## Saída esperada

```md
Plano localizado: `<caminho-do-plano>`
Método usado: `<argumento | git log | ls -t>`
```

## Regras

- Não escolha arquivo fora de `plans/` sem argumento explícito.
- Não invente nome de plano.
- Não continue se o plano não existir.
