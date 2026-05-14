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

## Checklist operacional aprofundado

Use este bloco quando o plano tocar autenticação, autorização, validação de entrada, secrets e abuso operacional. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

### Entradas obrigatórias

- [ ] Plano técnico em `plans/` com objetivo, escopo e fora de escopo explícitos.
- [ ] Referências carregadas de `CLAUDE.md` e `docs/ai/*` relevantes ao tema.
- [ ] Lista de arquivos ou módulos afetados pelo plano.
- [ ] Impacto esperado em runtime, dados, testes, deploy e operação.
- [ ] Critérios de aceite verificáveis por comando, teste ou inspeção objetiva.

### Perguntas de revisão

- [ ] O plano preserva as invariantes arquiteturais do preset `python-backend`?
- [ ] O desenho evita acoplamento novo desnecessário entre camadas?
- [ ] Existe caminho incremental que reduza risco de mudança grande?
- [ ] As dependências novas são justificadas por necessidade real, não conveniência?
- [ ] A estratégia funciona no stack esperado: Python, FastAPI, Pydantic, SQLAlchemy/Alembic quando presentes?
- [ ] Há tratamento explícito para erro, timeout, retry e estado parcial?
- [ ] O plano descreve como observar falha em produção sem debugger local?
- [ ] O plano define rollback ou mitigação se o deploy quebrar?
- [ ] Migrações, contratos ou flags têm ordem segura de aplicação?
- [ ] A mudança mantém compatibilidade com consumidores existentes?
- [ ] Testes cobrem caminho feliz, bordas e falhas prováveis?
- [ ] Fixtures/mocks são determinísticos e não dependem de rede externa?
- [ ] Secrets, tokens e configuração ficam fora do git?
- [ ] Logs não vazam PII, credenciais, payload sensível ou dados financeiros?
- [ ] A solução mantém simplicidade operacional para alguém debugar às 2h?

### Severidade

- **BLOCKER**: quebra segurança, dados, deploy, contrato público ou impede rollback.
- **MAJOR**: aumenta dívida técnica relevante, fragiliza testes ou cria acoplamento caro.
- **MINOR**: melhoria local que não bloqueia execução segura.
- **NIT**: ajuste textual, nomenclatura ou clareza sem impacto técnico.

### Saída obrigatória

Para cada achado, responda neste formato:

```md
### <SEVERIDADE> — <título curto>

- Evidência: `<arquivo ou seção>`
- Risco: <efeito concreto se ignorar>
- Correção: <mudança específica no plano>
- Validação: `ruff check && mypy/pyright quando configurado && pytest` ou verificação equivalente
```

Se não houver achados, registre explicitamente:

```md
OK — revisei autenticação, autorização, validação de entrada, secrets e abuso operacional contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
