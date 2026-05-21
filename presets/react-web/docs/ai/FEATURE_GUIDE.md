# React Web Feature Guide

## Feature creation flow

Follow these steps in order. Do not skip stages.

## 1 — Define scope

Before writing code:

- Describe what the feature does in 1-2 paragraphs.
- List expected screens/pages.
- List API endpoints consumed.
- List states to handle (loading, error, empty, success).
- Check if there is similar code already implemented.

## 2 — Plan structure

Create the necessary folders following the project architecture:

```txt
src/
  features/
    [feature-name]/
      components/
      hooks/
      api/
      types.ts
      constants.ts
      utils.ts
```

## 3 — Types and contracts

Define types BEFORE implementing.

```ts
// types.ts
export interface Feature {
  id: string;
  name: string;
  status: 'active' | 'inactive';
  createdAt: string;
}

export interface FeatureFilters {
  search: string;
  status?: Feature['status'];
  page: number;
  limit: number;
}

export interface FeatureListResponse {
  data: Feature[];
  total: number;
  page: number;
  totalPages: number;
}
```

## 4 — API layer

Isolate HTTP calls. Validate external data with Zod.

```ts
// api/feature-api.ts
import { z } from 'zod';
import { apiClient } from '@/shared/api/client';
import type { Feature, FeatureFilters, FeatureListResponse } from '../types';

const FeatureSchema = z.object({
  id: z.string(),
  name: z.string(),
  status: z.enum(['active', 'inactive']),
  createdAt: z.string(),
});

const FeatureListSchema = z.object({
  data: z.array(FeatureSchema),
  total: z.number(),
  page: z.number(),
  totalPages: z.number(),
});

export const featureApi = {
  getAll: async (filters: FeatureFilters): Promise<FeatureListResponse> => {
    const { data } = await apiClient.get('/features', { params: filters });
    return FeatureListSchema.parse(data);
  },

  getById: async (id: string): Promise<Feature> => {
    const { data } = await apiClient.get(`/features/${id}`);
    return FeatureSchema.parse(data);
  },

  create: async (input: CreateFeatureInput): Promise<Feature> => {
    const { data } = await apiClient.post('/features', input);
    return FeatureSchema.parse(data);
  },

  update: async (id: string, input: UpdateFeatureInput): Promise<Feature> => {
    const { data } = await apiClient.patch(`/features/${id}`, input);
    return FeatureSchema.parse(data);
  },

  delete: async (id: string): Promise<void> => {
    await apiClient.delete(`/features/${id}`);
  },
};
```

## 5 — Hooks (TanStack Query)

Encapsulate data fetching and cache.

```ts
// hooks/use-features.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { featureApi } from '../api/feature-api';
import type { FeatureFilters, CreateFeatureInput } from '../types';

export const featureKeys = {
  all: ['features'] as const,
  list: (filters: FeatureFilters) => [...featureKeys.all, filters] as const,
  detail: (id: string) => [...featureKeys.all, id] as const,
};

export function useFeatures(filters: FeatureFilters) {
  return useQuery({
    queryKey: featureKeys.list(filters),
    queryFn: () => featureApi.getAll(filters),
    staleTime: 30_000,
  });
}

export function useFeature(id: string) {
  return useQuery({
    queryKey: featureKeys.detail(id),
    queryFn: () => featureApi.getById(id),
    enabled: !!id,
  });
}

export function useCreateFeature() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: featureApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: featureKeys.all });
    },
  });
}

export function useDeleteFeature() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: featureApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: featureKeys.all });
    },
  });
}
```

## 6 — Components

Build visual components following the design system.

### List component

```tsx
// components/FeatureList.tsx
import { useFeatures } from '../hooks/use-features';
import { FeatureCard } from './FeatureCard';
import { FeatureListSkeleton } from './FeatureListSkeleton';
import { EmptyState } from '@/shared/components/EmptyState';
import { ErrorMessage } from '@/shared/components/ErrorMessage';

interface FeatureListProps {
  filters: FeatureFilters;
}

export function FeatureList({ filters }: FeatureListProps) {
  const { data, isLoading, isError, error, refetch } = useFeatures(filters);

  if (isLoading) return <FeatureListSkeleton />;
  if (isError) return <ErrorMessage error={error} onRetry={refetch} />;
  if (!data.data.length) return <EmptyState message="No features found" />;

  return (
    <div role="list" aria-label="Features list">
      {data.data.map((feature) => (
        <FeatureCard key={feature.id} feature={feature} />
      ))}
    </div>
  );
}
```

### Form component

```tsx
// components/FeatureForm.tsx
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useCreateFeature } from '../hooks/use-features';

const schema = z.object({
  name: z.string().min(2, 'Name is required'),
  status: z.enum(['active', 'inactive']),
});

type FormData = z.infer<typeof schema>;

export function FeatureForm() {
  const { mutate: createFeature, isPending } = useCreateFeature();

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  const onSubmit = (data: FormData) => {
    createFeature(data, { onSuccess: () => reset() });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="name">Name</label>
        <input
          id="name"
          {...register('name')}
          aria-invalid={!!errors.name}
          aria-describedby={errors.name ? 'name-error' : undefined}
        />
        {errors.name && (
          <span id="name-error" role="alert">{errors.name.message}</span>
        )}
      </div>

      <div>
        <label htmlFor="status">Status</label>
        <select id="status" {...register('status')}>
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
        </select>
      </div>

      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create'}
      </button>
    </form>
  );
}
```

## 7 — Page (container)

Join components, hooks, and layout.

```tsx
// pages/FeaturePage.tsx
import { useState } from 'react';
import { FeatureList } from '../components/FeatureList';
import { FeatureForm } from '../components/FeatureForm';
import type { FeatureFilters } from '../types';

export function FeaturePage() {
  const [filters, setFilters] = useState<FeatureFilters>({
    search: '',
    page: 1,
    limit: 20,
  });

  return (
    <main>
      <h1>Features</h1>
      <FeatureForm />
      <FeatureList filters={filters} />
    </main>
  );
}
```

## 8 — Tests

Test the main scenarios:

- Render with data
- Render empty
- Render loading
- Render error and retry
- Create with success
- Create with validation error

```tsx
// tests/FeatureList.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { FeatureList } from '../components/FeatureList';

describe('FeatureList', () => {
  it('shows empty state when no features', async () => {
    // Mock API returning empty list
    render(<FeatureList filters={{ search: '', page: 1, limit: 20 }} />);

    expect(await screen.findByText('No features found')).toBeInTheDocument();
  });

  it('shows error and retry button on failure', async () => {
    // Mock API failure
    render(<FeatureList filters={{ search: '', page: 1, limit: 20 }} />);

    expect(await screen.findByText(/error/i)).toBeInTheDocument();
    const retryButton = screen.getByRole('button', { name: /retry/i });
    expect(retryButton).toBeInTheDocument();
  });
});
```

## 9 — Accessibility checklist

Before delivery, check:

- [ ] Semantic HTML (button, a, nav, main)
- [ ] Labels on all inputs
- [ ] Announceable errors with role="alert"
- [ ] Keyboard navigation (Tab, Enter, Escape)
- [ ] Focus visible and in logical order
- [ ] Images with alt text
- [ ] Color contrast above 4.5:1

## 10 — Delivery checklist

- [ ] TypeScript without `any` in public contracts
- [ ] External data validated with Zod
- [ ] All states handled (loading, error, empty, success)
- [ ] TanStack Query for data fetching
- [ ] Design system used (no hardcoded values)
- [ ] Build passes (`npm run build`)
- [ ] Lint without errors (`npm run lint`)
- [ ] Basic tests pass
- [ ] Accessibility verified

## Anti-patterns

- **Start coding without defining types**: types first, implementation after.
- **HTTP call in component**: use hook + TanStack Query.
- **Component handling fetch + logic + layout**: split responsibilities.
- **Skip states**: loading, error, and empty are mandatory.
- **Use any for convenience**: validate with Zod or type explicitly.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any below.

### Planning
- **Types before implementation**: define types/contracts BEFORE writing logic.
- **Check if similar code already exists**: do not duplicate features without verification.

### API and data
- **Validate external data with Zod**: API responses must be validated at the boundary layer.
- **HTTP call in component is prohibited**: use hook + TanStack Query.

### States and rendering
- **Handle all states**: loading, error, empty, and success are mandatory on every feature.
- **Do not mix fetch + logic + layout in one component**: split responsibilities.

### Quality
- **TypeScript without `any` in public contracts**: type explicitly or validate with Zod.
- **Build and lint must pass**: `npm run build` and `npm run lint` without errors.
- **Accessibility verified before delivery**: semantic HTML, labels, keyboard navigation, contrast.
