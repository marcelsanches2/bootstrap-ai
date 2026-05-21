# Coding Standards

## Objective

Define consistent Dart and Flutter coding patterns. Reduce friction between files. Prevent common mistakes.

---

## General rules

- Use English for names, comments and documentation.
- Use `final` for variables that are not reassigned.
- Use `const` for immutable constructors and widgets.
- Avoid `dynamic`. Prefer explicit types or generics.
- One responsibility per class, file and function.
- Maximum of 300 lines per file. If it exceeds, it needs to be split.
- No magic numbers. Extract to named constants.
- No print() in production. Use AppLogger.

---

## Naming

| Element | Convention | Example |
|---|---|---|
| Files and folders | snake_case | `user_repository.dart` |
| Classes | PascalCase | `UserRepository` |
| Functions and variables | camelCase | `getUserProfile()` |
| Constants | camelCase | `const maxRetryCount = 3` |
| Private members | Prefix `_` | `_internalState` |
| Extensions | PascalCase | `ContextExtensions` |
| Mixins | PascalCase | `ReactiveMixin` |

---

## Imports

Organize imports in this order:

```dart
// 1. Dart SDK
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Packages
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';

// 4. Project (absolute)
import 'package:{{PROJECT_NAME}}/core/network/dio_client.dart';

// 5. Relative
import 'user_entity.dart';
```

Do not use relative imports for files outside the same directory. Use absolute imports with the package name.

---

## Widgets

### Order inside a widget

```dart
class MyWidget extends StatelessWidget {
  // 1. Constructor
  const MyWidget({
    super.key,
    required this.title,
    this.subtitle,
  });

  // 2. Final fields
  final String title;
  final String? subtitle;

  // 3. Build
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // 4. Private helpers (if any)
  Widget _buildHeader() => Container();
}
```

### const whenever possible

```dart
// Yes
const AppCard(
  child: Text('Hello'),
)

// No
AppCard(
  child: Text('Hello'),
)
```

### Extract widgets

If a method builds a complex subtree, extract to a private widget:

```dart
// Prefer
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(title);
}
```

---

## Null safety

- Do not use `!` without guarantee. Prefer `?.`, null checks or default values.
- Make optional parameters nullable. Do not use nullable for mandatory fields.
- Do not use `late` as a shortcut. Only when initialization is guaranteed before use.

---

## Error handling

- Convert all external errors (Dio, platform, etc.) to internal types.
- Do not expose raw technical messages to the user.
- Use `try/catch` only where the error is actually handled.
- Prefer result types (Either, ApiResult) for expected failures.

```dart
// Prefer
Future<ApiResult<User>> getUser(String id) async {
  try {
    final response = await dio.get('/users/$id');
    return ApiResult.success(UserModel.fromJson(response.data));
  } on DioException catch (e) {
    return ApiResult.failure(e.toApiException());
  }
}
```

---

## JSON serialization

- Use `json_serializable` for models that need serialization.
- Do not write manual `fromJson`/`toJson` for complex models.
- Keep entities free of serialization logic.

```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String name,
    String? email,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

---

## Dependency injection

- Use Riverpod for DI.
- Do not use `GetIt` or `get_it` unless there is an explicit justification.
- Define providers close to what they provide.
- Do not create global god-providers.

---

## Comments

- Comments explain "why", not "what".
- Code must be self-explanatory.
- TODOs must have context: `// TODO(name): description of what's missing`.

---

## Testing patterns

- One test file per source file: `user_repository_test.dart` for `user_repository.dart`.
- Use descriptive names: `test('should return user when API responds 200', () {...})`.
- Mocks with `mocktail`. Do not create manual mocks for external dependencies.
- Arrange-Act-Assert pattern in every test.

---

## Anti-patterns

- Widget with 500 lines.
- Direct Dio call inside a widget.
- `dynamic` in parameters or returns.
- `print()` left in the code.
- Unjustified `late`.
- `!` without null check.
- Manually maintained JSON mapping for complex models.
- God-class with 10 responsibilities.
- Duplicated logic that "I'll refactor later."
- Unnecessary stateful widget when stateless suffices.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **One responsibility per class, file and function**: no classes mixing UI + logic + network
- **Maximum 300 lines per file**: if it exceeds, it must be split before the task is considered complete
- **No print() in production**: use AppLogger
- **No magic numbers**: extract to named constants
- **No dynamic without explicit justification**: use explicit types or generics
- **Do not use ! without guarantee**: prefer null checks, ?. or default values
- **Do not use late as a shortcut**: only when initialization is guaranteed before use
- **Use json_serializable for complex models**: no manual fromJson/toJson for models with 4+ fields
- **One test file per source file**: each tested file has its corresponding _test.dart
- **Mocks with mocktail**: no manual mocks for external dependencies
