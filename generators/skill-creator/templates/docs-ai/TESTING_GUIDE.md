# Testing Guide

Padrões de teste para {{PROJECT_NAME}}.

## Framework

{{TEST_FRAMEWORK}}

## Estrutura de diretórios de teste

```
{{TEST_DIRECTORY_TREE}}
```

## Convenções de nomenclatura

- Arquivos: `test_<unit>.py` / `<unit>.test.ts` / `<unit>_test.dart`
- Descreção: nome do módulo + cenário
- Organização: Arrange → Act → Assert

## Tipos de teste

{{TEST_TYPES}}

## Fixtures / Factories / Mocks

{{FIXTURES_GUIDE}}

## Cobertura

{{COVERAGE_RULES}}

## O que testar por camada

{{TEST_PER_LAYER}}

## Anti-patterns

{{TEST_ANTI_PATTERNS}}

## Comandos

{{TEST_COMMANDS}}

## Regras duras

- Não teste implementação, teste comportamento.
- Não use dados aleatórios em testes determinísticos.
- Não chame serviços externos reais em teste.
- Não remova assertion para fazer teste passar.
- Não deixe teste dependente de ordem de execução.
