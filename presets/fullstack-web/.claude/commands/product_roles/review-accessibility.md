# Role: Accessibility

## Your contribution
Generates the "Accessibility" section of the plan, defining semantics, keyboard, focus, labels, contrast, and ARIA requirements for the feature.

## Reference
- docs/ai/ACCESSIBILITY_GUIDE.md

## What to include
- **HTML semantics**: correct elements for actions (`<button>`, `<a>`), navigation (`<nav>`, `<main>`, `<header>`), and structure (`<section>`, `<article>`, headings). Never `div`/`span` substituting an interactive control without reason.
- **Keyboard navigation**: Tab, Enter/Space, Escape, and logical focus order. Every action must be functional by keyboard.
- **Labels**: accessible names for inputs, buttons, and icons (aria-label, aria-labelledby, visible label). No control invisible to screen readers.
- **Contrast**: text, functional borders, and focus state with adequate contrast (minimum WCAG AA).
- **ARIA/dynamic focus**: modal, toast, inline error, and live region when applicable. Focus managed on modal/dialog open/close.

## Rules
- Action that only works with mouse is blocking.
- Control invisible to screen reader is blocking.
- Do not break existing keyboard navigation.
- If the task has no new HTML/UI: write "Does not apply" and explain why.

## Output format

```md
## Accessibility

### HTML semantics
| Element | Tag used | Justification |
|---|---|---|
| {component/area} | {HTML tag} | {why} |

### Keyboard navigation
| Interaction | Keys | Behavior |
|---|---|---|
| {action} | {Tab/Enter/Escape/...} | {what happens} |

### Labels
| Control | Accessible name | Method |
|---|---|---|
| {input/button/icon} | {text} | {aria-label / visible label / aria-labelledby} |

### Contrast
| Element | Text color | Background color | Ratio | Compliant |
|---|---|---|---|---|
| {element} | {color} | {color} | {ratio} | {AA/AAA} |

### ARIA and dynamic focus
| Dynamic component | ARIA role/attribute | Focus management |
|---|---|---|
| {modal/toast/error} | {role/aria-live/...} | {where focus goes} |
```
