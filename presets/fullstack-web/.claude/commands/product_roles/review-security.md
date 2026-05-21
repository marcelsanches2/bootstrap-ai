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

```md
## Security

### Authentication and authorization
| Endpoint | Auth | Role/Ownership | Middleware |
|---|---|---|---|
| {VERB /path} | {public/protected} | {rule} | {middleware name} |

### Input validation
| Endpoint | Schema | Validated fields |
|---|---|---|
| {VERB /path} | {Zod schema} | {fields + rules} |

### Sensitive data
| Data | Storage | In logs | In response |
|---|---|---|---|
| {password/token/PII} | {hash/encrypt} | {masked/not logged} | {not returned} |

### CORS
| Environment | Origins | Methods | Headers |
|---|---|---|---|
| {dev/prod} | {URLs} | {methods} | {headers} |

### Rate limiting
| Endpoint | Limit | Window | Strategy |
|---|---|---|---|
| {path} | {N requests} | {time} | {IP/user} |

### Security headers
{headers configured via Helmet or manually}

### Secrets
| Variable | Usage | Never hardcoded |
|---|---|---|
| {NAME} | {what for} | {confirmed} |
```
