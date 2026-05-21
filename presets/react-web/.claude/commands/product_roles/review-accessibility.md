# Role: Accessibility

## Your contribution
Generates the "Accessibility" section of the plan, defining keyboard navigation, ARIA, focus management, semantic HTML, and screen reader support.

## Reference
- docs/ai/ACCESSIBILITY_GUIDE.md

## What to include

- **Semantic HTML**: correct elements for every action, navigation, and structure — `<button>` for actions, `<nav>` for navigation, `<main>` for content, hierarchical headings. Never use `div`/`span` where a semantic element is more appropriate.
- **Keyboard navigation**: logical Tab order, Enter/Space activate controls, Escape closes modals/drawers. Define the complete keyboard flow — no action can depend solely on mouse.
- **Accessible labels**: every input, button, and icon must have an accessible name (`aria-label`, `aria-labelledby`, associated `<label>`, `alt` on images). No control can be invisible to screen readers.
- **Focus management**: for modals, toasts, inline errors, and dynamic content — where focus goes on open/close, how to return to trigger.
- **Dynamic ARIA**: `aria-live`, `role="alert"`, `aria-expanded`, `aria-hidden` — when and how to use them to announce state changes.
- **Contrast and visibility**: visible focus states, minimum text and functional border contrast. Define how focus is visually indicated.

## Rules

- Every interactive action must work by keyboard — no exceptions.
- Never replace a semantic element with a `div` with a click handler.
- Controls without accessible labels are prohibited.
- Modal/dialog without focus management and trap are prohibited.
- Dynamic states (error, toast, loading) must be announced via ARIA live regions.
- If not applicable to the task: write "Does not apply" and explain why.

## Output format

```md
## Accessibility

### Semantic HTML
| Element | Usage | Justification |
|---------|-------|---------------|
| {tag} | {where} | {why} |

### Keyboard navigation
| Action | Key | Behavior |
|--------|-----|----------|
| {action} | {Tab/Enter/Escape/Space} | {what happens} |

### Accessible labels
| Control | Accessible name | Method |
|---------|----------------|--------|
| {element} | {visible or descriptive text} | {aria-label / label / alt} |

### Focus management
| Context | Focus on open | Focus on close |
|---------|--------------|----------------|
| {modal/drawer/error} | {where it goes} | {where it returns} |

### Dynamic ARIA
| Element | Attribute | Value | When |
|---------|-----------|-------|------|
| {element} | aria-live / role / aria-expanded | {value} | {trigger} |

### Contrast and visual focus
{How focus is indicated, minimum contrast guaranteed}
```
