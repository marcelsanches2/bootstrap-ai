# review-api

## Objetivo
Validar que o plano segue as convenções REST e os contratos HTTP estão completos e consistentes.

## Fonte de referência
- `docs/ai/API_GUIDE.md`
- `docs/ai/ARCHITECTURE.md`

## Entrada esperada
Plano técnico em `plans/*.md` com endpoints documentados.

## Método
Para cada endpoint mencionado no plano, verificar se o contrato está completo e segue as convenções.

## Checklist obrigatório

- [ ] Verbo HTTP correto (GET para leitura, POST para criação, PUT/PATCH para atualização, DELETE para remoção)
- [ ] Path segue convenção (plural, kebab-case, max 2 níveis de nesting)
- [ ] Versionamento presente (/api/v1/)
- [ ] Schema de request definido (Pydantic com tipos, validação e exemplos)
- [ ] Schema de response definido (sem campos sensíveis)
- [ ] Status codes documentados (201 para POST, 204 para DELETE, 404/409/422 quando aplicável)
- [ ] Paginação em endpoints de lista (skip/limit com limites claros)
- [ ] Filtros e ordenação documentados quando aplicável
- [ ] Erro segue formato padronizado (ErrorDetail com code/message/field)
- [ ] Autenticação/autorização especificada (público, autenticado, role específica)
- [ ] Rate limiting especificado para endpoints sensíveis (login, reset password)
- [ ] Não há dados sensíveis em response (password_hash, token interno)
- [ ] Não há campo booleano "success" em response (usar status code)
- [ ] Não há lógica de negócio no router (deve estar em service)

## Resultado esperado por item

Para cada item:
- **OK**: evidência de conformidade (cite o endpoint e a especificação).
- **OK — não aplicável**: explique por que não se aplica a este plano.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta, em qual endpoint, e correção concreta.

### Severidade

- BLOCKER: endpoint sem schema, verbo errado, dados sensíveis expostos, auth faltando em endpoint protegido.
- MAJOR: paginação ausente em lista, status code inconsistente, erro sem formato padrão, rate limiting ausente.
- MINOR: nomenclatura fora de padrão, exemplo ausente no schema.

## Saída em Markdown

```md
### review-api

- [OK] Verbo HTTP — POST /api/v1/orders para criação. ✓
- [OK] Path — /api/v1/orders segue convenção. ✓
- [PENDÊNCIA MAJOR] Paginação — GET /api/v1/orders não documenta skip/limit.
  Correção: adicionar query params skip (default 0) e limit (default 20, max 100).
...
```

## Regra dura
Plano com endpoint sem schema de request E response, ou com dados sensíveis em response, não está pronto para implementação.
