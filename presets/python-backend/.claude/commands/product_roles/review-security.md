# Role: Security Designer

## Sua contribuição
Gera a seção "Segurança" do plano, cobrindo autenticação, autorização, validação de input, proteção de dados sensíveis e rate limiting.

## Referência
- docs/ai/SECURITY_GUIDE.md

## O que incluir
- **Autenticação**: para cada endpoint protegido, especifique o mecanismo (`Depends(get_current_user)`, JWT). Defina expiração de tokens (access: 15min, refresh: 7d).
- **Autorização**: verificação de role ou ownership. Qual role acessa qual recurso. Como verificar ownership (user_id no token vs recurso).
- **Validação de input**: Pydantic com tipos, ranges, tamanhos, regex. Nenhum input sem validação.
- **Senhas**: sempre hasheadas com bcrypt ou argon2. Nunca texto plano. Nunca logar.
- **JWT**: expiração configurável, secrets via env vars, nunca hardcoded.
- **Dados sensíveis em logs**: nenhum password, token, Authorization header, cookie ou PII sem mascaramento.
- **Dados sensíveis em response**: nenhum password_hash, secret interno ou PII desnecessário.
- **CORS**: origins explícitos. Nunca `*` em produção.
- **Rate limiting**: em endpoints sensíveis — login, reset password, registro. Defina limites (ex: `5/minute`).
- **Headers de segurança**: X-Content-Type-Options, HSTS, X-Frame-Options.
- **SQL injection**: SQLAlchemy parametriza automaticamente, mas verificar raw queries. Nenhum eval/exec com input externo.
- **Secrets**: sempre via env vars, nunca hardcoded.
- **HTTPS**: obrigatório em produção.

## Regras
- Todo endpoint protegido deve ter auth especificado.
- Senha sempre hasheada, nunca em texto plano, nunca em log.
- Input sempre validado com Pydantic.
- Nenhum dado sensível em log ou response.
- CORS nunca `*` em produção.
- Secrets sempre via env vars.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## Segurança

### Autenticação
| Endpoint | Auth | Detalhe |
|----------|------|---------|
| POST /api/v1/auth/login | Público | Retorna access_token (15min) + refresh_token (7d) |
| GET /api/v1/{resource} | Depends(get_current_user) | JWT Bearer |
| ... | ... | ... |

### Autorização
| Recurso | Role necessária | Ownership check |
|---------|----------------|-----------------|
| {recurso} | {role} | {como verificar} |

### Validação de input
| Endpoint | Campos validados | Regras |
|----------|-----------------|--------|
| POST /api/v1/{resource} | {campos} | {tamanho, range, regex} |

### Senhas e tokens
- Hash: {bcrypt/argon2}
- Access token TTL: {15min}
- Refresh token TTL: {7d}
- Secret via: env var `{JWT_SECRET}`

### Rate limiting
| Endpoint | Limite | Implementação |
|----------|--------|---------------|
| POST /api/v1/auth/login | 5/minute | {decorator/middleware} |
| POST /api/v1/auth/register | 3/minute | {decorator/middleware} |

### CORS
- Origins permitidas: `{lista}`
- Nunca `*` em produção: ✓

### Headers de segurança
- X-Content-Type-Options: nosniff
- Strict-Transport-Security: max-age=31536000
- X-Frame-Options: DENY

### Proteção de dados sensíveis
- **Logs**: nenhum password, token, PII sem mascaramento
- **Response**: nenhum password_hash, secret interno
- **Banco**: PII criptografado quando necessário

### Checklist de produção
- [ ] HTTPS obrigatório
- [ ] Secrets via env vars (nunca hardcoded)
- [ ] Nenhum eval/exec com input externo
- [ ] Raw queries verificadas contra SQL injection
```
