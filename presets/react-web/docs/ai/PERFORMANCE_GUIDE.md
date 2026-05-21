# React Web Performance

## Metrics

- LCP < 2.5s
- FID / INP < 200ms
- CLS < 0.1
- TTFB < 800ms

Values measured on real device or throttled connection, not localhost.

## Bundle

- Monitor bundle size on every relevant delivery.
- Lazy load routes and heavy components.
- Dynamic import for large dependencies (charts, editors).
- Manual chunks to separate vendor code from app code.
- Use tree-shakeable imports.

```tsx
// Lazy route
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

```ts
// Vite — manual chunks
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        vendor: ['react', 'react-dom'],
        query: ['@tanstack/react-query'],
        charts: ['recharts'],
      },
    },
  },
}
```

## Rendering

- Avoid unnecessary re-renders.
- `React.memo` with custom comparison when measured and justified.
- `useMemo` for expensive calculations on large lists.
- `useCallback` only when passed as prop to memoized child.
- Virtualized list for 100+ items.

```tsx
// Virtualized list
import { useVirtualizer } from '@tanstack/react-virtual';

function LargeList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 48,
  });

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map((virtualItem) => (
          <div
            key={virtualItem.key}
            style={{
              position: 'absolute',
              top: virtualItem.start,
              height: virtualItem.size,
            }}
          >
            {items[virtualItem.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

## Images

- Use `loading="lazy"` on images below the fold.
- Use `srcset` / `sizes` for responsive images.
- Use modern formats (WebP, AVIF) with fallback.
- Do not upload uncompressed images.

## Anti-patterns

- **Upload uncompressed images**: compress and use modern formats.
- **Render 500+ items without virtualization**: use virtualized list.
- **useMemo/useCallback on everything**: only with measurement and justification.
- **Full import of large library**: use tree-shakeable or dynamic import.
- **No bundle monitoring**: check size on every relevant delivery.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any below.

- **Lazy load routes and heavy components**: use `React.lazy` + `Suspense` for non-critical routes.
- **Dynamic import for large dependencies**: charts, editors, and heavy libs must be dynamically imported.
- **Manual chunks to separate vendor from app**: configure in Vite/Next.js.
- **Virtualized list for 100+ items**: do not render 100+ items in the DOM without virtualization.
- **Monitor bundle size**: check on every relevant delivery.
- **Use `loading="lazy"` on images below the fold**: mandatory.
- **Use modern formats (WebP/AVIF) with fallback**: do not upload uncompressed images.
