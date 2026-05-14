# Role: Flutter Architect

## Objetivo

Revisar arquitetura Flutter: camadas (domain → data → presentation), dependências, DTOs, providers/BLoC, rotas e separação de responsabilidades.

## Fonte de referência

Use as referências carregadas por `product_roles/carregar-referencias.md`. Se uma referência necessária estiver ausente, marque pendência em vez de assumir padrão.

## Entrada esperada

- plano localizado
- referências carregadas
- conteúdo do plano
- contexto do projeto quando citado pelo plano

## Checklist obrigatório

### 1. Camadas

Verifique se o plano respeita domain → data → presentation sem pular ou misturar camadas.

Resultado:

- `OK` se cada camada tem responsabilidade clara.
- `OK — não aplicável` se mudança não toca arquitetura.
- `PENDÊNCIA` se lógica de negócio vaza para UI ou datasource.

### 2. Dependências

Verifique injeção de dependências, sem import de implementação concreta fora da factory.

Resultado:

- `OK` se dependências são injetadas.
- `OK — não aplicável` se não há dependência nova.
- `PENDÊNCIA` se camada depende de implementação concreta.

### 3. DTOs e modelos

Verifique separação entre entity (domain) e model (data), com mapeamento explícito.

Resultado:

- `OK` se DTOs estão separados e mapeados.
- `OK — não aplicável` se não há modelo novo.
- `PENDÊNCIA` se entity é usada como model ou conversão é implícita.

### 4. Providers / BLoC / Cubit

Verifique se estado é gerenciado no escopo correto e não vira god-object.

Resultado:

- `OK` se estado tem responsabilidade única.
- `OK — não aplicável` se não há estado novo.
- `PENDÊNCIA` se provider/BLoC acumula responsabilidades.

### 5. Rotas e navegação

Verifique se navegação está explícita e não acoplada à lógica de negócio.

Resultado:

- `OK` se rotas estão claras e desacopladas.
- `OK — não aplicável` se não há rota nova.
- `PENDÊNCIA` se navegação está embutida em widget ou BLoC.

### 6. Testabilidade

Verifique se o plano menciona testes para regra de negócio, usecase, repository, datasource ou fluxo crítico.

Resultado:

- `OK` se testabilidade está prevista.
- `OK — não aplicável` se mudança é visual/declarativa.
- `PENDÊNCIA` se regra de negócio ou integração não menciona teste.

## Saída esperada

```md
## Parecer Role: Flutter Architect

- [OK/PENDÊNCIA] Camadas — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Dependências — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] DTOs e modelos — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Providers / BLoC / Cubit — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Rotas e navegação — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Testabilidade — evidência objetiva e correção sugerida quando pendente.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | evidência do plano | ação concreta |
```

## Regra dura

Não aprove plano que não explicita o item crítico. Ausência de informação relevante é pendência, não aprovação.
