# Role: Security

## Your contribution
Generates the "Security" section of the plan, defining auth, authorization, validation, sensitive data protection, and attack protection.

## Reference
- docs/ai/SECURITY_GUIDE.md

## What to include
- **Authentication**: protected endpoints with auth middleware. Login/refresh/token flow.
- **Authorization**: role or ownership check on each sensitive operation.
- **Input validation**: Zod on all boundary inputs (controller, API route).
- **Passwords**: hashed with bcrypt, never plain text.
- **JWT**: with expiration (access 15min, refresh 7d). Refresh token rotation.
- **Sensitive data in logs**: no tokens, passwords, Authorization headers, cookies, or PII without masking.
- **Sensitive data in response**: no passwordHash, token, or exposed PII.
- **CORS**: explicit origins, never `*`.
- **Rate limiting**: on login, reset, and sensitive endpoints.
- **Security headers**: Helmet configured.
- **SQL injection**: parameterized queries (Prisma does this by default).
- **Code injection**: no `eval`/`Function` with user input.
- **Secrets**: via env vars, never hardcoded.
- **HTTPS**: in production.

## Rules
- Missing auth on protected endpoint is blocking.
- Password in plain text is blocking.
- PII in logs is blocking.
- CORS with `*` in production is blocking.
- Never commit secrets, tokens, dumps, real `.env`, or credentials.
- If the task has no new security surface: write "Does not apply" and explain why.

## Output format

Return Markdown only. Be concise; prefer bullets over prose and tables only for real comparisons.

Required section(s):
- `## Security`

For each section include only: decision, risk, validation. Skip boilerplate.
If the role does not apply, write exactly one sentence: `Does not apply — {reason}`.
Do not duplicate sections owned by another selected role; mention cross-cutting dependencies in one bullet.
