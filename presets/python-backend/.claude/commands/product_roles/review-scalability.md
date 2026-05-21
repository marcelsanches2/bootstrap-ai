# Role: Scalability Designer

## Your contribution
Generates the "Scale" section of the plan, covering concurrency, queues, cache, connection pool and behavior under load.

## Reference
- docs/ai/SCALABILITY_GUIDE.md
- docs/ai/DATABASE_GUIDE.md
- docs/ai/OBSERVABILITY_GUIDE.md
- docs/ai/DEPLOYMENT_GUIDE.md

## What to include
- **Volume and hot path**: identify endpoints, jobs, queries that may receive high volume. RPS/throughput estimate. Justify if volume is low.
- **Database and queries**: strategy for queries on growing tables — pagination (offset for <1M, cursor for >1M), indexes, N+1, filters, sorting. Cost of critical queries.
- **Concurrency and idempotency**: where there is read-modify-write, retries, webhooks, parallel jobs, duplicate creation. How to mitigate: transaction, constraint, pessimistic lock (`with_for_update`), idempotency key.
- **Limits and backpressure**: maximum payload, pagination with limits, rate limit, connection pool (size, timeout), query timeout, queue with maximum size, memory consumption per request.
- **Cache and invalidation**: if there is cache, define key, TTL, scope (per user/tenant/global), invalidation strategy, stale data handling, hit/miss metrics.
- **Queues and jobs**: job idempotency, retry/backoff policy, dead-letter queue, maximum worker concurrency, backlog monitoring, logging by job_id.
- **External integrations**: timeout, safe retry (do not duplicate effect), graceful degradation, circuit breaker when necessary, latency and error metrics, failure test.
- **Scale observability**: P95/P99 latency, error rate, throughput, pool/connections, queue backlog — all with request/job ID for diagnostics.
- **Performance validation**: concurrent test, query test with volume, benchmark or load smoke test when the feature is critical.

## Rules
- Every growing table needs a pagination strategy.
- Balance/inventory/credit needs pessimistic lock or transactional constraint.
- Every external call needs timeout and safe retry.
- Every connection pool needs defined size and timeout.
- Proposed cache without invalidation is not acceptable.
- Job that can duplicate effect needs idempotency.
- If it does not apply to the task: write "Does not apply" and explain why.

## Output format

```markdown
## Scale

### Volume and hot path
| Endpoint/Job | Estimated RPS | Hot path? | Justification |
|-------------|--------------|-----------|---------------|
| {endpoint} | {n} | yes/no | {reason} |

### Database and queries
| Query | Table (growth) | Strategy | Indexes |
|-------|---------------|----------|---------|
| {listing X} | {table} (~{n}/month) | offset/cursor pagination | {required indexes} |

### Concurrency and idempotency
| Operation | Risk | Mitigation |
|-----------|------|------------|
| {operation} | {read-modify-write / duplicate retry} | {lock / constraint / idempotency key} |

### Limits and backpressure
| Resource | Limit | Configuration |
|----------|-------|---------------|
| Connection pool | {max_connections} | `pool_size={n}, max_overflow={n}` |
| Query timeout | {ms} | `statement_timeout` |
| Maximum payload | {KB/MB} | {middleware/nginx} |
| Pagination | limit max {n} | validation in schema |
| Rate limit | {n}/{period} | {middleware/redis} |
| Queue backlog | {max_size} | {configuration} |

### Cache
| Data | Key | TTL | Scope | Invalidation |
|------|-----|-----|-------|-------------|
| {data} | `{template}` | {seconds} | {global/user} | {event/timeout} |

{If no cache: "No cache needed for this feature — justification: ..."}

### Queues and jobs
| Job | Idempotency | Retry | Backoff | Dead-letter | Max concurrency |
|-----|------------|-------|---------|-------------|----------------|
| {job} | {key} | {max retries} | {expo/random} | {queue} | {workers} |

{If no jobs: "No async processing needed for this feature."}

### External integrations
| Service | Timeout | Retry | Circuit breaker | Metrics | Failure test |
|---------|---------|-------|-----------------|---------|-------------|
| {service} | {ms} | {policy} | {yes/no} | latency, error | {description} |

### Scale observability
| Metric | Alert threshold | How to diagnose |
|--------|----------------|-----------------|
| P95 latency | > {ms} | {log + metric} |
| 5xx error rate | > {n}% | {log + metric} |
| Pool exhausted | > {n}% usage | {pool metric} |
| Queue backlog | > {n} messages | {queue metric} |

### Performance validation
- **Test**: {type — concurrent / query with volume / benchmark / load smoke}
- **Scenario**: {test description}
- **Success criterion**: {expected result}
{If not needed: "Feature has no scale risk — justification: ..."}
```
