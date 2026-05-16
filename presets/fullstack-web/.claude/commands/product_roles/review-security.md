# review-security

## Objetivo
Validar auth, autorização, dados sensíveis e proteção contra ataques.

## Fonte de referência
- docs/ai/SECURITY_GUIDE.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Para cada mudança relevante, verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Autenticação em endpoints protegidos (authMiddleware)\n- [ ] Autorização verificada (role ou ownership)\n- [ ] Input validado com Zod\n- [ ] Senha hasheada com bcrypt\n- [ ] JWT com expiração (15min access, 7d refresh)\n- [ ] Nenhum dado sensível em log\n- [ ] Nenhum dado sensível em response (passwordHash, token)\n- [ ] CORS com origins explícitos (nunca *)\n- [ ] Rate limiting em login/reset\n- [ ] Helmet para security headers\n- [ ] SQL parametrizado (Prisma já faz)\n- [ ] Sem eval/Function com input\n- [ ] Secrets via env vars\n- [ ] HTTPS em produção

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção concreta.

### Severidade
- BLOCKER: Auth faltando em endpoint protegido, senha texto plano, PII em log.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style/conveniência.

## Saída em Markdown

```md
### review-security
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta.
  Correção: ação concreta.
...
```

## Regra dura
Plano que viola as regras BLOCKER não está pronto para implementação.
