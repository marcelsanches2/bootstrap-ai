# React Web Testing Guide

## Layers

- Unit: functions, formatters, simple hooks.
- Component: visual states, interaction, and basic accessibility.
- Integration: screen with mocked data.
- E2E: realistic critical journey.

## What to test

For a UI feature, cover:

- initial render
- loading
- empty
- error
- success
- main interaction
- relevant negative scenario
- basic accessibility when possible

## Mocks

- MSW or equivalent for API when available.
- Deterministic mock, no dependency on real network.
- Do not mock the component that is the test target.

## Build and regression

Large changes need a production build. Unit tests do not replace the build.

## Typical commands

```bash
npm run lint
npm run typecheck
npm test
npm run build
npx playwright test  # when E2E exists
```

Use the project's actual scripts.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any below.

- **Do not mock the test target**: never mock the component/function that is precisely what is being tested.
- **Production build required for large changes**: unit tests do not replace the build; run `npm run build`.
- **Deterministic mocks**: tests must not depend on real network; use MSW or equivalent.
- **Cover UI states**: render, loading, empty, error, success, and main interaction must be tested.
