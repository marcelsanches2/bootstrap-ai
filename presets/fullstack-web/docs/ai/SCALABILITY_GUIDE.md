# Scalability and Production Guide

## Objective

This document enforces review of the points that typically break when an application leaves the small environment and starts receiving real load: database, concurrency, queues, cache, latency, throughput, limits, and operations.

Scalability here does not mean microservices by default. It means knowing where the system will fail first and having the plan ready to diagnose, limit, and recover.

## Database

### Queries

Verify:

- filters use indexed columns when volume warrants
- sorting is deterministic
- pagination does not degrade with deep offset when volume is high
- joins have understood cardinality
- N+1 has been avoided
- critical queries have tests, `EXPLAIN`, or justification

### Indexes

An index should exist for:

- frequent lookup by foreign key
- uniqueness that protects a business rule
- critical pagination/sorting
- filters used in hot endpoints

Do not create indexes by reflex. Indexes speed up reads and cost writes, storage, and maintenance.

### Data growth

Plans that create or expand tables must answer:

- what is the expected volume in 3, 6, and 12 months?
- is there retention, archiving, or cleanup?
- will old queries remain acceptable with 10x data?
- are large fields kept out of hot tables?

## Concurrency and consistency

Verify operations with race condition risk:

- read-modify-write
- creation with logical uniqueness
- credit/balance/stock consumption
- redeliverable webhook
- job that can run in parallel
- automatic retry

Possible mitigations:

- unique constraint
- optimistic lock by version
- short pessimistic lock
- well-delimited transaction
- idempotency key
- outbox/inbox pattern
- queue with deduplication

Rule: if duplicating the request causes a duplicated effect, the plan must handle idempotency.

## Pool, connections, and limits

In production, a common failure is exhausting a shared resource.

Verify:

- database connection pool has explicit size
- workers/processes do not multiply connections beyond the database limit
- timeouts exist for database, external HTTP, and queue
- expensive endpoints have payload limits, pagination, or rate limiting
- upload/export does not load everything into memory
- backpressure exists for queue/job when downstream degrades

## Cache

Cache only helps when there is an invalidation strategy.

A plan with cache must define:

- key
- TTL
- scope per user/tenant when applicable
- invalidation
- behavior on cache miss
- stale data risk
- hit/miss metric when relevant

Do not use cache to hide a bad query before understanding the query.

## Queues and jobs

For async processing, verify:

- job is idempotent
- payload is small and versioned
- retry has limit and backoff
- dead-letter or failure state exists
- maximum concurrency is defined
- logs include job id and affected entity
- backlog is monitorable

## External integrations

Every critical external call needs:

- explicit timeout
- retry with backoff when safe
- circuit breaker or controlled degradation when necessary
- clear fallback/error for user/client
- latency and error metric
- timeout/failure test

## API performance

Verify:

- payload does not return unnecessary fields
- collection endpoint has pagination and maximum limit
- serialization does not dominate cost
- compression makes sense for large responses
- expensive operations do not run in synchronous request without necessity
- hot endpoint has p95/p99 latency metric when applicable

## Observability for scale

Scale without observability becomes guesswork.

Minimum for critical flow:

- latency per endpoint/job
- error rate by code/operation
- request/job count
- pool/connections when applicable
- queue backlog
- external dependency time
- logs with request id/job id

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

### Database
- **Growing table without pagination**: listings of growing tables must have mandatory pagination.
- **`SELECT *` in hot endpoint**: use explicit `select` in public endpoints with volume.
- **Deep offset without recognizing cost**: use cursor when volume warrants.
- **Export loading everything into memory**: use streaming or pagination for large exports.

### Concurrency
- **Check-then-act without constraint/transaction**: resolving concurrency only with "check first" is insufficient — use constraint, lock, or transaction.
- **Non-idempotent job with retry**: jobs with retry must be idempotent.
- **Duplication with duplicated effect**: if duplicating the request causes a duplicated effect, the plan must handle idempotency.

### Cache
- **Cache without invalidation**: every cache must have a defined invalidation strategy.
- **Do not use cache to hide a bad query**: understand the query before adding cache.

### Integrations
- **External call without timeout**: every critical external call needs an explicit timeout.

### Planning
- **Plan "we'll scale later" for already-critical flow**: critical flow needs a scale plan at implementation time.
