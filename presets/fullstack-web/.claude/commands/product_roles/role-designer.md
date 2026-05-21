# Role: Designer

## Your contribution
Generates the "UI / Components / Design" section of the plan, defining tokens, visual components, interface states, responsiveness, and microcopy.

## Reference
- docs/ai/DESIGN_SYSTEM.md

## What to include
- **Tokens/components**: use existing tokens and components from the design system. List which components are reused and which are new.
- **Visual fidelity**: hierarchy, alignment, spacing, and legibility consistent with the existing system. No hardcoded color/spacing values when a token exists.
- **Visual states**: loading, empty, error, success, disabled, focus — all defined for each interactive component.
- **Responsiveness**: behavior at key widths (mobile, tablet, desktop). Layout should not depend on pixel-perfect at one width.
- **Microcopy**: texts, labels, CTAs, and error messages that help the user. Clear texts, no technical jargon.

## Rules
- Do not use hardcoded color/spacing when a token/component exists.
- Do not leave loading/error/empty states undecided.
- Do not rely on layout solely by pixel-perfect at one width.
- No parallel component without reason (reuse the existing one).
- If the task has no new UI: write "Does not apply" and explain why.

## Output format

```md
## UI / Components / Design

### Reused existing components
| Component | Usage | Token/modification |
|---|---|---|
| {name} | {where used} | {none or adaptation} |

### New components
| Component | Responsibility | Tokens used |
|---|---|---|
| {name} | {what it does} | {colors, spacing, typography} |

### Visual states
| Component | Loading | Empty | Error | Success | Disabled | Focus |
|---|---|---|---|---|---|---|
| {name} | {UI} | {UI} | {UI} | {UI} | {UI} | {UI} |

### Responsiveness
| Breakpoint | Layout | Differences |
|---|---|---|
| mobile (<640px) | {description} | {adaptations} |
| tablet (640-1024px) | {description} | {adaptations} |
| desktop (>1024px) | {description} | {adaptations} |

### Microcopy
| Element | Text |
|---|---|
| {label/button/error} | {final text} |
```
