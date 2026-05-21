# Flutter Architecture

## Objective

Organize UI, state, navigation and presentation rules without turning each screen into its own framework.

---

## Stack

The project uses:

- Flutter
- Dart
- Riverpod
- GoRouter
- Dio
- Freezed
- json_serializable

The architecture follows an approach that is:

- feature-first
- pragmatic clean architecture
- low initial complexity
- prepared to scale

---

## Recommended structure

```txt
lib/
  main.dart

  app/
    app.dart
    router/
      app_router.dart
      route_names.dart
    config/
      environment.dart
      app_config.dart
    di/
      app_providers.dart
    theme/
      app_theme.dart
      app_colors.dart
      app_spacing.dart
      app_typography.dart

  core/
    network/
      dio_client.dart
      api_result.dart
      api_exception.dart
    errors/
      failure.dart
    logging/
      app_logger.dart
    constants/
      app_constants.dart

  shared/
    widgets/
      app_scaffold.dart
      loading_view.dart
      error_view.dart
    extensions/
      context_extensions.dart

  features/
    feature_name/
      presentation/
        pages/
        widgets/
        controllers/
      application/
        usecases/
      domain/
        entities/
        repositories/
      data/
        datasources/
        dtos/
        repositories/
```

---

## Layers

Each feature can have the following layers:

```txt
presentation → application → domain
data → domain
```

Not every feature needs to have all layers from the start.

Do not create empty files without need.

### Presentation

Responsible for:

- pages
- widgets
- controllers
- screen state
- user interaction

Must not contain:

- direct API calls
- direct Dio usage
- DTO parsing
- complex business logic
- direct datasource access

Presentation communicates with controllers/providers/usecases.

### Application

Responsible for:

- orchestrating use cases
- coordinating repository calls
- applying application rules
- preparing data for the presentation layer

Use case examples:

- LoginUseCase
- GetItemsUseCase
- SaveItemUseCase
- GetUserProfileUseCase

### Domain

Responsible for:

- entities
- value objects
- repository contracts (interfaces)
- core domain rules

Repositories must be interfaces in the domain.

The domain layer must not depend on Flutter, Dio or external details.

### Data

Responsible for:

- repository implementations
- datasources
- DTOs
- HTTP calls
- mapping external data to domain entities

DTOs must not leak outside the data layer.

---

## Riverpod

Riverpod should be used for:

- dependency injection
- screen controllers
- async state
- global providers

Global providers go in:

```txt
lib/app/di/app_providers.dart
```

Feature-specific providers can stay within the feature itself when the feature grows.

Do not concentrate all project providers in a single giant file.

---

## GoRouter

Navigation must be centralized in:

```txt
lib/app/router/app_router.dart
lib/app/router/route_names.dart
```

Pages must not know loose route strings.

Use constants or centralized helpers.

---

## Dio

Dio must be created centrally in:

```txt
lib/core/network/dio_client.dart
```

Rules:

- widgets do not use Dio
- controllers do not use Dio directly
- use cases do not use Dio directly
- datasources may use Dio
- repositories coordinate datasources
- errors must be converted to Failure or ApiResult

---

## Environment configuration

Expected environments:

```dart
enum Environment {
  dev,
  staging,
  prod,
}
```

Main config:

```dart
class AppConfig {
  final Environment environment;
  final String baseUrl;
}
```

Do not implement real flavors before being requested.

The structure should only be prepared.

---

## Errors

- API errors must become renderable state.
- External errors must be converted to internal structures: ApiException, Failure, ApiResult.
- Technical messages must not leak to the UI without handling.

---

## Anti-patterns

- 500-line component doing fetch, logic, layout and formatting.
- Controller with heavy domain logic.
- DTO being used in page/widget.
- Route strings scattered around.
- Hardcoded themes across multiple screens.
- Unjustified dependencies.
- Premature overengineering.
- Global layer-by-layer architecture for everything.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Presentation does not make direct API/Dio/datasource calls**: the presentation layer must communicate only with controllers/providers/usecases
- **Presentation does not parse DTOs**: DTOs are the exclusive responsibility of the data layer
- **Presentation does not contain complex business logic**: domain rules belong in inner layers
- **Domain does not depend on Flutter, Dio or external details**: the domain layer must be pure Dart
- **DTOs do not leak outside the data layer**: DTOs stay in data/dtos/ and are converted to entities before leaving
- **Widgets do not use Dio**: widgets only render UI and delegate actions
- **Controllers do not use Dio directly**: controllers call use cases, never Dio
- **Use cases do not use Dio directly**: use cases communicate with repositories
- **Errors must be converted to Failure or ApiResult**: external errors must not arrive raw to the application
- **Technical messages must not leak to the UI without handling**: errors must be handled before displaying
- **Do not concentrate all providers in a single file**: separate providers by feature when growing
- **Pages must not know loose route strings**: use constants or centralized helpers
- **Do not create empty files without need**: create only what is necessary for the current task
