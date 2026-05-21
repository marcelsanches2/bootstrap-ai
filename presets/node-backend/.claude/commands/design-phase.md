# /design-phase

Defines the project's visual design system. Three modes: extract from Figma, generate from scratch, or skip.

## When to use

- After `/kickoff` has completed (PRODUCT_BRIEF.md exists)
- User says "I want to define the design", "create design system"
- The applied preset has a generic `docs/ai/DESIGN_SYSTEM.md` that needs to be populated

## Prerequisites

- `PRODUCT_BRIEF.md` in the project root (with target users, features, platform)
- Project already has a decided stack (from kickoff or detected)

---

## Step 1 — Choose mode

Ask:

```
How do you want to define the design system?

1. "I have Figma" — I'll extract tokens and components from the link
2. "Create for me" — I'll generate a design system based on the product brief
3. "Skip" — no design system for now (can run later)

Answer 1, 2, or 3.
```

---

## Mode 1 — Figma (link provided)

### Receive the link

```
Paste the Figma link (design system).
```

### Extract information from the link

If the link is accessible (Figma URL), read the page and extract:

1. **Color palette** — primary, secondary, neutrals, feedback (success, warning, error, info)
2. **Typography** — fonts, sizes, weights for headings, body, labels, captions
3. **Spacing** — scale (4, 8, 12, 16, 24, 32, 48, 64...)
4. **Border radius** — tokens (none, sm, md, lg, full)
5. **Shadows** — levels (sm, md, lg)
6. **Components** — names, variants, visual props (button, input, card, modal, toast, avatar, badge, etc.)
7. **Breakpoints** — if responsive (mobile, tablet, desktop)
8. **Icons** — set/library used

If the link is not directly accessible, ask the user to paste the relevant content (tokens, CSS, or design system JSON export).

### Generate files

**`docs/ai/DESIGN_SYSTEM.md`**:
```markdown
# Design System — {{PROJECT_NAME}}

> Source: [Figma — link]

## Tokens

### Colors
| Token | Value | Usage |
|---|---|---|
| --color-primary | [hex] | Primary actions, CTAs |
| --color-primary-hover | [hex] | Hover for primary actions |
| --color-secondary | [hex] | Secondary actions |
| --color-background | [hex] | Main background |
| --color-surface | [hex] | Cards, modals |
| --color-text | [hex] | Main text |
| --color-text-muted | [hex] | Secondary text |
| --color-border | [hex] | Borders |
| --color-success | [hex] | Positive feedback |
| --color-warning | [hex] | Warning feedback |
| --color-error | [hex] | Error feedback |
| --color-info | [hex] | Informational feedback |

### Typography
| Token | Font | Weight | Size | Line height |
|---|---|---|---|---|
| --font-heading | [font] | [weight] | [sizes] | [height] |
| --font-body | [font] | [weight] | [sizes] | [height] |
| --font-mono | [font] | [weight] | [sizes] | [height] |

### Spacing
| Token | Value |
|---|---|
| --space-1 | 4px |
| --space-2 | 8px |
| ... | ... |

### Border Radius
| Token | Value |
|---|---|
| --radius-sm | [value] |
| --radius-md | [value] |
| --radius-lg | [value] |
| --radius-full | 9999px |

### Shadows
| Token | Value |
|---|---|
| --shadow-sm | [value] |
| --shadow-md | [value] |
| --shadow-lg | [value] |

## Components

### Button
- Variants: primary, secondary, ghost, danger
- Sizes: sm, md, lg
- States: default, hover, active, disabled, loading

### Input
- Variants: text, email, password, search, textarea
- States: default, focus, error, disabled

### Card
- Variants: default, elevated, outlined
- Padding: [value]

### Modal
- Sizes: sm, md, lg
- Overlay: [color/opacity]

### Toast / Notification
- Variants: success, warning, error, info
- Position: [position]

### [Other design components]

## Breakpoints (if web)
| Token | Value | Columns |
|---|---|---|
| --bp-mobile | [value] | [n] |
| --bp-tablet | [value] | [n] |
| --bp-desktop | [value] | [n] |

## Usage rules

1. Always use tokens, never hardcoded values
2. Minimum WCAG AA contrast (4.5:1 text, 3:1 UI)
3. Hover/focus always visible
4. Dark mode: if applicable, define inverted tokens
```

**`design/tokens.json`** (code-consumable format):
```json
{
  "colors": {
    "primary": "#...",
    "primaryHover": "#...",
    "secondary": "#...",
    "background": "#...",
    "surface": "#...",
    "text": "#...",
    "textMuted": "#...",
    "border": "#...",
    "success": "#...",
    "warning": "#...",
    "error": "#...",
    "info": "#..."
  },
  "typography": {
    "heading": { "fontFamily": "...", "weights": {}, "sizes": {} },
    "body": { "fontFamily": "...", "weights": {}, "sizes": {} },
    "mono": { "fontFamily": "...", "weights": {}, "sizes": {} }
  },
  "spacing": { "1": "4px", "2": "8px", "3": "12px", "4": "16px", "5": "24px", "6": "32px", "8": "48px", "10": "64px" },
  "radius": { "sm": "...", "md": "...", "lg": "...", "full": "9999px" },
  "shadows": { "sm": "...", "md": "...", "lg": "..." },
  "breakpoints": { "mobile": "...", "tablet": "...", "desktop": "..." }
}
```

---

## Mode 2 — Generate from scratch

Based on the PRODUCT_BRIEF (target users, platform, features), generate a design system:

### Automatic decisions

1. **Visual tone** — based on users:
   - Professional/B2B → clean, neutral, blue/gray
   - Consumer/social → vibrant, rounded, warm colors
   - Dev/tool → dark, mono, green/blue
   - Health/fitness → energetic, green/orange
   - Finance → sober, dark blue/green

2. **Palette** — generate with harmony:
   - Choose 1 primary color based on the tone
   - Generate complementary/analogous for secondary
   - Neutrals: gray scale with slight tint from primary
   - Feedback: green (success), yellow (warning), red (error), blue (info)

3. **Typography** — based on platform:
   - Web: Inter or Plus Jakarta Sans (body), Sora or Space Grotesk (heading)
   - Mobile: native system or Inter/Plus Jakarta Sans
   - Always define fallbacks: `-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`

4. **Spacing** — 4px base (standard 4, 8, 12, 16, 24, 32, 48, 64)

5. **Border radius** — based on tone:
   - Clean: 6, 8, 12
   - Friendly: 8, 12, 16
   - Playful: 12, 16, 24

6. **Base components** — always: Button, Input, Card, Modal, Toast, Avatar, Badge, Divider

### Same output format

Generate `docs/ai/DESIGN_SYSTEM.md` and `design/tokens.json` in the same format as Mode 1.

Add to the top of DESIGN_SYSTEM.md:

```markdown
> Automatically generated by bootstrap-ai. Customize freely.
```

---

## Mode 3 — Skip

Does not generate a design system. The generic preset applies the default `docs/ai/DESIGN_SYSTEM.md`.

Notify:
```
Design system skipped. When you want to define it, run /design-phase at any time.
```

---

## After any mode

### Update project CLAUDE.md

If `docs/ai/DESIGN_SYSTEM.md` was created, add to the project's CLAUDE.md:

```markdown
## Design System

Visual source of truth: `docs/ai/DESIGN_SYSTEM.md`
Tokens: `design/tokens.json`

Rules:
- Use tokens, never hardcoded values in CSS/styles
- Minimum WCAG AA contrast
- Components must follow documented variants
- Any visual change MUST be reflected in DESIGN_SYSTEM.md
```

### Verify integrity

- `docs/ai/DESIGN_SYSTEM.md` exists and has real content
- `design/tokens.json` exists and is valid JSON
- CLAUDE.md references the design system

---

## Pitfalls

- Do not invent color/typography values if you have Figma — use what was provided
- If the Figma link is inaccessible, ask the user to export the tokens
- Tokens must be compatible with the stack (CSS vars for web, Flutter ThemeExtension for mobile, etc.)
- Do not overwrite existing `DESIGN_SYSTEM.md` without confirming with the user
- Dark mode is optional — only generate if the product brief mentions it
