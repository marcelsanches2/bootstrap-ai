# Padrão: Loop Corretivo

Ciclo iterativo de revisão que continua até que todas as pendências sejam resolvidas.

## Quando usar

- Após revisão multi-role encontrar BLOCKERs ou MAJORs
- Quando o plano precisa ser corrigido antes de prosseguir
- Em qualquer fluxo onde "revisar → corrigir → revalidar" é necessário

## Estrutura

```
## Loop Corretivo

### Condição de entrada
Existem pendências BLOCKER ou MAJOR não resolvidas.

### Ciclo (máximo N iterações)

1. **Corrigir**: aplique a correção sugerida ou a resposta do usuário
2. **Revalidar**: rode novamente a revisão/especificação que gerou a pendência
3. **Avaliar**:
   - Pendência resolvida? → remover da lista
   - Pendência persiste? → reformular sugestão e perguntar ao usuário
   - Nova pendência encontrada? → adicionar à lista

### Condição de saída
- Zero BLOCKER + zero MAJOR pendentes → **APROVADO**
- Máximo de iterações atingido → **ESCALAR**: apresentar ao usuário o que não foi resolvido e pedir decisão

### Limite de iterações
Padrão: 3 iterações por pendência. Se não resolver em 3, escalar para o usuário.
```

## Regras

- NUNCA aprovar com BLOCKER pendente
- MAJOR pendente só é aceitável se o usuário explicitamente aceitar o risco
- Cada iteração deve ter escopo menor que a anterior (convergência)
- Se o loop diverge (mais pendências surgem do que resolvem), pare e escale
- Documente cada iteração: o que foi corrigido, o que persistiu

## Variações

### Loop no Revisor (jarvis-plan-revisor)
O revisor corrige o plano interativamente com o usuário, não o código.
- Entrada: plano com MAJOR
- Correção: atualizar plano (não código)
- Revalidação: re-rodar o role que achou a pendência

### Loop no Implementador (pós-revisão)
O implementador corrige o código, roda testes, e revalida.
- Entrada: código com falha de teste
- Correção: corrigir código
- Revalidação: rodar testes novamente

## Referência

Inspiração: Archon `loop` nodes com `until: ALL_TASKS_COMPLETE`.
Diferença: no bootstrap-ai, o loop é declarativo no comando com limite explícito e escalação.
