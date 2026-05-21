# CLAUDE.md

Main contract for Claude Code in the {{PROJECT_NAME}} project.

## Project

{{PROJECT_NAME}} is a Flutter mobile app.

Main stack:

- Flutter
- Dart
- Riverpod
- GoRouter
- Dio
- Feature-first architecture
- Pragmatic Clean Architecture

## On-demand reading

The files in `docs/ai/` should be read according to the task type. Do not read them all automatically — load only the relevant ones.

| Task type | Document(s) to read |
|---|---|
| Architecture change, folder structure, DI, router, network, config or core | `docs/ai/ARCHITECTURE.md` |
| Visual change, theme, component, screen, color, typography or UI | `docs/ai/DESIGN_SYSTEM.md` |
| Code implementation or refactoring | `docs/ai/CODING_STANDARDS.md` |
| Feature creation or change | `docs/ai/FEATURE_GUIDE.md` |
| Task mixing areas | All relevant documents |

If there is a conflict between documents, the priority order is:

1. `CLAUDE.md`
2. `ARCHITECTURE.md`
3. `CODING_STANDARDS.md`
4. `FEATURE_GUIDE.md`
5. `DESIGN_SYSTEM.md`

## Documentation in the plan

In the initial plan of any task, explicitly state which `docs/ai/` documents were read before implementing. This ensures traceability and alignment.

## Current priority

The project is in the technical foundation phase.

Priority:

1. technical structure
2. feature-first organization
3. layer separation
4. base navigation
5. dependency injection
6. network foundation
7. design system preparation

Do not implement feature, flow or final visual without explicit request.

## Mandatory rules

- Do not mix UI with business logic.
- Do not call Dio in widgets, pages or controllers.
- Do not access datasource outside the data layer.
- Do not leak DTOs to presentation.
- Do not create parallel architecture.
- Do not create large flow without explicit request.
- Do not implement final design in a technical task.
- Do not add dependency without justification.
- Do not overwrite files without inspecting first.
- Do not create large files.
- Do not duplicate logic between features.

## Process

Before changing:

1. inspect the current structure
2. read the `docs/ai/` documents relevant to the task (according to the on-demand reading table)
3. understand the task scope
4. briefly describe the plan
5. implement incrementally

After changing:

1. run `flutter pub get` if `pubspec.yaml` was changed
2. run `flutter analyze`
3. run `flutter test` if tests exist
4. fix introduced errors
5. report created/modified files, executed commands and pending items

## Decision principle

Prefer:

- simple over clever
- explicit over magic
- incremental over large rewrite
- stable architecture over false speed
- placeholders over scattered fake logic

When in doubt about the product, do not invent. Point out the pending decision.
