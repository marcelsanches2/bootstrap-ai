# review-database

## Objetivo
Validar que o plano trata corretamente banco de dados, migrations, queries, índices e integridade dos dados.

## Fonte de referência
- `docs/ai/DATABASE_GUIDE.md`
- `docs/ai/SCALABILITY_GUIDE.md` quando houver volume/concorrência

## Entrada esperada
Plano técnico em `plans/*.md` que menciona dados, tabelas, queries ou migrations.

## Método
Para cada mudança que envolve banco, verificar se migration, índice, query e integridade estão tratados.

## Checklist obrigatório

- [ ] Migration criada com upgrade() E downgrade() completos
- [ ] Índice em toda foreign key
- [ ] Índice em colunas de busca frequente (WHERE, JOIN)
- [ ] Constraint de unicidade onde faz sentido (email, slug, código)
- [ ] Nenhum SELECT * — colunas explícitas
- [ ] Nenhuma query N+1 — eager loading (selectinload/joinedload) quando acessa relacionamento
- [ ] Paginação em queries de lista (offset para <1M, cursor para >1M)
- [ ] Timeout em queries (statement timeout em produção)
- [ ] Transação explícita em operações multi-step (create + update relacionados)
- [ ] Pessimistic lock (with_for_update) em operações concorrentes (saldo, estoque)
- [ ] Tipo correto para colunas (Numeric para dinheiro, String com limite, DateTime com timezone)
- [ ] Não há dado sensível em texto plano (hash de senha, PII criptografado)
- [ ] Seed ou fixture para dados iniciais necessários

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + o que falta + correção concreta.

### Severidade
- BLOCKER: migration sem downgrade, N+1 em endpoint de lista, saldo sem lock, dado sensível em texto plano.
- MAJOR: índice faltando em FK, paginação ausente, tipo incorreto para dinheiro.
- MINOR: seed faltando, comment faltando em migration.

## Saída em Markdown

```md
### review-database

- [OK] Migration — upgrade() e downgrade() presentes. ✓
- [PENDÊNCIA BLOCKER] N+1 — GET /api/v1/orders lista items sem eager loading.
  Correção: adicionar .options(selectinload(Order.items)) na query.
- [PENDÊNCIA MAJOR] Índice — FK order_items.order_id sem índice.
  Correção: adicionar op.create_index("ix_order_items_order_id", ...) na migration.
...
```

## Regra dura
Plano que toca banco sem migration com downgrade, ou com N+1 em endpoint de lista, ou com saldo/estoque sem lock, não está pronto.
