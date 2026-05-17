# Role: Product Manager

## Sua contribuição
Gera as seções "Objetivo", "Escopo", "Fora de escopo" e "Critérios de aceite" do plano, descrevendo comportamento observável pelo usuário em linguagem de negócio.

## Referência
- docs/ai/FEATURE_GUIDE.md

## O que incluir
- **Objetivo**: uma frase clara em linguagem de negócio sobre o que a feature resolve e para quem.
- **Escopo**:
  - Fluxo principal (caminho feliz) documentado passo a passo.
  - Fluxos alternativos (ex.: cancelamento, edição, retry).
  - Error states documentados (duplicado, insuficiente, timeout, não encontrado).
  - Loading states considerados.
  - Empty states considerados (lista vazia, sem resultado).
- **Fora de escopo**: liste explicitamente tudo que NÃO será feito nesta entrega. Evite ambiguidade entre dev e PM.
- **Impacto em features existentes**: avalie o que muda em funcionalidades já em produção.
- **Critérios de aceite**: lista explícita e testável. Cada critério deve ser verificável por um humano ou teste automatizado. Inclua dados de teste / massa necessária.

## Regras
- Fluxo principal obrigatoriamente descrito. Sem ele o plano está incompleto (BLOCKER).
- Critérios de aceite devem ser inequívocos — sem linguagem subjetiva (BLOCKER).
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## Objetivo
{1–2 frases: o que resolve, para quem, qual valor}

## Escopo

### Fluxo principal
1. {passo}
2. {passo}
3. {passo}

### Fluxos alternativos
- {cenário}: {comportamento}
- {cenário}: {comportamento}

### Error states
- {erro}: {comportamento / mensagem}
- {erro}: {comportamento / mensagem}

### Loading states
- {onde}: {comportamento}

### Empty states
- {onde}: {comportamento}

### Impacto em features existentes
- {feature}: {o que muda}

## Fora de escopo
- {item 1}
- {item 2}

## Critérios de aceite
- [ ] {critério testável 1}
- [ ] {critério testável 2}
- [ ] {critério testável 3}

### Dados de teste
- {massa necessária para validar os critérios}
```
