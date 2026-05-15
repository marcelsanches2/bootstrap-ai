# Padrões de Código Flutter/Dart

## Princípios

O código deve ser:

- simples
- explícito
- legível
- testável
- modular
- incremental
- fácil de refatorar

Não criar abstrações desnecessárias.

Não antecipar problemas que ainda não existem.

---

## Nomeação

Use nomes claros e específicos.

Bom:

```dart
GetUserUseCase
UserRepository
ItemDto
AuthController
```

Ruim:

```dart
Manager
Helper
ServiceHelper
DataHandler
Thing
Utils
```

Evite nomes genéricos.

---

## Arquivos

Evite arquivos muito grandes.

Como regra prática:

- widgets pequenos
- controllers focados
- usecases objetivos
- repositories sem regra de UI
- datasources sem regra de domínio

---

## Widgets

Widgets devem:

- renderizar UI
- receber dados
- emitir eventos
- delegar ações para controllers/providers

Widgets não devem:

- chamar API
- montar regra de negócio
- converter DTO
- acessar datasource
- conter lógica complexa de estado

---

## Controllers

Controllers devem:

- controlar estado de tela
- chamar usecases
- tratar loading/error/success
- expor estado para a UI

Controllers não devem:

- usar Dio diretamente
- acessar datasource diretamente
- conhecer detalhes de API
- conter regra de domínio pesada

---

## Usecases

Usecases devem:

- representar uma ação clara
- ter entrada e saída objetivas
- conversar com repositories
- conter regra de aplicação quando necessário

Exemplo:

```dart
class GetItemsUseCase {
  final ItemRepository repository;

  GetItemsUseCase(this.repository);

  Future<List<Item>> call({required String categoryId}) {
    return repository.getItems(categoryId: categoryId);
  }
}
```

---

## Repositories

Interfaces ficam no domain.

Implementações ficam no data.

Exemplo:

```txt
domain/repositories/item_repository.dart
data/repositories/item_repository_impl.dart
```

---

## DTOs

DTOs ficam apenas em:

```txt
data/dtos/
```

DTOs devem ser convertidos para entidades antes de sair da camada data.

A UI nunca deve receber DTO.

---

## Erros

Erros externos devem ser convertidos para estruturas internas:

- ApiException
- Failure
- ApiResult

Não deixar exceções técnicas vazarem para a UI sem tratamento.

---

## Freezed e JSON

Use Freezed e json_serializable quando houver modelos reais.

Não criar modelos Freezed vazios apenas para preencher estrutura.

Ao alterar modelos gerados, rodar:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Dependências

Antes de adicionar dependência:

1. Verifique se já existe alternativa no projeto.
2. Avalie se é realmente necessária.
3. Justifique no resumo final.

Não adicionar dependência por conveniência pequena.

---

## Comentários

Comente apenas quando o código não for autoexplicativo.

Não usar comentários para explicar código ruim.

Melhore o código primeiro.

---

## Proibições

Não fazer:

- arquivos gigantes
- métodos longos
- providers globais demais
- lógica duplicada
- strings mágicas espalhadas
- imports relativos confusos
- dependência circular
- regra de negócio em widgets
