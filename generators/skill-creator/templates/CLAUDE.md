# CLAUDE.md

Main contract for Claude Code in the {{PROJECT_NAME}} project.

## Project

{{PROJECT_NAME}} is {{PROJECT_DESCRIPTION}}.

Main stack:

{{STACK_LIST}}

## On-demand reading

Files in `docs/ai/` should be read according to the task type. Do not read all automatically — only load the relevant ones.

| Task type | Document(s) to read |
|---|---|
{{READING_TABLE}}

If there is a conflict between documents, the priority order is:

{{PRIORITY_ORDER}}

## Documentation in the plan

In the initial plan for any task, explicitly state which documents from `docs/ai/` were read before implementing. This ensures traceability and alignment.

## Current priority

The project is in the technical foundation phase.

Priority:

{{PRIORITY_LIST}}

Do not implement features, flows, or final visuals without an explicit request.

## Mandatory rules

{{RULES_LIST}}

## Process

Before making changes:

1. inspect the current structure
2. read the relevant `docs/ai/` documents for the task (per the on-demand reading table)
3. understand the task scope
4. briefly describe the plan
5. implement incrementally

After making changes:

{{AFTER_CHANGE_STEPS}}

## Decision principle

Prefer:

- simple over clever
- explicit over magic
- incremental over large rewrites
- stable architecture over false speed
- placeholders over scattered fake logic

When in doubt about product decisions, do not make assumptions. Flag the pending decision.
