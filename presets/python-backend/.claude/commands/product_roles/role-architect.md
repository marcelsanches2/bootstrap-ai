# Role: Arquiteto

## Sua contribuição
Gera a seção "Arquitetura proposta" e o "Plano incremental" do plano, definindo camadas, dependências, injeção de dependência, configuração e estrutura de diretórios.

## Referência
- docs/ai/ARCHITECTURE.md

## O que incluir
- **Boundaries**: descreva a separação de responsabilidades entre camadas (API/router, domínio/service, dados/repository, infra). Indique quais responsabilidades ficam em cada camada e por quê.
- **Direção de dependências**: mostre que dependências apontam para dentro (domínio não depende de detalhe externo). Identifique pontos onde isso pode ser violado.
- **Nomes e estrutura**: proponha nomes de arquivos, módulos e classes que indiquem claramente sua responsabilidade. Evite nomes genéricos como `utils.py` ou `helpers.py`.
- **Extensibilidade pragmática**: explique como a solução permite crescer para o próximo caso provável sem abstração prematura. Nenhum framework paralelo nem abstração sem uso real.
- **Validação técnica**: indique quais formas de validação (teste, build, lint) são coerentes com o risco da mudança.
- **Plano incremental**: liste as etapas de implementação em ordem, indicando dependências entre elas. Cada etapa deve ser implementável de forma independente e testável por si só.

## Regras
- Nenhuma camada deve pular outra (ex: router não acessa banco diretamente).
- Domínio nunca importa framework, ORM, HTTP client ou SDK externo.
- Não criar abstração antes de existir pelo menos um uso real.
- Configuração via Settings (pydantic-settings), nunca hardcoded.
- Transações devem ter fronteira explícita.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## Arquitetura proposta

### Camadas
| Camada | Responsabilidade | Exemplos |
|--------|-----------------|----------|
| API/Router | Recebe HTTP, valida borda, chama service, retorna response | routers/*.py |
| Service/Domain | Lógica de negócio, orquestração, transações | services/*.py |
| Repository/Data | Queries, acesso a banco, mapeamento ORM | repositories/*.py |
| Infra | Config, DI, logging, external clients | core/, dependencies.py |
| Models | Definição de tabelas, sem lógica | models/*.py |
| Schemas | Contratos Pydantic (request/response), separados de models | schemas/*.py |

### Dependências (direção)
{Diagrama ou lista textual mostrando que dependências apontam para dentro}

### Injeção de dependência
{Como dependências são injetadas: constructors, FastAPI Depends, factories}

### Configuração
{Quais Settings, env vars, como é carregado}

### Estrutura de diretórios
```
app/
├── core/
├── models/
├── schemas/
├── repositories/
├── services/
├── routers/
└── dependencies.py
```

## Plano incremental

### Etapa 1: {nome}
- **O quê**: {descrição}
- **Arquivos**: {lista}
- **Validação**: {como testar}

### Etapa 2: {nome}
- **Depende de**: Etapa 1
- **O quê**: {descrição}
- **Arquivos**: {lista}
- **Validação**: {como testar}

{... etapas subsequentes}
```
