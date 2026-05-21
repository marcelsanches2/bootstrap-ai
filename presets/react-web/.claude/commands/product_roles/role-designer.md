# Role: Designer / UX

## Your contribution
Generates the "UI / Components / Design" section of the plan, defining visual tokens, components, visual states, responsiveness, and microcopy.

## Reference
- docs/ai/DESIGN_SYSTEM.md

## What to include

- **Design tokens**: colors, typography, spacing, and border radii used in the feature. Reference existing tokens — do not propose hardcoded values.
- **New components**: name, visual responsibility, main props. Before creating, check if an existing component in the design system already works.
- **Reused components**: list which existing components are used and whether they need extension/modification.
- **Visual states**: loading, empty, error, success, disabled, focus, hover — define what each state shows and how it transitions. No state can be left undecided.
- **Responsiveness**: behavior at main breakpoints (mobile, tablet, desktop). Layout must work at multiple widths — not depend on pixel-perfect at one.
- **Visual hierarchy**: order of importance, alignment, consistent spacing, legibility.
- **Microcopy**: label texts, CTAs, error messages, empty states, and confirmations. Texts should help the user — not be generic.

## Rules

- Do not propose hardcoded color or spacing values when a token exists in the design system.
- Do not create a parallel component when an equivalent exists in the design system — extend the existing one.
- Every relevant visual state (loading, error, empty, disabled) must have an explicit decision.
- Layout must work at at least 3 widths: mobile (~375px), tablet (~768px), desktop (~1280px).
- If not applicable to the task: write "Does not apply" and explain why.

## Output format

```md
## UI / Components / Design

### Tokens used
| Token | Value | Usage |
|-------|-------|-------|
| color-{name} | {value or reference} | {where it's used} |

### New components
| Component | Responsibility | Main props |
|-----------|---------------|------------|
| {Name} | {What it renders} | {key props} |

### Reused components
| Existing component | Usage in feature | Modification needed |
|-------------------|-----------------|--------------------|
| {Name} | {where} | {yes/no + what} |

### Visual states
| State | Component | Appearance |
|-------|-----------|------------|
| loading | {which} | {description} |
| empty | {which} | {description} |
| error | {which} | {description} |
| disabled | {which} | {description} |
| focus | {which} | {description} |

### Responsiveness
| Breakpoint | Behavior |
|-----------|----------|
| mobile (~375px) | {layout/adjustments} |
| tablet (~768px) | {layout/adjustments} |
| desktop (~1280px) | {layout/adjustments} |

### Microcopy
| Context | Text |
|---------|------|
| {Label/CTA/error/empty} | "{text}" |
```
