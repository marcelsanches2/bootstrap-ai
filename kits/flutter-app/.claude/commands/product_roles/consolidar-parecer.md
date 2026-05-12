## Objetivo

Consolidar os pareceres de Arquitetura, PM, Designer e QA E2E em uma decisão única.

## Fonte de referência

Use exclusivamente as referências carregadas por:
`product_roles/carregar-referencias.md`


## Entrada

Pareceres dos revisores:

- Arquitetura
- PM
- Designer
- QA E2E Flutter

E o inventário de referências carregadas/ausentes produzido por `product_roles/carregar-referencias.md`.

## Classificação de severidade

Classifique cada pendência como:

### BLOCKER

Impede execução.

Exemplos:

- violação de camadas
- dependência proibida entre camadas
- DTO vazando para camada errada
- feature com API sem mock/fake testável
- tela nova sem rota centralizada quando a rota for exigida pelas referências carregadas
- ausência de fluxo principal
- ausência total de critérios de aceite
- UI sem design system quando há tela relevante
- ausência de referência crítica que impeça validação confiável

### MAJOR

Deve corrigir antes ou durante a execução.

Exemplos:

- empty states ausentes
- error states incompletos
- loading state não definido
- ausência de alguns cenários negativos
- nomes genéricos
- componentização fraca
- acessibilidade esquecida

### MINOR

Pode seguir, mas deve virar ajuste.

Exemplos:

- copy pouco refinada
- métrica/evento não mencionado
- pequena ambiguidade visual
- sugestão de melhoria não bloqueante

## Veredito

### Plano aprovado para execução.

Somente se:

- zero BLOCKER
- zero MAJOR relevante
- apenas MINOR aceitável ou nenhuma pendência

### Plano aprovado com ajustes obrigatórios antes da execução.

Use se:

- não há violação estrutural grave
- existem MAJOR corrigíveis
- nenhum BLOCKER crítico

### Plano reprovado. Corrigir arquitetura antes de executar.

Use se houver:

- qualquer BLOCKER estrutural
- plano sem comportamento suficiente
- feature não testável
- arquitetura acoplada ou ambígua demais

## Saída esperada

```md
## Consolidação

### Pendências bloqueantes

- ...

### Pendências maiores

- ...

### Pendências menores

- ...

### Decisão

`<veredito>`

### Próximas ações obrigatórias

1. ...
2. ...
3. ...
```

## Regra

Não deixe parecer contraditório passar.

Se um papel aprova, mas outro mostra que a feature não é testável, o plano não está pronto.

## Interação para MAJOR

A consolidação pode conter pendências MAJOR. Se houver:
- A skill pai (`jarvis-revisor.md`) conduzirá uma etapa interativa para sanar cada MAJOR com o usuário.
- Durante essa etapa, o veredito provisório pode ser `Plano aprovado com ajustes obrigatórios antes da execução.`
- Só após todas as MAJOR sanadas o veredito final pode evoluir para aprovação plena (se zero MINOR críticas restarem).