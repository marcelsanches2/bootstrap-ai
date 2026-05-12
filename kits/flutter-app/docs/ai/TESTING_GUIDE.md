# TESTING_GUIDE.md

Este documento define os padrões de testes do projeto {{PROJECT_NAME}}.

O objetivo dos testes não é aumentar cobertura artificialmente.  
O objetivo é garantir confiança para evoluir o app sem quebrar fluxos críticos.

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

## Pirâmide de testes

Prioridade esperada:

1. Testes unitários para regra de negócio.
2. Testes de controller/provider para estado de tela.
3. Testes de repository e mapper para conversão e tratamento de erros.
4. Testes de widget quando houver comportamento visual relevante.
5. Testes E2E para fluxos críticos do usuário.

Use E2E com cuidado.  
E2E é mais caro, mais lento e mais frágil. Deve cobrir jornadas críticas, não todos os detalhes do app.

---

## O que deve ser testado

Teste obrigatoriamente quando houver:

- regra de negócio
- usecase relevante
- cálculo
- validação
- permissão
- localização
- autenticação
- ranking
- criação de corrida
- conclusão de corrida
- tratamento de erro
- conversão DTO -> Entity
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
test('returns ranking entries when repository succeeds', () async {});
test('emits error state when get nearby areas fails', () async {});
test('maps RankingEntryDto to RankingEntry entity', () {});