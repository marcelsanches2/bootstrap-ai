# Role: Delivery Web

## Your contribution
Generates the "Deploy and delivery" section of the plan, covering environment variables, CI/CD, production build, cache, and rollback strategy.

## Reference
- docs/ai/DEPLOYMENT_GUIDE.md

## What to include
- **Environment variables**: list all required env vars (public only for frontend). Document name, type, default value, and where they are used. Never include secrets.
- **CI/CD**: continuous integration and delivery pipeline — which commands run (lint, typecheck, test, build), in what order, and what triggers the deploy.
- **Production build**: build command, output directory, start command (if SSR). Confirm build passes before deploy.
- **Cache/CDN**: cache strategy for static assets (hash in name) and HTML/entrypoint. Ensure update does not serve incompatible version.
- **Rollback**: how to revert to previous build. Check API and cache compatibility when rolling back.
- **Hosting**: SPA fallback (all routes → index.html), relevant headers (CSP, CORS), TLS when applicable.

## Rules
- Never propose committing real `.env` — only `.env.example` with example values.
- Every secret (API key, token) must come from env var injected at runtime, never hardcoded in the bundle.
- Production build must be validated as an explicit pipeline step.
- Always define a rollback strategy — do not assume deploy never fails.
- If not applicable to the task: write "Does not apply" and explain why.

## Output format

Return Markdown only. Be concise; prefer bullets over prose and tables only for real comparisons.

Required section(s):
- `## Deploy and delivery`

For each section include only: decision, risk, validation. Skip boilerplate.
If the role does not apply, write exactly one sentence: `Does not apply — {reason}`.
Do not duplicate sections owned by another selected role; mention cross-cutting dependencies in one bullet.
