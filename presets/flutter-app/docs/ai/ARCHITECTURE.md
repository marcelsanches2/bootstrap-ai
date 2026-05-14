# Arquitetura Flutter

## Objetivo

Organizar UI, estado, navegação e regras de apresentação sem transformar cada tela em framework próprio.

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

## Estrutura recomendada

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

## Camadas

Cada feature pode ter as seguintes camadas:

```txt
presentation → application → domain
data → domain
```

Nem toda feature precisa ter todas as camadas desde o início.

Não crie arquivos vazios sem necessidade.

### Presentation

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

### Application

Responsável por:

- orquestrar casos de uso
- coordenar chamadas de repositórios
- aplicar regras de aplicação
- preparar dados para a camada de presentation

Exemplos de use cases:

- LoginUseCase
- GetItemsUseCase
- SaveItemUseCase
- GetUserProfileUseCase

### Domain

Responsável por:

- entidades
- value objects
- contratos de repositórios (interfaces)
- regras centrais de domínio

Repositórios devem ser interfaces no domínio.

A camada de domínio não deve depender de Flutter, Dio ou detalhes externos.

### Data

Responsável por:

- implementações de repositórios
- datasources
- DTOs
- chamadas HTTP
- mapeamento de dados externos para entidades de domínio

DTOs não podem vazar para fora da camada data.

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

## Erros

- Erro de API deve virar estado renderizável.
- Erro externo deve ser convertido para estruturas internas: ApiException, Failure, ApiResult.
- Mensagem técnica não deve vazar para a UI sem tratamento.

---

## Anti-patterns

- Componente de 500 linhas fazendo fetch, regra, layout e formatação.
- Controller com regra de domínio pesada.
- DTO sendo usado em page/widget.
- Strings de rotas espalhadas.
- Temas hardcoded em várias telas.
- Dependências não justificadas.
- Overengineering prematuro.
- Arquitetura por camada global para tudo.
