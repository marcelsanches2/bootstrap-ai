# Architecture

Estrutura de diretórios e arquitetura do projeto {{PROJECT_NAME}}.

## Visão geral

{{ARCHITECTURE_OVERVIEW}}

## Estrutura de diretórios

```
<raiz>/
{{DIRECTORY_TREE}}
```

## Camadas e responsabilidades

{{LAYERS_DESCRIPTION}}

## Fluxo de dados

{{DATA_FLOW}}

## Injeção de dependência

{{DI_PATTERN}}

## Convenções de nomenclatura

{{NAMING_CONVENTIONS}}

## Anti-patterns

{{ANTI_PATTERNS}}

## Regras duras

- Não pular camadas (ex: presentation não acessa data diretamente).
- Não duplicar lógica entre módulos.
- Não criar arquitetura paralela.
- Não introduzir dependência circular.
- Não vazar detalhes de implementação entre camadas.
