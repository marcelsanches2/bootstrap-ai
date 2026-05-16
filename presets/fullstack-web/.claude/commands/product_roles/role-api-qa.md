# review-api-qa

## Objetivo
Validar que o plano é testável com cenários suficientes.

## Fonte de referência
- docs/ai/TESTING_GUIDE.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Caminho feliz testável (input válido → output esperado)\n- [ ] Cenários negativos (400, 401, 403, 404, 409, 422)\n- [ ] Massa de dados determinística\n- [ ] Paginação testada\n- [ ] Edge cases (lista vazia, campo máximo, null)\n- [ ] Contrato API verificado (campos e tipos)\n- [ ] Dados sensíveis NÃO em response\n- [ ] Mocks para serviços externos\n- [ ] Testes independentes (sem ordem)

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção.

### Severidade
- BLOCKER: Caminho feliz sem teste, contrato API não verificável.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style.

## Saída em Markdown

```md
### review-api-qa
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta. Correção: ação.
```

## Regra dura
Plano que viola BLOCKER não está pronto.
