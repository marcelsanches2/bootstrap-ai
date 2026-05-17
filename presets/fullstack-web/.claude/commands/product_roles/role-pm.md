# Role: PM

## Sua contribuição
Gera as seções "Objetivo", "Escopo", "Fora de escopo" e "Critérios de aceite" do plano, garantindo que valor, jornada do usuário e limites estejam claros.

## Referência
- docs/ai/FEATURE_GUIDE.md

## O que incluir
- **Objetivo**: quem é o usuário, qual problema resolve, qual resultado esperado — em linguagem de negócio, não técnica.
- **Fluxo principal**: jornada do usuário no caminho feliz (passo a passo).
- **Fluxos alternativos**: cancelamento, sem permissão, retry, caminhos de desvio relevantes.
- **Error states**: tratamento de erro na interface E no backend (duplicado, insuficiente, timeout, 4xx/5xx).
- **Estados loading/vazio**: UX definida para estados assíncronos e listas vazias.
- **Critérios de aceite**: objetivos, testáveis, sem ambiguidade entre dev e PM. Cada critério deve ser verificável.
- **Dados de teste / massa**: dados necessários para validar a feature.
- **Breaking changes**: mudanças que quebram contrato existente identificadas e comunicadas.
- **Migration impact**: impacto de migrations em features existentes e UX.
- **Impacto em features existentes**: efeitos colaterais em features já entregues.
- **Escopo**: o que entra nesta entrega.
- **Fora de escopo**: o que explicitamente NÃO entra nesta entrega.

## Regras
- Fluxo principal não descrito é bloqueante.
- Critério de aceite ambíguo ou subjetivo é bloqueante.
- Breaking change não documentado é bloqueante.
- Se a task é puramente infra/exploratória sem jornada de usuário: adapte os itens que fazem sentido e marque o resto como "Não se aplica" com justificativa.

## Formato de saída

```md
## Objetivo
{1-3 frases: usuário, problema, resultado esperado}

## Escopo
- {item que entra}
- {item que entra}
- ...

## Fora de escopo
- {item que não entra}
- {item que não entra}

## Fluxo principal
1. {passo do usuário}
2. {passo do usuário}
3. ...

## Fluxos alternativos
- {cenário}: {o que acontece}

## Error states
| Cenário | Frontend | Backend |
|---|---|---|
| {erro} | {UI de erro} | {status + action} |

## Estados loading/vazio
| Estado | UI |
|---|---|
| loading | {o que o usuário vê} |
| vazio | {o que o usuário vê} |

## Critérios de aceite
- [ ] {critério verificável 1}
- [ ] {critério verificável 2}
- ...

## Dados de teste
{dados necessários ou seed}

## Breaking changes
{lista ou "Nenhuma"}

## Migration impact
{impacto ou "Nenhuma migration"}

## Impacto em features existentes
{efeitos colaterais ou "Nenhum"}
```
