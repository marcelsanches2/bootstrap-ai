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

Return Markdown only. Be concise; prefer bullets over prose and tables only for real comparisons.

Required section(s):
- `## Scale`

For each section include only: decision, risk, validation. Skip boilerplate.
If the role does not apply, write exactly one sentence: `Does not apply — {reason}`.
Do not duplicate sections owned by another selected role; mention cross-cutting dependencies in one bullet.
