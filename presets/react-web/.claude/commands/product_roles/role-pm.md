# Role: PM / Product

## Sua contribuição
Gera as seções "Objetivo", "Escopo", "Fora de escopo" e "Critérios de aceite" do plano, definindo valor, jornada do usuário e o que constitui entrega completa.

## Referência
- docs/ai/FEATURE_GUIDE.md

## O que incluir

- **Objetivo**: quem é o usuário, qual problema resolve e qual resultado esperado. Uma frase clara e concreta — sem jargão técnico.
- **Escopo**: liste tudo que faz parte da entrega. Inclua fluxo principal e fluxos alternativos relevantes (cancelamento, erro, vazio, sem permissão, retry).
- **Fora de escopo**: seja explícito sobre o que NÃO será feito. Isso evita ambiguidade e expectativa desalinhada.
- **Jornada do usuário**: descreva o fluxo principal passo a passo do ponto de vista de quem usa. Não liste implementação — liste ações e resultados.
- **Estados assíncronos**: loading, empty, error — defina a experiência de cada um. Nenhum estado pode ficar sem decisão.
- **Critérios de aceite**: lista objetiva e testável de condições para considerar a feature pronta. Cada critério deve ser verificável sem interpretação.

## Regras

- Objetivo deve ser compreensível por qualquer pessoa do time, sem conhecimento técnico.
- Critérios de aceite devem ser objetivos e testáveis — sem termos vagos como "funciona bem" ou "está ok".
- Não liste implementação no escopo — liste comportamento e resultado.
- Todo fluxo alternativo relevante deve estar coberto — ignorar fluxos comuns é risco.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Objetivo
{Quem, qual problema, qual resultado — 1-3 frases}

## Escopo

### Jornada principal
1. {Usuário faz X}
2. {Sistema responde Y}
3. ...

### Fluxos alternativos
- **{Cenário}**: {O que acontece}
- **{Cenário}**: {O que acontece}

### Estados assíncronos
| Estado | Experiência |
|--------|------------|
| loading | {O que o usuário vê} |
| error | {O que o usuário vê + ação disponível} |
| empty | {O que o usuário vê + ação disponível} |

## Fora de escopo
- {Item excluído com justificativa}
- ...

## Critérios de aceite
- [ ] {Critério objetivo e testável 1}
- [ ] {Critério objetivo e testável 2}
- [ ] ...
```
