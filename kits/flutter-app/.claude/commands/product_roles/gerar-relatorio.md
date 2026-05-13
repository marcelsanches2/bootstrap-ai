# Skill filha: gerar-relatorio

## Objetivo

Gerar o relatório final da revisão do plano.

## Fonte de referência

Use exclusivamente o inventário de referências carregadas por:
`product_roles/carregar-referencias.md`


## Entrada

- plano analisado
- inventário de referências carregadas
- inventário de referências ausentes
- parecer de arquitetura
- parecer PM
- parecer designer, quando aplicável
- parecer QA E2E Flutter, quando aplicável
- consolidação de severidade
- veredito

## Formato obrigatório

```md
# Revisão do Plano

Plano analisado: `<arquivo>`

## Referências

Resultado produzido por `product_roles/carregar-referencias.md`:

### Carregadas

- [OK] `<referência carregada>`

### Ausentes

- [PENDÊNCIA] `<referência ausente>` — motivo/impacto

### Adicionais

- [OK] `<referência adicional>` — referência adicional carregada

## Parecer Arquitetura

- [OK/PENDÊNCIA] Camadas — ...
- [OK/PENDÊNCIA] Dependência — ...
- [OK/PENDÊNCIA] DTOs — ...
- [OK/PENDÊNCIA] Nomenclatura — ...
- [OK/PENDÊNCIA] Arquivos vazios — ...
- [OK/PENDÊNCIA] Rota — ...
- [OK/PENDÊNCIA] Providers — ...
- [OK/PENDÊNCIA] Mock — ...
- [OK/PENDÊNCIA] Testes — ...

## Parecer PM

- [OK/PENDÊNCIA] Objetivo da feature — ...
- [OK/PENDÊNCIA] Fluxo principal — ...
- [OK/PENDÊNCIA] Fluxos alternativos — ...
- [OK/PENDÊNCIA] Empty states — ...
- [OK/PENDÊNCIA] Error states — ...
- [OK/PENDÊNCIA] Loading states — ...
- [OK/PENDÊNCIA] Critérios de aceite — ...

## Parecer Designer

- [OK/PENDÊNCIA/OK — não aplicável] Design system — ...
- [OK/PENDÊNCIA/OK — não aplicável] Fidelidade visual — ...
- [OK/PENDÊNCIA/OK — não aplicável] Estados visuais — ...
- [OK/PENDÊNCIA/OK — não aplicável] Acessibilidade — ...
- [OK/PENDÊNCIA/OK — não aplicável] Responsividade — ...
- [OK/PENDÊNCIA/OK — não aplicável] Componentização visual — ...

## Parecer QA E2E Flutter

- [OK/PENDÊNCIA] Testabilidade — ...
- [OK/PENDÊNCIA] Caminho feliz — ...
- [OK/PENDÊNCIA] Cenários negativos — ...
- [OK/PENDÊNCIA] Massa de dados — ...
- [OK/PENDÊNCIA] Automação Flutter — ...

## Cenários E2E sugeridos

Use Gherkin quando aplicável:

Cenário: ...
Dado ...
Quando ...
Então ...

## Pendências consolidadas

### BLOCKER

- ...

### MAJOR

- ...

### MINOR

- ...

## Próximas ações obrigatórias

1. ...
2. ...
3. ...

## Veredito

`<veredito>`
```

## Regras para o veredito

Use exatamente uma das opções definidas pela skill pai.

## Entrega do relatório

Este relatório deve ser apendado no final do arquivo do plano original pela skill pai (`jarvis-plan-revisor.md`), gerando um plano completo (plano + revisão).

Se houver pendências MAJOR sanadas interativamente, registre no relatório final como `MAJOR sanada` com a decisão do usuário.

## Regras

- Não repita uma lista fixa de documentos neste arquivo.
- Apenas renderize o inventário produzido por `product_roles/carregar-referencias.md`.
- Toda pendência deve ter correção sugerida.
- Se algum parecer não foi aplicável, explique por quê.
- Não esconda limitações causadas por referências ausentes.
