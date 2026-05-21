# Scalability and Production Guide

## Objective

This document forces a review of the points that typically break when an application leaves the small-scale environment and starts receiving real load: database, concurrency, queues, cache, latency, throughput, limits, and operations.

Scalability here does not mean microservices by default. It means knowing where the system will fail first and keeping the plan prepared to diagnose, limit, and recover.

## Database

### Queries

Verify:

- filters use indexed columns when volume justifies it
- ordering is deterministic
- pagination does not degrade with deep offset when volume is high
- joins have understood cardinality
- N+1 has been avoided
- critical query has a test, `EXPLAIN`, or justification

### Indexes

An index should exist for:

- frequent lookup by foreign key
- uniqueness that protects a business rule
- critical pagination/ordering
- filters used on a hot endpoint

Do not create indexes by reflex. An index accelerates reads and costs writes, storage, and maintenance.

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

Rule: if duplicating the request causes a duplicate effect, the plan must handle idempotency.

## Pool, connections, and limits

In production, a common failure is exhausting shared resources.

Verify:

- database connection pool has explicit size
- workers/processes do not multiply connections beyond the database limit
- timeouts exist for database, external HTTP, and queues
- expensive endpoints have payload limits, pagination, or rate limits
- upload/export does not load everything into memory
- backpressure exists for queue/job when downstream degrades

## Cache

Cache only helps when there's an invalidation strategy.

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
- retry has a limit and backoff
- dead-letter or failure state exists
- max concurrency is defined
- logs include job id and affected entity
- backlog is monitorable

## External integrations

Every critical external call needs:

- explicit timeout
- retry with backoff when safe
- circuit breaker or controlled degradation when needed
- clear fallback/error for the user/client
- latency and error metrics
- timeout/failure test

## API performance

Verify:

- payload does not return unnecessary fields
- collection endpoint has pagination and max limit
- serialization does not dominate cost
- compression makes sense for large responses
- expensive operations do not run in synchronous request unnecessarily
- hot endpoint has p95/p99 latency metrics when applicable

## Observability for scale

Scale without observability becomes guesswork.

Minimum for critical flows:

- latency per endpoint/job
- error rate by code/operation
- request/job count
- pool/connections when applicable
- queue backlog
- external dependency time
- logs with request id/job id

## Blocking anti-patterns

- Listing a growing table without pagination.
- Doing `SELECT *` on a hot public endpoint.
- Using deep offset for a large feed without acknowledging the cost.
- Creating a non-idempotent job with retry.
- Making an external call without timeout.
- Solving concurrency only by "checking before" without constraint/transaction.
- Cache without invalidation.
- Export loading everything into memory.
- "We'll scale later" plan for a flow that is already critical.

## Blocking rules

Rules extracted from this guide. The plan CANNOT be proposed if it violates any of the rules below.

- **Do not list growing tables without pagination**: Every collection endpoint must have pagination and max limit.
- **Do not do `SELECT *` on hot endpoints**: Use explicit `select` for needed fields.
- **Do not use deep offset without acknowledging cost**: For large feeds, use cursor-based pagination.
- **Do not create non-idempotent jobs with retry**: Jobs with retry must be idempotent.
- **Do not make external calls without timeout**: Every external integration needs an explicit timeout.
- **Do not solve concurrency only with prior check**: Use unique constraint, lock, or transaction.
- **Do not use cache without invalidation**: Cache needs a defined invalidation strategy.
- **Do not load everything into memory in exports**: Use streaming or pagination for large volumes.
- **Do not postpone scale for flows that are already critical**: Plans touching critical flows must address scale, limits, and diagnostics.
- **Do not use cache to hide bad queries**: Understand the query before caching.
- **Idempotency is mandatory if duplicating a request causes a duplicate effect**: Handle idempotency with key, constraint, or deduplication.
