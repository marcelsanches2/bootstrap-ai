---
description: Validates an E2E flow ensuring deterministic test data, tests, and updated report.
---

# /jarvis-test-flow

Validates an end-to-end flow of {{PROJECT_NAME}}. Optional argument: `flow_id`.

## Generation

This file should be generated using `prompts/derive-jarvis-test-flow.md` based on the specific stack.

## Mandatory structure (to be filled)

```
0. Evaluate task size (LARGE/SMALL)
1. Determine flow_id
2. Inventory test data (fixtures/deterministic mocks)
3. Inventory tests (with cross-ref to jarvis-plan)
4. Execute pipeline (lint → typecheck → test → migration → build → healthcheck)
4a. Diagnosis and correction loop (max 3 attempts)
5. Generate report in docs/test_report_{flow_id}.md
6. Finish
7. Commit (only if PASSED, never --no-verify)
8. Push (never force, ask before rebase)
+ Mandatory restrictions
```

## Minimum expected

- 200+ lines (~9000+ chars)
- Pipeline with real stack commands
- Diagnosis loop with specific causes
- Commit/push with hard rules
