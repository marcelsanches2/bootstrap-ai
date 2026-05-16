# review-api

## Objetivo
Validar contratos REST completos e consistentes.

## Fonte de referência
- docs/ai/API_GUIDE.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Para cada mudança relevante, verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Verbo HTTP correto (GET leitura, POST criação, PUT/PATCH atualização, DELETE remoção)\n- [ ] Path segue convenção (plural, kebab-case, max 2 níveis)\n- [ ] Versionamento presente (/api/v1/)\n- [ ] Zod schema de request definido (tipos, validação)\n- [ ] Response tipada (sem campos sensíveis)\n- [ ] Status codes corretos (201 POST, 204 DELETE, 404/409/422)\n- [ ] Paginação em endpoints de lista (skip/limit)\n- [ ] Erro segue formato padronizado (code/message/field)\n- [ ] Auth especificada em endpoints protegidos\n- [ ] Rate limiting em endpoints sensíveis\n- [ ] Sem dados sensíveis em response\n- [ ] Sem campo booleano "success"\n- [ ] Sem lógica de negócio no controller

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção concreta.

### Severidade
- BLOCKER: Endpoint sem schema, dados sensíveis expostos, auth faltando.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style/conveniência.

## Saída em Markdown

```md
### review-api
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta.
  Correção: ação concreta.
...
```

## Regra dura
Plano que viola as regras BLOCKER não está pronto para implementação.
