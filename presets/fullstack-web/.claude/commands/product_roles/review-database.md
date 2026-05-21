# Role: Database

## Your contribution
Generates the "Database" section of the plan, defining schema, migrations, indexes, queries, and data integrity.

## Reference
- docs/ai/DATABASE_GUIDE.md
- docs/ai/SCALABILITY_GUIDE.md

## What to include
- **Migration**: migration created and tested (`prisma migrate dev`/`deploy`). Rollback/downgrade command documented.
- **Schema**: new/altered models with fields, types, and constraints. Correct types (Decimal for money, DateTime with timezone).
- **Indexes**: `@@index` on every foreign key. Index on frequently searched columns. Justification for each index.
- **Queries**: explicit select (never `SELECT *`), N+1 avoided with `include`/`select`, pagination on list queries.
- **Transactions**: `$transaction` for multi-step operations. Interactive transaction for concurrent operations (balance, inventory).
- **Sensitive data**: never in plain text (hash, encrypt).
- **Seed**: initial data needed.

## Rules
- Migration without rollback is blocking.
- N+1 in listing is blocking.
- Balance/inventory without lock/transaction is blocking.
- Sensitive data in plain text is blocking.
- Never alter schema without migration and documented rollback.
- If the task does not involve the database: write "Does not apply" and explain why.

## Output format

```md
## Database

### Schema
| Model | Field | Type | Constraint | Notes |
|---|---|---|---|---|
| {Model} | {field} | {type} | {unique/required/default} | {notes} |

### Indexes
| Model | Fields | Type | Justification |
|---|---|---|---|
| {Model} | {fields} | {unique/index} | {why} |

### Migration
| Name | Up command | Down command | Tested |
|---|---|---|---|
| {name} | {prisma migrate deploy} | {prisma migrate resolve --rolled-back} | {yes/no} |

### Critical queries
| Operation | Query | Optimization |
|---|---|---|
| {description} | {include/select/where} | {index/pagination/...} |

### Transactions
| Operation | Type | Scope |
|---|---|---|
| {description} | {batch/interactive} | {tables involved} |

### Seed
| Data | File | Condition |
|---|---|---|
| {initial data} | {seed.ts} | {when it runs} |
```
