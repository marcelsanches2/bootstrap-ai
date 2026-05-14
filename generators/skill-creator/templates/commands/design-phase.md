# /design-phase

Define o design system visual do projeto. Três modos: extrair do Figma Make, gerar do zero, ou pular.

## Quando usar

- Após `/kickoff` ter completado (PRODUCT_BRIEF.md existe)
- Usuário diz "quero definir o design", "criar design system"
- O preset aplicado tem `docs/ai/DESIGN_SYSTEM.md` genérico que precisa ser populado

## Pré-requisitos

- `PRODUCT_BRIEF.md` na raiz do projeto (com target users, features, plataforma)
- Projeto já tem stack decidida (do kickoff ou detectada)

---

## Passo 1 — Escolher modo

Pergunte:

```
Como você quer definir o design system?

1. "Tenho Figma Make" — vou extrair tokens e componentes do link
2. "Crie pra mim" — vou gerar um design system baseado no product brief
3. "Pula" — sem design system por agora (pode rodar depois)

Responda 1, 2 ou 3.
```

---

## Modo 1 — Figma Make (link fornecido)

### Receber o link

```
Cole o link do Figma Make (design system).
```

### Extrair informações do link

Se o link é acessível (URL do Figma), leia a página e extraia:

1. **Paleta de cores** — primária, secundária, neutros, feedback (success, warning, error, info)
2. **Tipografia** — fontes, tamanhos, pesos para headings, body, labels, captions
3. **Espaçamento** — scale (4, 8, 12, 16, 24, 32, 48, 64...)
4. **Border radius** — tokens (none, sm, md, lg, full)
5. **Shadows** — níveis (sm, md, lg)
6. **Componentes** — nomes, variantes, props visuais (button, input, card, modal, toast, avatar, badge, etc.)
7. **Breakpoints** — se for responsivo (mobile, tablet, desktop)
8. **Ícones** — set/library usado

Se o link não for diretamente acessível, peça ao usuário para colar o conteúdo relevante (tokens, CSS, ou exportação JSON do design system).

### Gerar arquivos

**`docs/ai/DESIGN_SYSTEM.md`**:
```markdown
# Design System — {{PROJECT_NAME}}

> Fonte: [Figma Make — link]

## Tokens

### Cores
| Token | Valor | Uso |
|---|---|---|
| --color-primary | [hex] | Ações primárias, CTAs |
| --color-primary-hover | [hex] | Hover de ações primárias |
| --color-secondary | [hex] | Ações secundárias |
| --color-background | [hex] | Fundo principal |
| --color-surface | [hex] | Cards, modais |
| --color-text | [hex] | Texto principal |
| --color-text-muted | [hex] | Texto secundário |
| --color-border | [hex] | Bordas |
| --color-success | [hex] | Feedback positivo |
| --color-warning | [hex] | Feedback de alerta |
| --color-error | [hex] | Feedback de erro |
| --color-info | [hex] | Feedback informativo |

### Tipografia
| Token | Font | Peso | Tamanho | Linha |
|---|---|---|---|---|
| --font-heading | [font] | [weight] | [sizes] | [height] |
| --font-body | [font] | [weight] | [sizes] | [height] |
| --font-mono | [font] | [weight] | [sizes] | [height] |

### Espaçamento
| Token | Valor |
|---|---|
| --space-1 | 4px |
| --space-2 | 8px |
| ... | ... |

### Border Radius
| Token | Valor |
|---|---|
| --radius-sm | [valor] |
| --radius-md | [valor] |
| --radius-lg | [valor] |
| --radius-full | 9999px |

### Sombras
| Token | Valor |
|---|---|
| --shadow-sm | [valor] |
| --shadow-md | [valor] |
| --shadow-lg | [valor] |

## Componentes

### Button
- Variantes: primary, secondary, ghost, danger
- Tamanhos: sm, md, lg
- Estados: default, hover, active, disabled, loading

### Input
- Variantes: text, email, password, search, textarea
- Estados: default, focus, error, disabled

### Card
- Variantes: default, elevated, outlined
- Padding: [valor]

### Modal
- Tamanhos: sm, md, lg
- Overlay: [cor/opacity]

### Toast / Notification
- Variantes: success, warning, error, info
- Posição: [posição]

### [Outros componentes do design]

## Breakpoints (se web)
| Token | Valor | Colunas |
|---|---|---|
| --bp-mobile | [valor] | [n] |
| --bp-tablet | [valor] | [n] |
| --bp-desktop | [valor] | [n] |

## Regras de uso

1. Sempre use tokens, nunca valores hardcoded
2. Contraste mínimo WCAG AA (4.5:1 texto, 3:1 UI)
3. Hover/focus sempre visíveis
4. Dark mode: se aplicável, definir tokens invertidos
```

**`design/tokens.json`** (formato consumível por código):
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

## Modo 2 — Gerar do zero

Baseado no PRODUCT_BRIEF (target users, plataforma, features), gere um design system:

### Decisões automáticas

1. **Tom visual** — baseado nos usuários:
   - Profissional/B2B → clean, neutro, azul/cinza
   - Consumer/social → vibrante, arredondado, cores quentes
   - Dev/ferramenta → escuro, mono, verde/azul
   - Saúde/fitness → energético, verde/laranja
   - Finanças → sóbrio, azul/verde escuro

2. **Paleta** — gerar com harmonia:
   - Escolha 1 cor primária baseada no tom
   - Gere complementar/análoga para secundária
   - Neutros: escala de cinza com leve tint da primária
   - Feedback: verde (success), amarelo (warning), vermelho (error), azul (info)

3. **Tipografia** — baseado na plataforma:
   - Web: Inter ou Plus Jakarta Sans (body), Sora ou Space Grotesk (heading)
   - Mobile: sistema nativa ou Inter/Plus Jakarta Sans
   - Sempre definir fallbacks: `-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`

4. **Espaçamento** — base 4px (padrão 4, 8, 12, 16, 24, 32, 48, 64)

5. **Border radius** — baseado no tom:
   - Clean: 6, 8, 12
   - Friendly: 8, 12, 16
   - Playful: 12, 16, 24

6. **Componentes base** — sempre: Button, Input, Card, Modal, Toast, Avatar, Badge, Divider

### Mesmo formato de saída

Gere `docs/ai/DESIGN_SYSTEM.md` e `design/tokens.json` no mesmo formato do Modo 1.

Adicione ao topo do DESIGN_SYSTEM.md:

```markdown
> Gerado automaticamente pelo bootstrap-ai. Personalize livremente.
```

---

## Modo 3 — Pula

Não gera design system. O preset genérico aplica `docs/ai/DESIGN_SYSTEM.md` padrão.

Avise:
```
Design system pulado. Quando quiser definir, rode /design-phase a qualquer momento.
```

---

## Após qualquer modo

### Atualizar CLAUDE.md do projeto

Se `docs/ai/DESIGN_SYSTEM.md` foi criado, adicione ao CLAUDE.md do projeto:

```markdown
## Design System

Fonte de verdade visual: `docs/ai/DESIGN_SYSTEM.md`
Tokens: `design/tokens.json`

Regras:
- Use tokens, nunca valores hardcoded em CSS/estilos
- Contraste mínimo WCAG AA
- Componentes devem seguir as variantes documentadas
- Qualquer mudança visual DEVE ser refletida no DESIGN_SYSTEM.md
```

### Verificar integridade

- `docs/ai/DESIGN_SYSTEM.md` existe e tem conteúdo real
- `design/tokens.json` existe e é JSON válido
- CLAUDE.md referencia o design system

---

## Pitfalls

- Não invente valores de cores/tipografia se tem Figma Make — use o que veio
- Se o Figma Make link é inacessível, peça ao usuário para exportar os tokens
- Tokens devem ser compatíveis com a stack (CSS vars pra web, Flutter ThemeExtension pra mobile, etc.)
- Não sobrescreva `DESIGN_SYSTEM.md` existente sem confirmar com o usuário
- Dark mode é opcional — só gere se o product brief mencionar
