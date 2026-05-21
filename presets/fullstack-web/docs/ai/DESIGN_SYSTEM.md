# Design System

## Objective

Ensure visual consistency and reduce rework without blocking product evolution.

## Tokens

Use centralized tokens for:

- color
- typography
- spacing
- border radius
- shadow
- z-index
- breakpoints

Hardcoded values are only acceptable if the project doesn't yet have a corresponding token and the plan proposes consolidating later.

## Components

Reusable components must have:

- states: default, hover, focus, disabled, loading, error when applicable
- variations named by intent, not by loose color
- built-in accessibility
- simple props API

## Layout

- Mobile, tablet, and desktop when applicable.
- Do not assume a single width.
- Define overflow, truncation, and empty state behavior.

## UX states

Every async screen/flow must decide:

- loading
- empty
- error
- success
- permission denied when applicable

## Visual rule

Do not accept "functional but ugly" UI in product delivery. If the plan doesn't define enough visual detail to implement with quality, flag it as a pending item.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Do not use hardcoded values when a corresponding token exists**: color, spacing, typography must come from the design system.
- **Do not assume a single width**: layout must work on mobile, tablet, and desktop when applicable.
- **Do not accept "functional but ugly" UI**: if the plan doesn't define enough visual detail, flag it as a pending item.
- **Every async screen/flow must decide UI states**: loading, empty, error, success, permission denied.
