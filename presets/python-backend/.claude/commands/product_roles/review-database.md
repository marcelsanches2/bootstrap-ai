# Role: Database Designer

## Your contribution
Generates the "Database" section of the plan, defining schema, migrations, indexes, constraints, queries and ORM usage.

## Reference
- docs/ai/DATABASE_GUIDE.md
- docs/ai/SCALABILITY_GUIDE.md

## What to include
- **Schema**: define tables, columns, types, relationships and constraints. Correct types (Numeric for money, String with limit, DateTime with timezone).
- **Migrations**: for each migration, write complete upgrade() and downgrade(). Describe what each one does.
- **Indexes**: index on every foreign key. Index on frequently searched columns (WHERE, JOIN). Composite indexes when the query benefits.
- **Constraints**: unique constraints where it makes sense (email, slug, code). Check constraints for domain validation in the database.
- **Queries**: explicit columns (no SELECT *). Eager loading (selectinload/joinedload) to avoid N+1. Pagination (offset for <1M, cursor for >1M). Statement timeout in production.
- **Transactions**: explicit boundary in multi-step operations (create + update related).
- **Locks**: pessimistic lock (`with_for_update`) in concurrent operations (balance, inventory, credit).
- **Sensitive data**: no sensitive data in plain text — password hash (bcrypt/argon2), PII encrypted when necessary.
- **Seeds/fixtures**: initial data needed for the feature to work.

## Rules
- Every migration must have complete upgrade() AND downgrade() and be tested.
- Every foreign key must have an index.
- No SELECT * — always explicit columns.
- No N+1 query — use eager loading when accessing relationships.
- Balance/inventory/credit must have pessimistic lock.
- Numeric type for money, never Float.
- If it does not apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## Database

### Schema

#### Table: {name}
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PK, default uuid4 | Identifier |
| {column} | {type} | {constraints} | {description} |

**Relationships:**
- {table_a} → {table_b}: {type (1:N, N:1, N:M)}

### Migrations

#### {alembic/versions/xxx_description.py}
- **upgrade()**: {what it does}
- **downgrade()**: {what it does}
- **Safe rollback**: {how to test the downgrade}

### Indexes
| Table | Column(s) | Type | Reason |
|-------|-----------|------|--------|
| {table} | {column} | {unique/btree/} | {FK lookup, frequent WHERE} |

### Constraints
| Table | Type | Column(s) | Reason |
|-------|------|-----------|--------|
| {table} | UNIQUE | {column} | {unique email} |
| {table} | CHECK | {column} | {value > 0} |

### Critical queries
| Query | Optimization | Pagination |
|-------|-------------|------------|
| {listing of X} | {eager loading, index} | {offset/cursor} |

### Transactions
| Flow | Operations | Lock |
|------|-----------|------|
| {order creation} | create order + update stock | {with_for_update on stock} |

### Seeds/fixtures
- `{seed_name}`: {data it inserts, when it is needed}
```
