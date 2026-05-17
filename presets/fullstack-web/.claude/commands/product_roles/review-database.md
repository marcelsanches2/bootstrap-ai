# Role: Banco de Dados

## Sua contribuição
Gera a seção "Banco de dados" do plano, definindo schema, migrations, índices, queries e integridade de dados.

## Referência
- docs/ai/DATABASE_GUIDE.md
- docs/ai/SCALABILITY_GUIDE.md

## O que incluir
- **Migration**: migration criada e testada (`prisma migrate dev`/`deploy`). Comando de rollback/downgrade documentado.
- **Schema**: modelos novos/alterados com campos, tipos e constraints. Tipos corretos (Decimal para dinheiro, DateTime com timezone).
- **Índices**: `@@index` em toda foreign key. Índice em colunas de busca frequente. Justificativa para cada índice.
- **Queries**: select explícito (nunca `SELECT *`), N+1 evitado com `include`/`select`, paginação em queries de lista.
- **Transações**: `$transaction` em operações multi-step. Interactive transaction para operações concorrentes (saldo, estoque).
- **Dados sensíveis**: nunca em texto plano (hash, encrypt).
- **Seed**: dados iniciais necessários.

## Regras
- Migration sem rollback é bloqueante.
- N+1 em listagem é bloqueante.
- Saldo/estoque sem lock/transaction é bloqueante.
- Dado sensível em texto plano é bloqueante.
- Nunca alterar schema sem migration e rollback documentado.
- Se a task não envolve banco de dados: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Banco de dados

### Schema
| Modelo | Campo | Tipo | Constraint | Observação |
|---|---|---|---|---|
| {Model} | {campo} | {tipo} | {unique/required/default} | {notas} |

### Índices
| Modelo | Campos | Tipo | Justificativa |
|---|---|---|---|
| {Model} | {campos} | {unique/index} | {por quê} |

### Migration
| Nome | Comando up | Comando down | Testada |
|---|---|---|---|
| {nome} | {prisma migrate deploy} | {prisma migrate resolve --rolled-back} | {sim/não} |

### Queries críticas
| Operação | Query | Otimização |
|---|---|---|
| {descrição} | {include/select/where} | {índice/paginação/...} |

### Transações
| Operação | Tipo | Escopo |
|---|---|---|
| {descrição} | {batch/interactive} | {tabelas envolvidas} |

### Seed
| Dado | Arquivo | Condição |
|---|---|---|
| {dado inicial} | {seed.ts} | {quando executa} |
```
