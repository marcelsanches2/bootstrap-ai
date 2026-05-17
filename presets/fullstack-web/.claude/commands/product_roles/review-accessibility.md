# Role: Acessibilidade

## Sua contribuição
Gera a seção "Acessibilidade" do plano, definindo requisitos de semântica, teclado, foco, labels, contraste e ARIA para a feature.

## Referência
- docs/ai/ACCESSIBILITY_GUIDE.md

## O que incluir
- **Semântica HTML**: elementos corretos para ações (`<button>`, `<a>`), navegação (`<nav>`, `<main>`, `<header>`) e estrutura (`<section>`, `<article>`, headings). Nunca `div`/`span` substituindo controle interativo sem motivo.
- **Navegação por teclado**: Tab, Enter/Espaço, Escape e ordem de foco lógica. Toda ação funcional por teclado.
- **Labels**: nomes acessíveis para inputs, botões e ícones (aria-label, aria-labelledby, visible label). Nenhum controle invisível para leitor de tela.
- **Contraste**: texto, bordas funcionais e estado de foco com contraste adequado (mínimo WCAG AA).
- **ARIA/foco dinâmico**: modal, toast, erro inline e live region quando aplicável. Foco gerenciado em abertura/fechamento de modal/diálogo.

## Regras
- Ação que só funciona com mouse é bloqueante.
- Controle invisível para leitor de tela é bloqueante.
- Não quebrar navegação por teclado existente.
- Se a task não tem HTML/UI novo: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Acessibilidade

### Semântica HTML
| Elemento | Tag usada | Justificativa |
|---|---|---|
| {componente/área} | {tag HTML} | {por quê} |

### Navegação por teclado
| Interação | Teclas | Comportamento |
|---|---|---|
| {ação} | {Tab/Enter/Escape/...} | {o que acontece} |

### Labels
| Controle | Nome acessível | Método |
|---|---|---|
| {input/botão/ícone} | {texto} | {aria-label / visible label / aria-labelledby} |

### Contraste
| Elemento | Cor texto | Cor fundo | Ratio | Conforme |
|---|---|---|---|---|
| {elemento} | {cor} | {cor} | {ratio} | {AA/AAA} |

### ARIA e foco dinâmico
| Componente dinâmico | ARIA role/attribute | Gerenciamento de foco |
|---|---|---|
| {modal/toast/erro} | {role/aria-live/...} | {para onde foco vai} |
```
