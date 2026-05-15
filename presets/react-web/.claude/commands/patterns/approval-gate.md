# Padrão: Approval Gate

Ponto de parada obrigatório que exige resposta humana antes de prosseguir.

## Quando usar

- Antes de executar um plano que foi revisado (transição revisão → execução)
- Antes de fazer ship/deploy (transição dev → produção)
- Antes de apendar revisão em plano original
- Em qualquer ponto onde o custo de erro é irreversível

## Estrutura

```
## Gate: <NOME DO GATE>

**Condição para parar:**
- <lista de condições que disparam o gate>

**Ação:**
1. Apresente o resumo do que será feito
2. Pergunte explicitamente: "Prosseguir com <ação>? (sim/não)"
3. Aguarde resposta do usuário
4. Só execute após confirmação explícita

**Se recusado:**
- Pare o fluxo
- Registre o motivo da recusa
- Sugira próximos passos
```

## Regras

- NUNCA prosseguir sem confirmação explícita ("sim", "prossiga", "ok")
- Silêncio ou ambiguidade = NÃO
- Apresentar resumo conciso do que será feito ANTES de pedir aprovação
- Se o usuário pedir mudanças, incorporar e voltar ao gate

## Referência

Inspiração: Archon `approval` nodes — pausa workflow até humano aprovar.
Diferença: no bootstrap-ai, o gate é declarativo dentro do comando, não um tipo de node.
