# Guia de Testes Flutter

## Objetivo

Garantir confiança para evoluir o app sem quebrar fluxos críticos.

O objetivo não é aumentar cobertura artificialmente.

---

## Camadas

- Unit: funções, usecases, mappers, regras de domínio.
- Controller/Provider: estado de tela, loading/error/success.
- Repository: conversão e tratamento de erros.
- Widget: comportamento visual relevante.
- Integration/E2E: jornadas críticas do usuário.

Use E2E com cuidado. É mais caro, mais lento e mais frágil. Deve cobrir jornadas críticas, não todos os detalhes do app.

---

## Princípios

Os testes devem ser:

- determinísticos
- rápidos quando unitários
- claros
- legíveis
- independentes
- fáceis de manter
- orientados a comportamento
- conectados a regras reais do produto

Não criar testes frágeis apenas para aumentar cobertura.

Não testar detalhe interno sem valor.

Não depender de produção.

Não depender de ordem de execução.

---

## O que deve ser testado

Teste obrigatoriamente quando houver:

- regra de negócio
- usecase relevante
- cálculo
- validação
- autenticação
- permissão
- tratamento de erro
- conversão DTO → Entity
- repository com datasource
- controller com loading/error/success
- fluxo crítico do usuário

---

## O que não deve ser testado

Evite testar:

- implementação interna irrelevante
- getters simples
- construtores triviais
- widgets puramente visuais sem comportamento
- mocks do próprio mock
- detalhes que mudam com frequência
- texto exato quando a copy ainda não está estabilizada
- snapshot visual frágil sem necessidade

---

## Nomeação dos testes

Use nomes descritivos orientados a comportamento.

Bom:

```dart
test('returns items when repository succeeds', () async {});
test('emits error state when fetch fails', () async {});
test('maps ItemDto to Item entity', () {});
test('controller emits loading then success on fetch', () async {});
```

Ruim:

```dart
test('test1', () {});
test('works', () {});
test('repository', () {});
```

---

## Mocks

- Use mocks determinísticos, sem depender de rede real.
- Não mockar o alvo do teste.
- Prefira `mocktail` ou equivalente para criar mocks.
- Mantenha fixtures simples e reutilizáveis.

---

## Comandos típicos

```bash
flutter test
flutter test test/features/auth/
flutter test --coverage
flutter analyze
```

Use os comandos reais do projeto.

---

## Build e regressão

Mudança grande precisa de build. Teste unitário não substitui build.

```bash
flutter build apk       # Android
flutter build ios       # iOS
flutter build web       # Web quando aplicável
```

---

## Pirâmide de testes

Prioridade:

1. Testes unitários para regra de negócio.
2. Testes de controller/provider para estado de tela.
3. Testes de repository e mapper para conversão e tratamento de erros.
4. Testes de widget quando houver comportamento visual relevante.
5. Testes E2E para fluxos críticos do usuário.
