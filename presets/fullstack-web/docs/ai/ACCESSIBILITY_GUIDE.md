# React Web Accessibility

## Principles

Accessibility is not optional or a final phase. Every delivered component must be keyboard-navigable and screen-reader-comprehensible.

## Required minimum

- Semantic HTML before ARIA.
- Buttons are `<button>`; links are `<a>`.
- Every mouse action must be possible via keyboard.
- Visible focus and logical focus order.
- Inputs with associated `<label>` (not just placeholder).
- Form errors must be announcable and close to the field.
- Minimum contrast 4.5:1 for normal text, 3:1 for large text.

## Semantics and components

Prefer native elements. Use ARIA only to complement.

```tsx
// ✅ Correct: native button with automatic semantics
<button onClick={handleSave}>Save</button>

// ❌ Wrong: div with no semantics at all
<div onClick={handleSave}>Save</div>
```

For composite components (dropdowns, modals, tabs), use accessible primitives:

- `@radix-ui/react-*` — free access, complete semantics
- `@headlessui/react` — good integration with Tailwind
- `react-aria` — hooks focused on accessibility

Do not reinvent WAI-ARIA patterns if a consolidated library solves it.

## Forms

### Labels and help

```tsx
<label htmlFor="email">Email</label>
<input id="email" type="email" aria-describedby="email-help" />
<span id="email-help">Use your corporate email</span>
```

### Field errors

```tsx
<input
  id="email"
  type="email"
  aria-invalid={!!error}
  aria-describedby={error ? 'email-error' : undefined}
/>
{error && <span id="email-error" role="alert">{error}</span>}
```

### Validation with React Hook Form + Zod

```tsx
const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Minimum 8 characters'),
});

const { register, formState: { errors } } = useForm({
  resolver: zodResolver(schema),
});

<input
  {...register('email')}
  aria-invalid={!!errors.email}
  aria-describedby={errors.email ? 'email-error' : undefined}
/>
{errors.email && (
  <span id="email-error" role="alert">{errors.email.message}</span>
)}
```

## ARIA

Use ARIA to complement semantics, not to fix incorrect HTML.

- `aria-label` when no visible text exists.
- `aria-describedby` for help/error.
- `aria-live="polite"` for async feedback (toast, loading status).
- `aria-live="assertive"` only for critical alerts.
- `aria-expanded`, `aria-controls` for dropdowns and collapsibles.

### Live region with TanStack Query

```tsx
<div aria-live="polite" aria-atomic="true">
  {isLoading && 'Loading data...'}
  {isError && 'Error loading. Please try again.'}
</div>
```

## Modals and overlays

Required:

- Focus trap inside modal while open.
- Escape closes when safe (no unsaved data).
- Focus moves to modal on open.
- Focus returns to trigger element on close.
- Click outside should not destroy data without confirmation.

Use `@radix-ui/react-dialog` or equivalent that handles this automatically:

```tsx
<Dialog.Root open={open} onOpenChange={setOpen}>
  <Dialog.Trigger asChild>
    <button>Open</button>
  </Dialog.Trigger>
  <Dialog.Portal>
    <Dialog.Overlay className="fixed inset-0 bg-black/50" />
    <Dialog.Content className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
      <Dialog.Title>Confirm action</Dialog.Title>
      <Dialog.Description>Are you sure you want to continue?</Dialog.Description>
      {/* content */}
    </Dialog.Content>
  </Dialog.Portal>
</Dialog.Root>
```

## Images and icons

- Informative images need descriptive `alt`.
- Decorative images use `alt=""` and `aria-hidden="true"`.
- Clickable icons need `aria-label` or visible label.

```tsx
// Icon as button
<button aria-label="Close notification" onClick={onClose}>
  <XIcon aria-hidden="true" />
</button>
```

## Navigation and routes

- Use `<nav>` with `aria-label` for main navigation.
- Indicate active page with `aria-current="page"`.
- React Router: use `<Link>` from the router, not `<a>` with onClick.

```tsx
<nav aria-label="Main navigation">
  <ul>
    {links.map((link) => (
      <li key={link.path}>
        <Link
          to={link.path}
          aria-current={location.pathname === link.path ? 'page' : undefined}
        >
          {link.label}
        </Link>
      </li>
    ))}
  </ul>
</nav>
```

## Verification tools

```bash
# Accessibility lint with eslint-plugin-jsx-a11y
npx eslint --rule 'jsx-a11y/*: error' src/
```

## Anti-patterns

- **Div as button:** do not use `<div onClick>` for actions. Use `<button>`.
- **Placeholder as label:** placeholder disappears on input and does not replace label.
- **Overlay without focus trap:** tab exits modal to invisible content.
- **Color as sole indication:** never use only color to indicate error/state. Combine with icon or text.
- **aria-hidden on focusable element:** if it has `aria-hidden`, it cannot receive focus.
- **Image without alt:** empty alt for decorative, descriptive alt for informative. Never omit the attribute.
- **Infinite list without announcement:** pagination/infinite scroll must announce new items via `aria-live`.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

### Semantics and navigation
- **Accessibility is not optional or a final phase**: every delivered component must be keyboard-navigable and screen-reader-comprehensible.
- **Div as button is prohibited**: actions use `<button>`, links use `<a>`.
- **Every mouse action must be possible via keyboard**: no exceptions.

### Forms
- **Inputs with associated `<label>`**: never use only placeholder as label.
- **Form errors must be announcable and close to the field**: use `aria-invalid` and `aria-describedby`.

### Visual
- **Minimum contrast 4.5:1 for normal text, 3:1 for large text**: never use only color to indicate error/state.
- **Informative image needs descriptive `alt`**: decorative uses `alt=""` + `aria-hidden="true"`. Never omit the attribute.

### Modals and overlays
- **Overlay without focus trap is prohibited**: tab cannot exit modal to invisible content.

### ARIA
- **Do not reinvent WAI-ARIA patterns if a consolidated library solves it**: use Radix, Headless UI, or react-aria.
- **`aria-hidden` on focusable element is prohibited**: if it has `aria-hidden`, it cannot receive focus.
- **Infinite list without announcement**: pagination/infinite scroll must announce new items via `aria-live`.
