# Feature Guide

## Objective

Define how to structure, organize and implement features in the Flutter app following feature-first and pragmatic clean architecture.

---

## Feature structure

Each feature follows the structure:

```txt
lib/
  features/
    {feature_name}/
      presentation/
        pages/
          {feature_name}_page.dart
        widgets/
          {feature_name}_widget.dart
        controllers/
          {feature_name}_controller.dart
      application/
        usecases/
          {usecase_name}.dart
      domain/
        entities/
          {entity_name}.dart
        repositories/
          {repository_name}_repository.dart
      data/
        datasources/
          {datasource_name}_datasource.dart
        dtos/
          {dto_name}_dto.dart
        repositories/
          {repository_name}_repository_impl.dart
```

### Example: `auth` feature

```txt
lib/
  features/
    auth/
      presentation/
        pages/
          login_page.dart
          register_page.dart
        widgets/
          login_form.dart
          social_login_buttons.dart
        controllers/
          auth_controller.dart
      application/
        usecases/
          login_usecase.dart
          register_usecase.dart
          logout_usecase.dart
      domain/
        entities/
          user_entity.dart
          auth_token_entity.dart
        repositories/
          auth_repository.dart
      data/
        datasources/
          auth_remote_datasource.dart
        dtos/
          user_dto.dart
          auth_token_dto.dart
        repositories/
          auth_repository_impl.dart
```

---

## Creating a new feature

### Step 1: Define the entity

Start with the domain. Define the entity that represents the core concept.

```dart
// lib/features/{feature}/domain/entities/{entity}.dart
class UserEntity {
  final String id;
  final String name;
  final String email;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

### Step 2: Define the repository contract

Create the interface in the domain layer.

```dart
// lib/features/{feature}/domain/repositories/{feature}_repository.dart
abstract class UserRepository {
  Future<ApiResult<UserEntity>> getUser(String id);
  Future<ApiResult<List<UserEntity>>> getUsers();
  Future<ApiResult<UserEntity>> createUser(CreateUserParams params);
}
```

### Step 3: Define the DTO

Create the data model with serialization.

```dart
// lib/features/{feature}/data/dtos/{entity}_dto.dart
@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String name,
    required String email,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

extension UserDtoX on UserDto {
  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    email: email,
  );
}
```

### Step 4: Implement the datasource

Access to external data (API, local storage, etc.).

```dart
// lib/features/{feature}/data/datasources/{feature}_remote_datasource.dart
class UserRemoteDatasource {
  final DioClient _dioClient;

  UserRemoteDatasource(this._dioClient);

  Future<UserDto> getUser(String id) async {
    final response = await _dioClient.get('/users/$id');
    return UserDto.fromJson(response.data);
  }
}
```

### Step 5: Implement the repository

Connect the datasource with the domain.

```dart
// lib/features/{feature}/data/repositories/{feature}_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource _remoteDatasource;

  UserRepositoryImpl(this._remoteDatasource);

  @override
  Future<ApiResult<UserEntity>> getUser(String id) async {
    try {
      final dto = await _remoteDatasource.getUser(id);
      return ApiResult.success(dto.toEntity());
    } on ApiException catch (e) {
      return ApiResult.failure(e);
    }
  }
}
```

### Step 6: Create the use case

Orchestrate domain logic.

```dart
// lib/features/{feature}/application/usecases/{usecase}.dart
class GetUserUseCase {
  final UserRepository _repository;

  GetUserUseCase(this._repository);

  Future<ApiResult<UserEntity>> call(String id) async {
    return await _repository.getUser(id);
  }
}
```

### Step 7: Create the controller/state

Manage the presentation state.

```dart
// lib/features/{feature}/presentation/controllers/{feature}_controller.dart
@riverpod
class UserController extends _$UserController {
  @override
  Future<ApiResult<UserEntity>> build() {
    return Future.value(const ApiResult<UserEntity>.empty());
  }

  Future<void> loadUser(String id) async {
    state = const AsyncLoading();
    state = AsyncData(await GetUserUseCase(ref.read(userRepositoryProvider))(id));
  }
}
```

### Step 8: Create the page and widgets

Render the UI.

```dart
// lib/features/{feature}/presentation/pages/{feature}_page.dart
class UserPage extends ConsumerWidget {
  const UserPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: userState.when(
        data: (result) => result.when(
          success: (user) => _UserContent(user: user),
          failure: (error) => AppErrorView(message: error.message),
        ),
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorView(message: e.toString()),
      ),
    );
  }
}
```

---

## Dependency flow

```
Page → Controller → UseCase → Repository (interface) → RepositoryImpl → Datasource → Dio
                                                      ↕
                                                     DTO ↔ Entity
```

Rules:

- Page only knows Controller.
- Controller only knows UseCase and state.
- UseCase only knows Repository interface.
- RepositoryImpl knows Datasource and DTO.
- Datasource knows Dio.
- DTO converts to Entity at the repository boundary.

---

## Feature dependencies

Features should not directly depend on other features.

If a feature needs data from another:

1. Create a shared use case in `application/usecases/` of the feature that owns the data.
2. Or extract the shared logic to `core/` or `shared/`.
3. Or use a shared provider.

Do not import `features/B/data/` from `features/A/`.

---

## When to simplify

Not every feature needs all layers.

| Scenario | Minimum needed |
|---|---|
| Static screen with no API | Page + Widgets |
| Simple CRUD | Page + Controller + UseCase + Repository + Datasource |
| Screen with complex state | Page + Controller + UseCase + Repository + Datasource |
| Reusable component | Widget in `shared/widgets/` |

If a feature is very simple, reduce layers. Do not overengineer.

---

## Anti-patterns

- Importing `features/B/data/` from `features/A/`.
- DTO being used in Page or Widget.
- Datasource called directly from Controller.
- Feature with all empty files "for future use."
- Entity with JSON serialization logic.
- Repository interface in the data layer.
- Use case with Dio directly.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Features must not directly depend on other features**: use shared use cases, shared providers or extract to core/
- **DTO must not be used in Page or Widget**: DTOs stay in the data layer and are converted to entities
- **Datasource must not be called directly from Controller**: the flow is Controller → UseCase → Repository
- **Entity must not have JSON serialization logic**: serialization is the DTO's responsibility
- **Repository interface must be in the domain layer**: the contract belongs to domain, not data
- **Use cases must not use Dio directly**: use cases communicate with repositories, never with Dio
- **Do not create empty files "for future use"**: create only what is necessary for the current task
- **Dependency flow must follow: Page → Controller → UseCase → Repository → Datasource**: do not skip layers
