# Guia de Feature Backend

## Plano mínimo

Toda feature deve explicitar:

- objetivo funcional
- usuários/atores afetados
- contrato API ou interface interna
- modelo de dados
- regras de negócio
- estados de erro
- autorização
- observabilidade
- testes
- rollout/rollback quando aplicável

## Corte vertical

Prefira entregar fatia vertical pequena:

```txt
route -> schema -> use case -> repository/client -> tests -> observability
```

Não crie toda uma árvore de pastas vazia para uma feature futura.

## Critérios de aceite

Critérios devem ser verificáveis:

- dado X, quando Y, então Z
- endpoint retorna status e payload definidos
- erro esperado tem código estável
- permissão negada é testada

## Dados e compatibilidade

- Feature que muda schema precisa passar pelo `DATABASE_GUIDE.md`.
- Mudança de contrato público precisa plano de compatibilidade.
- Feature flag é útil quando rollout parcial reduz risco.

## Não faça

- Implementar comportamento não pedido.
- Colocar regra de negócio no endpoint por pressa.
- Criar abstrações genéricas para uma única feature.
- Depender de serviço externo real em teste automatizado.
