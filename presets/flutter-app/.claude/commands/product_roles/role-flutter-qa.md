# Role: QA Flutter

## Your contribution

Generates the "Tests" section of the plan, defining unit tests, widget tests, integration tests, pipeline and Gherkin scenarios.

## Reference

- docs/ai/CODING_STANDARDS.md
- docs/ai/FEATURE_GUIDE.md

## What to include

- **Unit tests** — for each layer:
  - **Business rule / use case**: test domain logic with mock repository. Cover success and failure cases.
  - **Repository**: test mapping between DTO and entity, datasource calls, error handling.
  - **Datasource**: test response parsing, status code handling, timeout and connection.
- **Widget tests** — test each new or altered widget: correct rendering, interaction (tap, scroll, input), visual states (loading, error, empty), and Semantics verification.
- **Integration tests** — test the complete feature flow end-to-end with `integration_test`. Include deterministic environment setup (mock/fake datasource, data seed).
- **Pipeline** — define commands that must pass:
  - `flutter test` — all unit and widget tests
  - `flutter analyze` — zero warnings
  - Golden tests — when applicable (visual components with deterministic state)
- **Gherkin scenarios** — write E2E scenarios in Gherkin format for happy path and negative scenarios. Each scenario must be deterministic and not depend on external environment.

## Rules

- Every feature that depends on API or integration must have mock/fake/deterministic test data. No exceptions.
- Gherkin scenarios must be self-contained: the "Given" step prepares all necessary state.
- Widget tests must use `Key` on critical widgets for stability.
- No test depends on real backend, real user or production data.
- Golden tests only when the component has a stable and deterministic layout.
- If the task is purely technical without testable logic (e.g.: config, build): write "Does not apply" and explain why.

## Output format

```md
## Tests

### Unit tests

| Layer | Target | Scenarios | File |
|---|---|---|---|
| Domain / Use case | {UseCaseName} | success, failure, edge cases | test/{feature}/domain/usecases/{name}_test.dart |
| Repository | {RepositoryImplName} | mapping OK, datasource error | test/{feature}/data/repositories/{name}_test.dart |
| Datasource | {DatasourceName} | parsing OK, timeout, status error | test/{feature}/data/datasources/{name}_test.dart |

### Widget tests

| Widget | What it tests | File |
|---|---|---|
| {WidgetName} | renders default state, loading, error, empty | test/{feature}/presentation/widgets/{name}_test.dart |
| {PageName} | navigation, interaction, states | test/{feature}/presentation/pages/{name}_test.dart |

### Integration tests

| Flow | Setup | File |
|---|---|---|
| {flow name} | {data/initial state} | integration_test/{feature}/{name}_test.dart |

### Pipeline

```bash
flutter test
flutter analyze
# Golden tests (if applicable):
flutter test --update-goldens
```

### Gherkin scenarios

#### Happy path

```gherkin
Scenario: {scenario name}
  Given {precondition}
  And {test data/initial state}
  When {user action}
  Then {expected result}
```

#### Negative scenarios

```gherkin
Scenario: {error scenario name}
  Given {precondition}
  And {simulated error condition}
  When {user action}
  Then {expected error behavior}
```

{Repeat for each relevant negative scenario}
```
