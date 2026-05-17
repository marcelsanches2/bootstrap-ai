# Role: Designer / UX

## Sua contribuição

Gera a seção "UI / Componentes / Design" do plano, definindo tokens, componentes visuais, estados visuais, responsividade e acessibilidade.

## Referência

- docs/ai/DESIGN_SYSTEM.md
- docs/ai/FEATURE_GUIDE.md

## O que incluir

- **Design system tokens usados** — listar cores, tipografia, espaçamento, bordas, elevação e quaisquer tokens do tema que a task utiliza. Referenciar o design system existente, não inventar valores.
- **Componentes visuais necessários** — listar cada widget/componente que será criado ou reutilizado, com descrição visual clara (hierarquia, alinhamento, espaçamento, conteúdo).
- **Estados visuais de cada componente** — para cada componente interativo, definir loading, empty, error, success e disabled states. Incluir transições visuais quando relevante.
- **Responsividade** — descrever comportamento em larguras principais (phone, tablet), orientações (portrait, landscape) e tamanhos de tela. Usar LayoutBuilder, MediaQuery ou convenção do projeto.
- **Acessibilidade visual** — declarar Semantics labels, contraste mínimo (WCAG AA), tamanho mínimo de touch target (48dp), ordem de leitura e hints de acessibilidade para cada componente interativo.

## Regras

- Usar apenas tokens e componentes do design system existente. Se precisar de token novo, justificar e propor o valor.
- Nenhum valor hardcoded de cor, espaçamento ou tipografia — sempre referenciar o tema.
- Todo componente interativo deve ter pelo menos loading, error e default states definidos.
- Touch targets mínimos de 48dp em todos os elementos clicáveis.
- Contraste mínimo de 4.5:1 para texto normal, 3:1 para texto grande (WCAG AA).
- Se a task não tem UI nova: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## UI / Componentes / Design

### Tokens utilizados

| Token | Valor | Uso |
|---|---|---|
| {corToken} | {valor} | {onde usa} |
| {typographyToken} | {valor} | {onde usa} |
| {spacingToken} | {valor} | {onde usa} |

### Componentes

#### {NomeDoComponente}

- **Descrição**: {composição visual, hierarquia, alinhamento}
- **Reutiliza**: {componente existente do DS ou "novo"}
- **Tokens**: {quais tokens usa}

**Estados visuais:**

| Estado | Visual | Interação |
|---|---|---|
| Default | {descrição} | {comportamento} |
| Loading | {descrição} | {comportamento} |
| Empty | {descrição} | {comportamento} |
| Error | {descrição} | {comportamento} |
| Disabled | {descrição} | {comportamento} |

#### {NomeDoComponente2}

- **Descrição**: ...
- ...

### Responsividade

| Breakpoint | Comportamento |
|---|---|
| Phone (< 600dp) | {layout e adaptações} |
| Tablet (600dp–840dp) | {layout e adaptações} |
| Landscape | {adaptações se diferente do portrait} |

### Acessibilidade visual

| Componente | Semantics label | Touch target | Contraste |
|---|---|---|---|
| {componente} | {label descritivo} | {≥ 48dp} | {≥ 4.5:1} |
| {componente} | ... | ... | ... |
```
