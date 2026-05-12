# Guia de Banco de Dados

## Princípio

Schema é código. Toda mudança deve ser revisável, reversível quando possível e segura para dados existentes.

## Migrations

- Toda alteração de schema precisa de migration Alembic.
- `upgrade` deve ser explícito.
- `downgrade` deve existir ou documentar por que é impossível.
- Migration destrutiva exige backup e plano de rollout.
- Dados backfilled precisam de estratégia idempotente.

## Modelagem

- Chave primária estável.
- Foreign keys quando integridade relacional importa.
- `NOT NULL` somente quando backfill/valor default estiver resolvido.
- Enum em banco exige plano para novos valores.
- Campos de auditoria (`created_at`, `updated_at`) devem ter timezone/semântica consistente.

## Índices

Crie índice quando:

- coluna participa de lookup frequente
- FK é usada em join/filtro
- ordenação/paginação depende dela
- constraint de unicidade representa regra de negócio

Não crie índice por reflexo; índice aumenta custo de escrita.

## Transações e concorrência

- Use transação por caso de uso, não por função aleatória.
- Operações idempotentes precisam de chave idempotente ou constraint única.
- Evite read-modify-write sem lock/constraint quando há concorrência.
- Webhooks devem tolerar reentrega.

## Queries

- Evite N+1.
- Paginação deve ter ordenação determinística.
- Query complexa precisa de teste ou EXPLAIN quando performance for risco.

## Produção

Antes de tocar produção:

1. backup verificado
2. migration testada em cópia ou ambiente staging
3. rollback/downgrade documentado
4. impacto de lock estimado para tabelas grandes
