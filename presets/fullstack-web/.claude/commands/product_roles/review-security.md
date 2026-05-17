# Role: Segurança

## Sua contribuição
Gera a seção "Segurança" do plano, definindo auth, autorização, validação, proteção de dados sensíveis e proteção contra ataques.

## Referência
- docs/ai/SECURITY_GUIDE.md

## O que incluir
- **Autenticação**: endpoints protegidos com middleware de auth. Fluxo de login/refresh/token.
- **Autorização**: verificação de role ou ownership em cada operação sensível.
- **Validação de input**: Zod em todas as entradas de boundary (controller, API route).
- **Senhas**: hasheadas com bcrypt, nunca texto plano.
- **JWT**: com expiração (access 15min, refresh 7d). Refresh token rotation.
- **Dados sensíveis em logs**: nenhum token, senha, Authorization header, cookie ou PII sem mascaramento.
- **Dados sensíveis em response**: nenhum passwordHash, token ou PII exposto.
- **CORS**: origins explícitos, nunca `*`.
- **Rate limiting**: em login, reset e endpoints sensíveis.
- **Security headers**: Helmet configurado.
- **SQL injection**: queries parametrizadas (Prisma já faz por padrão).
- **Code injection**: sem `eval`/`Function` com input do usuário.
- **Secrets**: via env vars, nunca hardcoded.
- **HTTPS**: em produção.

## Regras
- Auth faltando em endpoint protegido é bloqueante.
- Senha em texto plano é bloqueante.
- PII em log é bloqueante.
- CORS com `*` em produção é bloqueante.
- Nunca commitar secrets, tokens, dumps, `.env` real ou credenciais.
- Se a task não tem superfície de segurança nova: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Segurança

### Autenticação e autorização
| Endpoint | Auth | Role/Ownership | Middleware |
|---|---|---|---|
| {VERB /path} | {público/protegido} | {regra} | {nome do middleware} |

### Validação de input
| Endpoint | Schema | Campos validados |
|---|---|---|
| {VERB /path} | {Zod schema} | {campos + regras} |

### Dados sensíveis
| Dado | Armazenamento | Em log | Em response |
|---|---|---|---|
| {senha/token/PII} | {hash/encrypt} | {mascarado/não loga} | {não retorna} |

### CORS
| Ambiente | Origins | Methods | Headers |
|---|---|---|---|
| {dev/prod} | {URLs} | {métodos} | {headers} |

### Rate limiting
| Endpoint | Limite | Janela | Estratégia |
|---|---|---|---|
| {path} | {N requests} | {tempo} | {IP/user} |

### Security headers
{headers configurados via Helmet ou manual}

### Secrets
| Variável | Uso | Nunca hardcoded |
|---|---|---|
| {NOME} | {para quê} | {confirmado} |
```
