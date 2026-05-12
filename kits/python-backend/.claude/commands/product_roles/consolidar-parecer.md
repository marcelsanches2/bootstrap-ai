# Skill filha: consolidar-parecer

Consolide pareceres dos roles em uma decisão única e acionável.

## Severidade

- `BLOCKER`: risco de quebrar arquitetura, segurança, dados, contrato público, deploy ou impedir execução segura.
- `MAJOR`: precisa corrigir antes ou durante a implementação planejada; não bloqueia investigação, bloqueia entrega.
- `MINOR`: melhoria desejável; pode seguir se registrada.
- `INFO`: observação sem ação obrigatória.

## Regras de consolidação

1. Uma pendência `BLOCKER` reprova o plano.
2. `MAJOR` sem dono, arquivo ou correção sugerida vira `BLOCKER`.
3. Se dois papéis discordarem, escolha o parecer mais restritivo e explique o trade-off.
4. Não aceite "validar depois" para segurança, migration, contrato API ou dados destrutivos.
5. Toda pendência consolidada precisa ter: severidade, dono técnico, arquivo/área afetada e correção sugerida.

## Saída esperada

```md
## Pendências consolidadas

| Severidade | Papel | Área | Pendência | Correção exigida |
|---|---|---|---|---|
| BLOCKER/MAJOR/MINOR | papel responsável | módulo/arquivo afetado | risco observado | ação concreta |

## Decisão

Plano aprovado para execução. // ou
Plano aprovado com ajustes obrigatórios antes da execução. // ou
Plano reprovado. Corrigir arquitetura antes de executar.
```
