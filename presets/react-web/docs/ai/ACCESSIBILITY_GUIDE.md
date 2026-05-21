# React Web Accessibility

## Principles

Accessibility is not optional nor a final phase. Every delivered component must be keyboard-navigable and understandable by screen readers.

## Minimum required

- Semantic HTML before ARIA.
- Buttons are `<button>`; links are `<a>`.
- Every mouse action must be possible by keyboard.
- Visible focus and logical focus order.
- Inputs with associated `<label>` (not just placeholder).
- Form errors must be announcable and close to the field.
- Minimum contrast 4.5:1 for normal text, 3:1 for large text.

## Semantics and components

Prefer native elements. Use ARIA only to complement.

```tsx
// ✅ Correct: native button with automatic semantics
<button onClick={handleSave}>Save</button>

// ❌ Wrong: div with no semantics
<div onClick={handleSave}>Save</div>
```

For composite components (dropdowns, modals, tabs), use accessible primitives:

- `@radix-ui/react-*` — open access, complete semantics
- `@headlessui/react` — good Tailwind integration
- `react-aria` — accessibility-focused hooks

Do not reinvent WAI-ARIA patterns when a consolidated library solves it.

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

Use ARIA to complement semantics, not to fix wrong HTML.

- `aria-label` when visible text does not exist.
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

Mandatory requirements:

- Focus trap inside the modal while open.
- Escape closes when safe (no unsaved data).
- Focus moves to the modal on open.
- Focus returns to the trigger element on close.
- Click outside must not destroy data without confirmation.

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
- React Router: use the router's `<Link>`, not `<a>` with onClick.

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
- **Placeholder as label:** placeholder disappears on typing and does not replace a label.
- **Overlay without focus trap:** tab leaves the modal to invisible content.
- **Color as only indication:** never use only color to indicate error/state. Combine with icon or text.
- **aria-hidden on focusable element:** if it has `aria-hidden`, it cannot receive focus.
- **Image without alt:** empty alt for decorative, descriptive alt for informative. Never omit the attribute.
- **Infinite list without announcement:** pagination/infinite scroll needs to announce new items via `aria-live`.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any below.

### Minimum required
- **Accessibility is not optional**: every delivered component must be keyboard-navigable and understandable by screen readers.
- **Semantic HTML before ARIA**: use native elements (`<button>`, `<a>`, `<nav>`) instead of generic divs.
- **Every mouse action must be possible by keyboard**: no exceptions.
- **Visible focus and logical order**: focus cannot disappear or be in confusing order.
- **Inputs with associated `<label>`**: placeholder does not replace a label.
- **Minimum contrast 4.5:1 (normal text), 3:1 (large text)**: insufficient contrast is blocking.

### Modals and overlays
- **Focus trap in modal**: tab cannot escape to invisible content.
- **Escape closes the modal**: when safe (no unsaved data).
- **Focus moves on open and returns on close**: mandatory.
- **Click outside does not destroy data without confirmation**: mandatory.

### Images and icons
- **Informative image needs descriptive `alt`**: never omit the alt attribute.
- **Clickable icon needs `aria-label` or visible label**: no exceptions.

### Prohibitions
- **Never use `<div onClick>` for actions**: use `<button>`.
- **Never use color as only state indication**: combine with icon or text.
- **Never use `aria-hidden` on focusable element**: if it has aria-hidden, it cannot receive focus.
- **Do not reinvent WAI-ARIA patterns**: use a consolidated library (Radix, Headless UI, react-aria).
