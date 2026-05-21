# /ship

Final checklist before closing out a change.

1. Read the plan in `plans/`.
2. Confirm that `/jarvis-test-flow` was executed or justify why it doesn't apply.
3. Check `git diff --stat` and `git status`.
4. Ensure no secrets, sensitive logs, or temporary files.
5. Summarize altered files, executed commands, remaining risks, and next step.
6. Do not force push.

## Approval Gate

Before concluding, present the summary and ask:

**"Ship approved? Ready to commit/push? (yes/no)"**

- **Yes** → proceed with commit and push.
- **No** → stop, record what's missing, wait for correction.
