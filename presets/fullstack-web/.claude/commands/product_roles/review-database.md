# review-database

## Objetivo
Validar banco, migrations, queries, índices e integridade.

## Fonte de referência
- docs/ai/DATABASE_GUIDE.md, docs/ai/SCALABILITY_GUIDE.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Para cada mudança relevante, verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Migration criada e testada (prisma migrate)\n- [ ] Índice em toda foreign key (@@index)\n- [ ] Índice em colunas de busca frequente\n- [ ] Sem SELECT * — sempre select explícito\n- [ ] Sem N+1 — usar include no Prisma\n- [ ] Paginação em queries de lista\n- [ ] Transação ($transaction) em operações multi-step\n- [ ] Interactive transaction para operações concorrentes (saldo, estoque)\n- [ ] Tipos corretos (Decimal para dinheiro, DateTime com timezone)\n- [ ] Sem dado sensível em texto plano\n- [ ] Seed para dados iniciais

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção concreta.

### Severidade
- BLOCKER: Migration sem rollback, N+1 em lista, saldo sem lock, dado sensível texto plano.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style/conveniência.

## Saída em Markdown

```md
### review-database
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta.
  Correção: ação concreta.
...
```

## Regra dura
Plano que viola as regras BLOCKER não está pronto para implementação.
