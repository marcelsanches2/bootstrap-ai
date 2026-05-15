# review-security

## Objetivo
Validar que o plano trata autenticação, autorização, dados sensíveis e proteção contra ataques comuns.

## Fonte de referência
- `docs/ai/SECURITY_GUIDE.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Para cada endpoint, fluxo ou mudança que envolve auth, dados ou entrada externa, verificar se segurança está tratada.

## Checklist obrigatório

- [ ] Autenticação especificada em endpoints protegidos (Depends(get_current_user))
- [ ] Autorização verificada (role ou ownership check)
- [ ] Input validado com Pydantic (tipos, ranges, tamanhos)
- [ ] Senha hasheada com bcrypt/argon2 (nunca texto plano)
- [ ] JWT com expiração (access 15min, refresh 7d)
- [ ] Nenhum dado sensível em log (senha, token, PII)
- [ ] Nenhum dado sensível em response (password_hash, secret interno)
- [ ] CORS configurado com origins explícitos (nunca * em produção)
- [ ] Rate limiting em endpoints sensíveis (login, reset password, registro)
- [ ] Headers de segurança presentes (X-Content-Type-Options, HSTS, X-Frame-Options)
- [ ] SQL parametrizado (SQLAlchemy já faz, mas verificar raw queries)
- [ ] Nenhum eval/exec com input externo
- [ ] Secrets via env vars, nunca hardcoded
- [ ] HTTPS obrigatório em produção

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + risco + correção.

### Severidade
- BLOCKER: auth faltando em endpoint protegido, senha em texto plano, PII em log, SQL injection.
- MAJOR: rate limiting ausente em login, CORS wildcard, input sem validação.
- MINOR: header de segurança faltando.

## Saída em Markdown

```md
### review-security

- [OK] Auth — POST /api/v1/orders usa Depends(get_current_user). ✓
- [PENDÊNCIA BLOCKER] Login sem rate limiting — vulnerável a brute force.
  Correção: adicionar @limiter.limit("5/minute") em POST /api/v1/auth/login.
...
```

## Regra dura
Plano com endpoint protegido sem auth, ou com dado sensível em log/response, ou com input não validado, não está pronto.
