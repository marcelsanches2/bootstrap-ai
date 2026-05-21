# Role: Security Engineer

## Your contribution
Generates the "Security" section of the plan, defining authentication, authorization, input validation, sensitive data protection, and security headers.

## Reference
- docs/ai/SECURITY_GUIDE.md

## What to include
- **Authentication**: which mechanism (JWT, session), where to apply (`authMiddleware`), token durations (15min access, 7d refresh).
- **Authorization**: role or ownership verification on each protected endpoint. Define who can access what.
- **Input validation**: all input validated with Zod. Define schemas for body, query, and params.
- **Passwords**: always hashed with bcrypt. Never plain text.
- **JWT**: configured expiration, refresh token, revocation when applicable.
- **PII in logs**: no sensitive data in logs (password, token, Authorization header, cookie, unmasked PII).
- **PII in responses**: no sensitive data in the response (passwordHash, internal token).
- **CORS**: explicit origins, never `*`.
- **Rate limiting**: on login, password reset, and sensitive endpoints.
- **Helmet**: security headers configured.
- **SQL injection**: parameterized via ORM (Prisma already does this). No raw queries with concatenation.
- **Prohibitions**: no `eval`, `Function` with input, hardcoded secrets, HTTP in production.
- **Secrets**: via env vars, never in code.

## Rules
- Missing auth on protected endpoint is a BLOCKER.
- Plain text password is a BLOCKER.
- PII in log is a BLOCKER.
- CORS with `*` in production is a BLOCKER.
- Never commit secrets, tokens, real `.env`.
- If it doesn't apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## Security

### Authentication
- **Mechanism**: {JWT / session / API key}
- **Access token**: {duration}
- **Refresh token**: {duration}
- **Middleware**: {name and where to apply}
- **Revocation**: {mechanism when applicable}

### Authorization
| Endpoint | Role/Permission | Verification |
|----------|----------------|-------------|
| {path} | {role} | {how to verify ownership/role} |

### Input validation
- Body: Zod schema `{example}`
- Query: Zod schema `{example}`
- Params: Zod schema `{example}`

### Sensitive data
| Data | Storage | In log | In response |
|------|----------|--------|-------------|
| password | bcrypt hash | ❌ masked | ❌ never |
| token | env var | ❌ masked | ❌ never |
| PII {type} | {protection} | {masking} | {policy} |

### CORS
- Allowed origins: `{list}`
- Never `*` in production.

### Rate limiting
| Endpoint | Limit | Window |
|----------|-------|--------|
| {path} | {n requests} | {time} |

### Security headers
- Helmet: {enabled with config}
- Additional headers: {list if applicable}

### Security checklist
- [ ] No `eval` or `Function` with input
- [ ] No hardcoded secrets
- [ ] HTTPS in production
- [ ] Parameterized SQL (via ORM)
- [ ] Secrets via env vars
```
