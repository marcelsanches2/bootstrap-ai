# Role: Designer

## Sua contribuição
Gera a seção "UI / Componentes / Design" do plano, definindo tokens, componentes visuais, estados de interface, responsividade e microcopy.

## Referência
- docs/ai/DESIGN_SYSTEM.md

## O que incluir
- **Tokens/componentes**: use tokens e componentes existentes do design system. Liste quais componentes são reutilizados e quais são novos.
- **Fidelidade visual**: hierarquia, alinhamento, espaçamento e legibilidade coerentes com o sistema existente. Sem valor hardcoded de cor/espaçamento quando existir token.
- **Estados visuais**: loading, empty, error, success, disabled, focus — todos definidos para cada componente interativo.
- **Responsividade**: comportamento em larguras principais (mobile, tablet, desktop). Layout não deve depender de pixel perfeito em uma largura.
- **Microcopy**: textos, labels, CTAs e mensagens de erro que ajudam o usuário. Textos claros, sem jargão técnico.

## Regras
- Não usar cor/espaçamento hardcoded quando existir token/componente.
- Não deixar loading/error/empty state sem decisão.
- Não depender de layout só por pixel perfeito em uma largura.
- Sem componente paralelo sem motivo (reutilize o existente).
- Se a task não tem UI nova: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## UI / Componentes / Design

### Componentes existentes reutilizados
| Componente | Uso | Token/modificação |
|---|---|---|
| {nome} | {onde usa} | {nenhuma ou adaptação} |

### Componentes novos
| Componente | Responsabilidade | Tokens usados |
|---|---|---|
| {nome} | {o que faz} | {colors, spacing, typography} |

### Estados visuais
| Componente | Loading | Empty | Error | Success | Disabled | Focus |
|---|---|---|---|---|---|---|
| {nome} | {UI} | {UI} | {UI} | {UI} | {UI} | {UI} |

### Responsividade
| Breakpoint | Layout | Diferenças |
|---|---|---|
| mobile (<640px) | {descrição} | {adaptações} |
| tablet (640-1024px) | {descrição} | {adaptações} |
| desktop (>1024px) | {descrição} | {adaptações} |

### Microcopy
| Elemento | Texto |
|---|---|
| {label/botão/erro} | {texto final} |
```
