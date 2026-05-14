# Role: Arquiteto

## Objetivo

Revisar planos sob a perspectiva de arquitetura, boundaries, dependências, nomes, acoplamento e extensibilidade.

## Checklist

### 1. Boundaries

Responsabilidades estão separadas (UI/API, domínio, dados, infra)?

- `OK` — separação clara e simples.
- `OK — não aplicável` — mudança documental ou trivial.
- `PENDÊNCIA` — responsabilidades críticas misturadas ou ausentes.

### 2. Dependências

Direção de dependência aponta para dentro? Domínio não depende de detalhe externo?

- `OK` — dependências apontam para dentro; detalhes na borda.
- `OK — não aplicável` — não há nova dependência/acoplamento.
- `PENDÊNCIA` — domínio/regra dependente de detalhe externo.

### 3. Nomes e estrutura

Arquivos, módulos e classes têm nomes que indicam responsabilidade?

- `OK` — nomes indicam responsabilidade clara.
- `OK — não aplicável` — não há novo nome estrutural.
- `PENDÊNCIA` — nomes genéricos escondem intenção.

### 4. Extensibilidade pragmática

Permite crescer sem abstração prematura?

- `OK` — extensão simples para o próximo caso provável.
- `OK — não aplicável` — mudança não precisa de extensão.
- `PENDÊNCIA` — framework paralelo ou abstração inútil.

### 5. Validação técnica

Há teste/build/lint coerente com o risco?

- `OK` — validação cobre o risco.
- `OK — não aplicável` — mudança não executável.
- `PENDÊNCIA` — sem forma objetiva de validar.
