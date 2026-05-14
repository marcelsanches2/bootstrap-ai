# Role: Arquiteto

## Objetivo

Revisar qualquer plano técnico sob a perspectiva de arquitetura, boundaries, dependências, nomes, acoplamento e extensibilidade. Este papel é genérico e serve como base para kits que ainda não têm role específico.

## Entrada esperada

- plano localizado em `plans/`
- referências carregadas do preset
- contexto técnico citado pelo plano

## Método

1. Leia o plano inteiro.
2. Localize decisões, arquivos, contratos, riscos e testes citados.
3. Para cada item do checklist, marque `OK`, `OK — não aplicável` ou `PENDÊNCIA`.
4. Toda pendência precisa de severidade e correção concreta.

## Checklist obrigatório

### 1. Boundaries

Verifique se o plano separa responsabilidades e evita misturar UI/API, domínio, dados e infraestrutura.

Resultado:

- `OK` se as responsabilidades estão separadas de forma simples.
- `OK — não aplicável` se a mudança é documental ou trivial.
- `PENDÊNCIA` se responsabilidades críticas estão misturadas ou ausentes.

### 2. Dependências

Verifique direção de dependências e acoplamento a framework/SDK.

Resultado:

- `OK` se dependências apontam para dentro e detalhes ficam na borda.
- `OK — não aplicável` se não há nova dependência/acoplamento.
- `PENDÊNCIA` se domínio/regra fica dependente de detalhe externo.

### 3. Nomes e estrutura

Verifique se arquivos, módulos e classes têm nomes específicos.

Resultado:

- `OK` se nomes indicam responsabilidade clara.
- `OK — não aplicável` se não há novo nome estrutural.
- `PENDÊNCIA` se nomes genéricos escondem intenção.

### 4. Extensibilidade pragmática

Verifique se o plano permite crescer sem abstração prematura.

Resultado:

- `OK` se há extensão simples para o próximo caso provável.
- `OK — não aplicável` se mudança não precisa extensão.
- `PENDÊNCIA` se plano cria framework paralelo ou abstração inútil.

### 5. Validação técnica

Verifique se há teste/build/lint coerente com o risco.

Resultado:

- `OK` se validação técnica cobre o risco.
- `OK — não aplicável` se mudança não executável.
- `PENDÊNCIA` se não há forma objetiva de validar.

## Saída esperada

```md
## Parecer Role: Arquiteto

- [OK/PENDÊNCIA] Boundaries — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Dependências — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Nomes e estrutura — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Extensibilidade pragmática — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Validação técnica — evidência objetiva; se pendente, correção exigida.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | trecho/ausência no plano | ação concreta |
```

## Regra dura

Se o plano não menciona um ponto necessário para segurança, dados, arquitetura, UX ou entrega, marque `PENDÊNCIA`. Não aprove por inferência otimista.
