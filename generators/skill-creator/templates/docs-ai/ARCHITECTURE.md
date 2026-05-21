# Architecture

Directory structure and architecture of the {{PROJECT_NAME}} project.

## Overview

{{ARCHITECTURE_OVERVIEW}}

## Directory structure

```
<root>/
{{DIRECTORY_TREE}}
```

## Layers and responsibilities

{{LAYERS_DESCRIPTION}}

## Data flow

{{DATA_FLOW}}

## Dependency injection

{{DI_PATTERN}}

## Naming conventions

{{NAMING_CONVENTIONS}}

## Anti-patterns

{{ANTI_PATTERNS}}

## Hard rules

- Do not skip layers (e.g.: presentation does not access data directly).
- Do not duplicate logic across modules.
- Do not create parallel architecture.
- Do not introduce circular dependencies.
- Do not leak implementation details between layers.
