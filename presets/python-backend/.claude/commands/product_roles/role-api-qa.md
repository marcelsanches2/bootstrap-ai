# review-api-qa

## Objetivo
Validar que o plano é testável e cobre cenários suficientes de teste (positivos, negativos, edge cases).

## Fonte de referência
- `docs/ai/TESTING_GUIDE.md`
- `docs/ai/API_GUIDE.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Para cada endpoint ou fluxo, inventariar cenários de teste e verificar cobertura.

## Checklist obrigatório

- [ ] Caminho feliz testável (input válido → output esperado)
- [ ] Cenários negativos (400: input inválido, 401: não autenticado, 403: sem permissão, 404: não encontrado, 409: conflito, 422: validação)
- [ ] Massa de dados determinística descrita (factories, fixtures)
- [ ] Paginação testada (primeira página, última página, beyond total, limites)
- [ ] Edge cases identificados (lista vazia, único item, campo máximo, unicode, null)
- [ ] Contrato API testado (response tem campos certos, tipos certos)
- [ ] Dados sensíveis NÃO aparecem em response (password_hash, token)
- [ ] Testes de integração para endpoints críticos
- [ ] Mocks externos especificados (email, payment gateway, SMS)
- [ ] Ordem de execução não importa (testes independentes)

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + cenário faltando + correção.

### Severidade
- BLOCKER: caminho feliz sem teste, contrato API não verificável.
- MAJOR: cenário negativo crítico ausente (auth, conflito), massa não determinística.
- MINOR: edge case faltando.

## Saída em Markdown

```md
### review-api-qa

- [OK] Caminho feliz — POST /api/v1/orders com items válidos retorna 201. ✓
- [PENDÊNCIA MAJOR] Auth — GET /api/v1/orders sem token não testado.
  Correção: adicionar teste esperando 401 sem Authorization header.
- [PENDÊNCIA MAJOR] Conflito — POST /api/v1/orders com item inexistente não testado.
  Correção: adicionar teste com product_id inválido esperando 404 ou 400.
...
```

## Regra dura
Plano com endpoint sem cenário de teste para caminho feliz, ou sem verificar contrato API, não está pronto.
