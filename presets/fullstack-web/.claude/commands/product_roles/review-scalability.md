# Role: Scale

## Your contribution
Generates the "Scale" section of the plan, defining concurrency, queues, cache, pool, limits, and load validation strategies to support real production.

## Reference
- docs/ai/SCALABILITY_GUIDE.md
- docs/ai/DATABASE_GUIDE.md
- docs/ai/OBSERVABILITY_GUIDE.md

## What to include
- **Volume and hot path**: identify endpoints, jobs, queries, or screens that may receive high volume. Justify when it doesn't apply.
- **Database and queries**: pagination, filters, sorting, N+1, indexes, constraints, and cost of critical queries per expected volume.
- **Concurrency and idempotency**: read-modify-write, retries, webhooks, parallel jobs, duplicate creation, balance/inventory/credit. Mitigation via transaction, constraint, lock, or idempotency key.
- **Limits and backpressure**: max payload, pagination, rate limit, connection pool, timeouts, queues, workers, and memory consumption. No unlimited resource consumption.
- **Cache and invalidation**: key, TTL, scope, invalidation, stale data, and metrics. Cache without invalidation is technical debt.
- **Queues and jobs**: idempotency, retry/backoff, dead-letter, max concurrency, backlog, and logging by job id.
- **External integrations**: timeout, safe retry, degradation, circuit breaker, metrics, and failure testing.
- **Scale observability**: p95/p99 latency, error rate, throughput, pool/connections, backlog, and logs with request/job id.
- **Performance/load validation**: concurrent test, query test with volume, benchmark, or load smoke test proportional to risk.

## Rules
- Data corruption from concurrency is blocking.
- Financial/operational duplication is blocking.
- Incident without clear rollback is blocking.
- Unlimited resource consumption (CPU, memory, connection, queue, network) is blocking.
- Do not over-engineer — only address predictable production failures.
- If the change is small with no scale risk: write "Does not apply" and explain why.

## Output format

```md
## Scale

### Volume and hot path
| Operation | Expected volume | Strategy |
|---|---|---|
| {endpoint/job/query} | {estimate} | {optimization} |

### Database and queries
| Query | Risk | Index | Pagination |
|---|---|---|---|
| {operation} | {N+1/full scan/...} | {created/existing} | {skip/limit} |

### Concurrency and idempotency
| Operation | Risk | Mitigation |
|---|---|---|
| {read-modify-write/retry/webhook} | {duplication/inconsistency} | {transaction/lock/constraint/idempotency key} |

### Limits and backpressure
| Resource | Limit | Configuration |
|---|---|---|
| {payload/pagination/rate limit/pool/timeout/queue/workers/memory} | {value} | {where configured} |

### Cache
| Data | Key | TTL | Invalidation | Scope |
|---|---|---|---|---|
| {cached data} | {key format} | {time} | {event/timeout} | {global/user/tenant} |

### Queues and jobs
| Job | Idempotency | Retry | Dead-letter | Max concurrency |
|---|---|---|---|---|
| {name} | {how it guarantees} | {attempts + backoff} | {yes/no} | {workers} |

### External integrations
| Service | Timeout | Retry | Circuit breaker | Degradation |
|---|---|---|---|---|
| {name} | {ms} | {attempts} | {yes/no} | {fallback} |

### Scale observability
| Metric | Threshold | Alert |
|---|---|---|
| {p95/throughput/error rate/pool/backlog} | {value} | {when it fires} |

### Performance validation
| Test | Tool | Volume | Pass criteria |
|---|---|---|---|
| {type} | {k6/artillery/manual} | {RPS/connections} | {p95 < Xms / 0 errors} |
```
