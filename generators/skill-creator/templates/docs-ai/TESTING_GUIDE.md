# Testing Guide

Testing standards for {{PROJECT_NAME}}.

## Framework

{{TEST_FRAMEWORK}}

## Test directory structure

```
{{TEST_DIRECTORY_TREE}}
```

## Naming conventions

- Files: `test_<unit>.py` / `<unit>.test.ts` / `<unit>_test.dart`
- Description: module name + scenario
- Organization: Arrange → Act → Assert

## Test types

{{TEST_TYPES}}

## Fixtures / Factories / Mocks

{{FIXTURES_GUIDE}}

## Coverage

{{COVERAGE_RULES}}

## What to test per layer

{{TEST_PER_LAYER}}

## Anti-patterns

{{TEST_ANTI_PATTERNS}}

## Commands

{{TEST_COMMANDS}}

## Hard rules

- Test behavior, not implementation.
- Do not use random data in deterministic tests.
- Do not call real external services in tests.
- Do not remove assertions to make tests pass.
- Do not leave tests dependent on execution order.
