# /ship

Final checklist before closing a change.

1. Read the plan in `plans/`.
2. Confirm that `/jarvis-test-flow` was executed or justify why it doesn't apply.
3. Check `git diff --stat` and `git status`.
4. Ensure there are no secrets, sensitive logs, or temporary files.
5. Summarize changed files, executed commands, remaining risks, and next steps.
6. Do not force push.

## Approval Gate

Before concluding, present the summary and ask:

**"Ship approved? Ready to commit/push? (yes/no)"**

- **Yes** → proceed with commit and push.
- **No** → stop, document what's missing, wait for correction.
