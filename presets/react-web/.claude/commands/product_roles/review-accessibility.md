# Role: Acessibilidade

## Sua contribuição
Gera a seção "Acessibilidade" do plano, definindo navegação por teclado, ARIA, gestão de foco, HTML semântico e suporte a leitores de tela.

## Referência
- docs/ai/ACCESSIBILITY_GUIDE.md

## O que incluir

- **HTML semântico**: elementos corretos para cada ação, navegação e estrutura — `<button>` para ações, `<nav>` para navegação, `<main>` para conteúdo, headings hierárquicos. Nunca use `div`/`span` onde um elemento semântico é mais apropriado.
- **Navegação por teclado**: Tab order lógico, Enter/Space ativam controles, Escape fecha modais/drawers. Defina o fluxo completo por teclado — nenhuma ação pode depender só de mouse.
- **Labels acessíveis**: todo input, botão e ícone deve ter nome acessível (`aria-label`, `aria-labelledby`, `<label>` associado, `alt` em imagens). Nenhum controle pode ser invisível para leitor de tela.
- **Gestão de foco**: para modais, toasts, erro inline e conteúdo dinâmico — onde o foco vai ao abrir/fechar, como retornar ao trigger.
- **ARIA dinâmico**: `aria-live`, `role="alert"`, `aria-expanded`, `aria-hidden` — quando e como usar para anunciar mudanças de estado.
- **Contraste e visibilidade**: estados de foco visíveis, contraste mínimo de texto e bordas funcionais. Defina como o foco é indicado visualmente.

## Regras

- Toda ação interativa deve funcionar por teclado — sem exceção.
- Nunca substitua elemento semântico por `div` com click handler.
- Controles sem label acessível são proibidos.
- Modal/dialog sem gestão de foco e trap são proibidos.
- Estados dinâmicos (erro, toast, loading) devem ser anunciados via ARIA live regions.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Acessibilidade

### HTML semântico
| Elemento | Uso | Justificativa |
|----------|-----|---------------|
| {tag} | {onde} | {por quê} |

### Navegação por teclado
| Ação | Tecla | Comportamento |
|------|-------|---------------|
| {ação} | {Tab/Enter/Escape/Space} | {o que acontece} |

### Labels acessíveis
| Controle | Nome acessível | Método |
|----------|---------------|--------|
| {elemento} | {texto visível ou descritivo} | {aria-label / label / alt} |

### Gestão de foco
| Contexto | Foco ao abrir | Foco ao fechar |
|----------|--------------|----------------|
| {modal/drawer/erro} | {para onde vai} | {onde retorna} |

### ARIA dinâmico
| Elemento | Atributo | Valor | Quando |
|----------|----------|-------|--------|
| {elemento} | aria-live / role / aria-expanded | {valor} | {trigger} |

### Contraste e foco visual
{Como o foco é indicado, contraste mínimo garantido}
```
