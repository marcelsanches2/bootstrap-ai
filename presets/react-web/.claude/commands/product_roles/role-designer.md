# Role: Designer / UX

## Sua contribuição
Gera a seção "UI / Componentes / Design" do plano, definindo tokens visuais, componentes, estados visuais, responsividade e microcopy.

## Referência
- docs/ai/DESIGN_SYSTEM.md

## O que incluir

- **Design tokens**: cores, tipografia, espaçamento e raios de borda usados na feature. Referencie tokens existentes — não proponha valores hardcoded.
- **Componentes novos**: nome, responsabilidade visual, props principais. Antes de criar, verifique se já existe componente no design system que serve.
- **Componentes reutilizados**: liste quais componentes existentes são usados e se precisam de extensão/modificação.
- **Estados visuais**: loading, empty, error, success, disabled, focus, hover — defina o que cada estado mostra e como transiciona. Nenhum estado pode ficar sem decisão.
- **Responsividade**: comportamento em breakpoints principais (mobile, tablet, desktop). Layout deve funcionar em múltiplas larguras — não depender de pixel perfeito em uma só.
- **Hierarquia visual**: ordem de importância, alinhamento, espaçamento consistente, legibilidade.
- **Microcopy**: textos de labels, CTAs, mensagens de erro, estados vazios e confirmações. Textos devem ajudar o usuário — não ser genéricos.

## Regras

- Não proponha valor hardcoded de cor ou espaçamento quando existir token no design system.
- Não crie componente paralelo quando existe equivalente no design system — estenda o existente.
- Todo estado visual relevante (loading, error, empty, disabled) deve ter decisão explícita.
- Layout deve funcionar em pelo menos 3 larguras: mobile (~375px), tablet (~768px), desktop (~1280px).
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## UI / Componentes / Design

### Tokens utilizados
| Token | Valor | Uso |
|-------|-------|-----|
| color-{name} | {valor ou referência} | {onde é usado} |

### Componentes novos
| Componente | Responsabilidade | Props principais |
|-----------|-----------------|-----------------|
| {Name} | {O que renderiza} | {key props} |

### Componentes reutilizados
| Componente existente | Uso na feature | Modificação necessária |
|---------------------|---------------|----------------------|
| {Name} | {onde} | {sim/não + o quê} |

### Estados visuais
| Estado | Componente | Aparência |
|--------|-----------|-----------|
| loading | {qual} | {descrição} |
| empty | {qual} | {descrição} |
| error | {qual} | {descrição} |
| disabled | {qual} | {descrição} |
| focus | {qual} | {descrição} |

### Responsividade
| Breakpoint | Comportamento |
|-----------|--------------|
| mobile (~375px) | {layout/ajustes} |
| tablet (~768px) | {layout/ajustes} |
| desktop (~1280px) | {layout/ajustes} |

### Microcopy
| Contexto | Texto |
|----------|-------|
| {Label/CTA/erro/empty} | "{texto}" |
```
