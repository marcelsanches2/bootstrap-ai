# ARCHITECTURE.md

Este documento define a arquitetura técnica do app {{PROJECT_NAME}}.

---

## Stack

O projeto utiliza:

- Flutter
- Dart
- Riverpod
- GoRouter
- Dio
- Freezed
- json_serializable

A arquitetura segue uma abordagem:

- feature-first
- clean architecture pragmática
- baixa complexidade inicial
- preparada para escalar

---

## Estrutura base

A estrutura principal deve seguir este formato:

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

    location/
      location_service.dart
      location_permission_status.dart

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
    auth/
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

    home/
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

    map/
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

    battle/
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

    ranking/
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

    profile/
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

## Camadas

Cada feature pode ter as seguintes camadas:

```txt
presentation
application
domain
data
```

Nem toda feature precisa ter todas as camadas desde o início.

Não crie arquivos vazios sem necessidade.

---

## Presentation

Responsável por:

- pages
- widgets
- controllers
- estado de tela
- interação com o usuário

Não pode conter:

- chamada direta a API
- uso direto de Dio
- parsing de DTO
- regra de negócio complexa
- acesso direto a datasource

A presentation conversa com controllers/providers/usecases.

---

## Application

Responsável por:

- orquestrar casos de uso
- coordenar chamadas de repositórios
- aplicar regras de aplicação
- preparar dados para a camada de presentation

Use esta camada para casos de uso como:

- LoginUseCase
- GetNearbyBattleAreasUseCase
- StartRunSessionUseCase
- FinishRunSessionUseCase
- GetRankingUseCase

---

## Domain

Responsável por:

- entidades
- value objects
- contratos de repositórios
- regras centrais de domínio

Exemplos:

```txt
domain/
  entities/
  repositories/
```

Repositórios devem ser interfaces no domínio.

A camada de domínio não deve depender de Flutter, Dio ou detalhes externos.

---

## Data

Responsável por:

- implementações de repositórios
- datasources
- DTOs
- chamadas HTTP
- mapeamento de dados externos para entidades de domínio

DTOs não podem vazar para fora da camada data.

---

## Regra de dependência

As dependências devem seguir esta direção:

```txt
presentation -> application -> domain
data -> domain
data -> core/network
```

A camada de domínio não depende de data, presentation ou framework.

---

## Riverpod

Riverpod deve ser usado para:

- injeção de dependências
- controllers de tela
- estado assíncrono
- providers globais

Providers globais ficam em:

```txt
lib/app/di/app_providers.dart
```

Providers específicos de feature podem ficar dentro da própria feature quando a feature crescer.

Não concentrar todos os providers do projeto em um único arquivo gigante.

---

## GoRouter

A navegação deve ser centralizada em:

```txt
lib/app/router/app_router.dart
lib/app/router/route_names.dart
```

Pages não devem conhecer strings soltas de rota.

Use constantes ou helpers centralizados.

---

## Dio

Dio deve ser criado centralmente em:

```txt
lib/core/network/dio_client.dart
```

Regras:

- widgets não usam Dio
- controllers não usam Dio diretamente
- usecases não usam Dio diretamente
- datasources podem usar Dio
- repositories coordenam datasources
- erros devem ser convertidos para Failure ou ApiResult

---

## Configuração de ambiente

Ambientes esperados:

```dart
enum Environment {
  dev,
  staging,
  prod,
}
```

Config principal:

```dart
class AppConfig {
  final Environment environment;
  final String baseUrl;
}
```

Não implementar flavors reais antes de ser pedido.

A estrutura deve apenas estar preparada.

---

## Location

A estrutura de localização deve ficar em:

```txt
lib/core/location/
```

Inicialmente criar apenas:

- LocationService abstrato
- LocationPermissionStatus enum

Não implementar GPS real sem tarefa explícita.

---

## Features iniciais esperadas

O projeto deve estar preparado para receber:

- auth
- home
- map
- battle
- ranking
- profile

Mas não deve implementar essas features antes de uma tarefa explícita.

---

## Proibições

Não fazer:

- arquitetura por camada global para tudo
- controllers gigantes
- widgets com regra de negócio
- chamadas HTTP na UI
- DTO sendo usado em page/widget
- strings de rotas espalhadas
- temas hardcoded em várias telas
- dependências não justificadas
- overengineering prematuro
