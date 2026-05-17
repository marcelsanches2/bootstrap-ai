# Role: Flutter Architect

## Sua contribuição

Gera a seção "Arquitetura proposta" e o "Plano incremental" do plano, definindo camadas, dependências, DTOs, estado, rotas e estrutura de arquivos.

## Referência

- docs/ai/ARCHITECTURE.md
- docs/ai/CODING_STANDARDS.md
- docs/ai/FEATURE_GUIDE.md

## O que incluir

- **Camadas envolvidas** — listar cada camada (domain, data, presentation) tocada pela task e descrever a responsabilidade de cada uma neste contexto específico. Explicar o fluxo de dados entre camadas.
- **Dependências e injeção** — declarar quais dependências são necessárias, como são injetadas (factory, provider, get_it) e onde ficam os bindings. Não importar implementação concreta fora da factory.
- **DTOs e modelos com mapeamento** — listar entities (domain) e models (data), mostrar o mapeamento explícito entre eles. Não usar entity como model nem vice-versa.
- **State management** — definir qual estratégia de estado (Provider, BLoC, Cubit, Riverpod), qual o escopo, e qual a responsabilidade do objeto de estado. Evitar god-objects.
- **Rotas e navegação** — declarar rotas novas ou alteradas, como a navegação é feita (GoRouter), e garantir que navegação não fique acoplada à lógica de negócio.
- **Estrutura de arquivos** — listar os arquivos que serão criados ou modificados, organizados por feature e camada. Seguir convenção feature-first.
- **Plano incremental** — dividir a implementação em passos ordenados, onde cada passo deixa o projeto compilando e testável.

## Regras

- Respeitar o fluxo domain → data → presentation sem pular ou misturar camadas.
- Nenhuma dependência concreta fora da factory de injeção.
- DTOs nunca vazam para presentation; entities nunca são usados como models.
- Cada provider/BLoC/Cubit com responsabilidade única.
- Navegação sempre explícita e desacoplada de widgets e lógica de negócio.
- Cada passo do plano incremental deve ser compilável de forma independente.
- Se a task não toca arquitetura: escreva "Não se aplica" e explique por quê (ex.: mudança puramente visual ou de configuração).

## Formato de saída

```md
## Arquitetura proposta

### Camadas envolvidas

| Camada | Responsabilidade | Arquivos |
|---|---|---|
| domain | {descrição} | {arquivos} |
| data | {descrição} | {arquivos} |
| presentation | {descrição} | {arquivos} |

### Dependências e injeção

- {dependência 1}: injetada via {mecanismo} em {local}
- {dependência 2}: ...

### DTOs e modelos

| Tipo | Nome | Camada | Mapeamento |
|---|---|---|---|
| Entity | {Nome} | domain | — |
| Model | {Nome} | data | {Nome}Entity ↔ {Nome}Model |

### State management

- **Estratégia**: {Provider/BLoC/Cubit/Riverpod}
- **Estado**: {NomeDoEstado} — responsabilidade: {descrição}
- **Escopo**: {global/feature/page}

### Rotas e navegação

| Rota | Destino | Parâmetros |
|---|---|---|
| {/rota} | {Page/Screen} | {params} |

### Estrutura de arquivos

```
lib/
  {feature}/
    domain/
      entities/
        {arquivo}.dart
      repositories/
        {arquivo}.dart
      usecases/
        {arquivo}.dart
    data/
      models/
        {arquivo}.dart
      datasources/
        {arquivo}.dart
      repositories/
        {arquivo}.dart
    presentation/
      pages/
        {arquivo}.dart
      widgets/
        {arquivo}.dart
      {state}/
        {arquivo}.dart
```

## Plano incremental

1. **Passo 1 — {título}**: {descrição}. Arquivos: {lista}. Validação: {como verificar}.
2. **Passo 2 — {título}**: {descrição}. Arquivos: {lista}. Validação: {como verificar}.
3. ...
```
