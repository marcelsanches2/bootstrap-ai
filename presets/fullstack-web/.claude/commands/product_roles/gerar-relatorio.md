# Skill filha: gerar-relatorio

Gere o relatório final da revisão do plano.

## Formato obrigatório

```md
# Revisão do Plano

Plano analisado: `<arquivo>`
Data: `<YYYY-MM-DD>`

## Referências

- `arquivo` — usado para validar <evidência objetiva do plano>

## Pareceres por papel

### <Papel>

- [OK/PENDÊNCIA] Item — evidência objetiva.

## Pendências consolidadas

| Severidade | Papel | Área | Pendência | Correção exigida |
|---|---|---|---|---|

## Decisão

<um dos vereditos permitidos pelo jarvis-plan-revisor>

## Próximos passos obrigatórios

1. Executar as correções obrigatórias listadas acima antes da implementação.
```

## Qualidade mínima

- Cite arquivos, módulos, endpoints, tabelas ou componentes quando existirem no plano.
- Não produza relatório genérico.
- Se o plano for vago, o relatório deve ser específico sobre o que falta.
