# Role: Designer / UX

## Your contribution

Generates the "UI / Components / Design" section of the plan, defining tokens, visual components, visual states, responsiveness and accessibility.

## Reference

- docs/ai/DESIGN_SYSTEM.md
- docs/ai/FEATURE_GUIDE.md

## What to include

- **Design system tokens used** — list colors, typography, spacing, borders, elevation and any theme tokens that the task uses. Reference the existing design system, do not invent values.
- **Visual components needed** — list each widget/component that will be created or reused, with a clear visual description (hierarchy, alignment, spacing, content).
- **Visual states of each component** — for each interactive component, define loading, empty, error, success and disabled states. Include visual transitions when relevant.
- **Responsiveness** — describe behavior at main widths (phone, tablet), orientations (portrait, landscape) and screen sizes. Use LayoutBuilder, MediaQuery or project convention.
- **Visual accessibility** — declare Semantics labels, minimum contrast (WCAG AA), minimum touch target size (48dp), reading order and accessibility hints for each interactive component.

## Rules

- Use only existing design system tokens and components. If a new token is needed, justify and propose the value.
- No hardcoded color, spacing or typography values — always reference the theme.
- Every interactive component must have at least loading, error and default states defined.
- Minimum touch targets of 48dp on all clickable elements.
- Minimum contrast of 4.5:1 for normal text, 3:1 for large text (WCAG AA).
- If the task has no new UI: write "Does not apply" and explain why.

## Output format

```md
## UI / Components / Design

### Tokens used

| Token | Value | Usage |
|---|---|---|
| {colorToken} | {value} | {where used} |
| {typographyToken} | {value} | {where used} |
| {spacingToken} | {value} | {where used} |

### Components

#### {ComponentName}

- **Description**: {visual composition, hierarchy, alignment}
- **Reuses**: {existing DS component or "new"}
- **Tokens**: {which tokens it uses}

**Visual states:**

| State | Visual | Interaction |
|---|---|---|
| Default | {description} | {behavior} |
| Loading | {description} | {behavior} |
| Empty | {description} | {behavior} |
| Error | {description} | {behavior} |
| Disabled | {description} | {behavior} |

#### {ComponentName2}

- **Description**: ...
- ...

### Responsiveness

| Breakpoint | Behavior |
|---|---|
| Phone (< 600dp) | {layout and adaptations} |
| Tablet (600dp–840dp) | {layout and adaptations} |
| Landscape | {adaptations if different from portrait} |

### Visual accessibility

| Component | Semantics label | Touch target | Contrast |
|---|---|---|---|
| {component} | {descriptive label} | {≥ 48dp} | {≥ 4.5:1} |
| {component} | ... | ... | ... |
```
