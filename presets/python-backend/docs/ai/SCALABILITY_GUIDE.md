# Scalability and Production Guide

## Objective

This document forces a review of the points that typically break when an application leaves the small environment and starts receiving real load: database, concurrency, queues, cache, latency, throughput, limits and operations.

Scalability here doesn't mean microservices by default. It means knowing where the system will fail first and keeping the plan prepared to diagnose, limit and recover.

## Database

### Queries

Verify:

- filters use indexed columns when volume justifies it
- ordering is deterministic
- pagination doesn't degrade with deep offset when volume is high
- joins have understood cardinality
- N+1 has been avoided
- critical query has test, `EXPLAIN` or justification

### Indexes

An index should exist for:

- frequent lookup by foreign key
- uniqueness that protects a business rule
- critical pagination/ordering
- filters used on a hot endpoint

Do not create indexes by reflex. An index speeds up reads and costs writes, storage and maintenance.

### Data growth

Plans that create or expand tables must answer:

- what is the expected volume in 3, 6 and 12 months?
- is there retention, archiving or cleanup?
- will old queries remain acceptable with 10x data?
- are large fields kept out of hot tables?

## Concurrency and consistency

Check operations with race condition risk:

- read-modify-write
- creation with logical uniqueness
- credit/balance/inventory consumption
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

Rule: if duplicating the request causes a duplicated effect, the plan must address idempotency.

## Pool, connections and limits

In production, a common failure is exhausting a shared resource.

Verify:

- database connection pool has explicit size
- workers/processes don't multiply connections beyond the database limit
- timeouts exist for database, external HTTP and queue
- expensive endpoint has payload limit, pagination or rate limit
- upload/export doesn't load everything into memory
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

- payload doesn't return unnecessary fields
- collection endpoint has pagination and maximum limit
- serialization doesn't dominate cost
- compression makes sense for large responses
- expensive operations don't run in synchronous request unnecessarily
- hot endpoint has p95/p99 latency metric when applicable

## Observability for scale

Scale without observability becomes guessing.

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

- **Mandatory pagination on growing tables**: Never list a growing table without pagination.
- **No `SELECT *` on hot endpoint**: Do not use `SELECT *` on a public endpoint with volume.
- **Deep offset with caution**: Do not use deep offset for large feeds without acknowledging cost; use cursor.
- **Idempotent job with retry**: Never create a non-idempotent job with automatic retry.
- **Timeout on external call**: Never make an external call without explicit timeout.
- **Concurrency with constraint/transaction**: Do not solve concurrency just by "checking before"; use constraint, lock or transaction.
- **Cache with invalidation**: Never use cache without an invalidation strategy.
- **Export without loading everything into memory**: Never load entire dataset into memory for export; use streaming.
- **Critical flow needs scale plan**: Do not accept "we'll scale later" for a flow already in production with load.
- **Duplication causes duplicated effect**: If duplicating a request causes a duplicated effect, the plan must address idempotency.
