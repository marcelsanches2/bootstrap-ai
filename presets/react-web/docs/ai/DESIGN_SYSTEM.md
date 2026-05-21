# React Web Design System

## Tokens

Use tokens for consistent visual identity. Do not hardcode values.

```ts
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#eff6ff',
          500: '#3b82f6',
          700: '#1d4ed8',
          900: '#1e3a8a',
        },
        surface: {
          DEFAULT: '#ffffff',
          muted: '#f9fafb',
        },
        text: {
          DEFAULT: '#111827',
          muted: '#6b7280',
        },
        danger: '#ef4444',
        success: '#22c55e',
        warning: '#f59e0b',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      spacing: {
        xs: '0.25rem',
        sm: '0.5rem',
        md: '1rem',
        lg: '1.5rem',
        xl: '2rem',
      },
    },
  },
};

export default config;
```

## Components

Build from tokens. Do not bypass the design system.

If it is not enough, propose extension. Do not work around it.

## Anti-patterns

- **Hardcoded color, font, or spacing value**: use a token.
- **Local CSS for something the design system already provides**: extend the system if necessary.
- **Duplicate component per screen**: reuse and compose.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any below.

- **Do not hardcode colors, fonts, or spacing**: always use tokens.
- **Do not work around the design system**: if insufficient, extend it.
- **Do not duplicate visual component per screen**: reuse and compose.
