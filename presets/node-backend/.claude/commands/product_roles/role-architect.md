# Role: Arquiteto

## Sua contribuição
Gera as seções "Arquitetura proposta" e "Plano incremental" do plano, definindo camadas, dependências, DI, configuração e estrutura de diretórios.

## Referência
- docs/ai/ARCHITECTURE.md

## O que incluir
- **Boundaries**: descreva a separação de responsabilidades entre camadas (API/domínio, dados, infra). Indique qual código mora em cada camada e por quê.
- **Direção de dependências**: mostre que dependências apontam para dentro (domínio não depende de detalhes externos como framework, ORM ou SDK).
- **Nomes e estrutura**: proponha nomes de arquivos, módulos e classes que indiquem responsabilidade clara. Use kebab-case para arquivos, PascalCase para classes, camelCase para funções.
- **Extensibilidade pragmática**: garanta que a estrutura permite crescer para o próximo caso provável sem abstração prematura. Nenhum framework paralelo ou abstração inútil.
- **Configuração**: defina como variáveis de ambiente são carregadas e validadas (ex.: Zod schema de env).
- **Validação técnica**: indique quais ferramentas de validação (build, lint, testes) são coerentes com o risco da mudança.
- **Plano incremental**: liste as etapas de implementação em ordem de dependência, cada etapa com escopo claro e resultado verificável.

## Regras
- Domínio nunca importa Express/Fastify/Nest, ORM, fetch/axios ou SDK externo.
- DTO/schema de API não é entidade de domínio.
- Não criar abstração antes de existir pelo menos um uso real.
- Transações devem ter fronteira explícita.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## Arquitetura proposta

### Camadas
| Camada | Responsabilidade | Exemplos de arquivos |
|--------|-----------------|---------------------|
| {camada} | {responsabilidade} | {arquivos} |

### Dependências
{Diagrama ou descrição textual da direção de dependências}

### Configuração
- Variáveis de ambiente: {lista com nomes e validação}
- Como carregar: {método}

### Nomes e estrutura
{Árvore de diretórios proposta com nomes de arquivos}

### Extensibilidade
{Como a estrutura suporta o próximo caso provável}

## Plano incremental

### Etapa 1 — {nome}
- **Escopo**: {o que faz}
- **Arquivos**: {lista}
- **Validação**: {como verificar}

### Etapa 2 — {nome}
- **Escopo**: {o que faz}
- **Arquivos**: {lista}
- **Validação**: {como verificar}

{... mais etapas conforme necessário}
```
