# Testing Guide

## Objective

Define the testing strategy for the Flutter app. Ensure each feature can be validated in isolation and in integration.

---

## Testing pyramid

The project follows a testing pyramid:

```
         /  E2E  \
        /  Integration  \
       /  Widget Tests  \
      /   Unit Tests     \
     /___________________\
```

Priority:

1. Unit tests
2. Widget tests
3. Integration tests

---

## Unit tests

### What to test

- Use cases (application layer)
- Repository implementations (data layer)
- Datasources (data layer)
- Domain rules
- Mappers (DTO ↔ Entity)
- Utility functions

### Patterns

```dart
// Name convention
test('should return user when repository responds successfully', () async {
  // Arrange
  final mockRepository = MockUserRepository();
  final usecase = GetUserUseCase(mockRepository);
  const userId = '123';

  // Act
  final result = await usecase(userId);

  // Assert
  expect(result, isA<Success<User>>());
  verify(() => mockRepository.getUser(userId)).called(1);
});
```

### Rules

- One test file per source file.
- File in the same path as the source, within `test/`.
- Example: `lib/features/auth/domain/usecases/login_usecase.dart`
- Test: `test/features/auth/domain/usecases/login_usecase_test.dart`
- Use `mocktail` for mocks.
- Do not mock what is not used.
- Each test must be independent. No shared mutable state.

---

## Widget tests

### What to test

- Custom widgets
- Pages/Screen
- Visual states (loading, error, empty, success)
- User interaction (tap, scroll, input)
- Navigation

### Patterns

```dart
testWidgets('should show loading indicator while fetching data',
    (tester) async {
  // Arrange
  final container = ProviderContainer(overrides: [
    userProvider.overrideWith((ref) => Future.value()),
  ]);

  // Act
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: UserPage()),
    ),
  );

  // Assert
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### Rules

- Use `Key` in widgets that need to be found in tests.
- Do not depend on network or real backend.
- Use provider overrides to inject mocks.
- Test all visual states of the component.
- Do not test internal implementation details of Flutter widgets.

---

## Integration tests

### What to test

- Complete user flows
- Navigation between screens
- State management in real scenario
- Integration between layers

### Patterns

```dart
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete login flow', (tester) async {
    // Arrange
    await tester.pumpWidget(const MyApp());

    // Act
    await tester.enterText(find.byKey(const Key('email_field')), 'test@email.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'password123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(HomePage), findsOneWidget);
  });
}
```

### Rules

- Use `package:integration_test`.
- Do not depend on real backend. Use deterministic mocks.
- Each test must be self-contained.
- Do not use `Future.delayed` to "wait" for something. Use `pumpAndSettle` or `pump`.

---

## Golden tests

### When to use

- Components with stable and deterministic visual layout.
- Design system components.
- Do not use for complex pages that change frequently.

---

## Test commands

```bash
# All unit and widget tests
flutter test

# Specific test
flutter test test/features/auth/domain/usecases/login_usecase_test.dart

# Integration test
flutter test integration_test/app_test.dart

# Coverage
flutter test --coverage
```

---

## Coverage

- Minimum coverage target: 80% for the application and domain layers.
- Coverage does not need to be 100%, but critical paths must be covered.
- Do not write tests just to inflate numbers.

---

## Anti-patterns

- Test that depends on real backend.
- `Future.delayed` in test.
- Shared mutable state between tests.
- Test that tests implementation detail instead of behavior.
- Test that is not deterministic.
- Ignoring failing test to "fix later."

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Every use case must have at least a success and a failure test**: unit tests are mandatory for the application layer
- **Every custom widget must have a widget test**: visual components must be tested
- **Do not depend on real backend in tests**: all tests must be deterministic with mocks/fakes
- **Do not use Future.delayed in tests**: use pump, pumpAndSettle or proper async mechanisms
- **Each test must be independent**: no shared mutable state between tests
- **One test file per source file**: each tested file has its corresponding _test.dart
- **Integration tests must use package:integration_test**: do not use frameworks outside the standard
