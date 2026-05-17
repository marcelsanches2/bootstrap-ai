# Role: QA / Testes

## Sua contribuição
Gera a seção "Testes" do plano, definindo cenários de teste unit, integration, API e E2E com massa determinística.

## Referência
- docs/ai/TESTING_GUIDE.md

## O que incluir
- **Testes unitários**: cenários de caminho feliz para lógica de negócio (input válido → output esperado). Liste funções/módulos a testar.
- **Cenários negativos**: cubra status codes 400, 401, 403, 404, 409, 422 com inputs específicos que causam cada erro.
- **Massa de dados determinística**: defina seeds, factories ou fixtures. Testes não dependem de produção, relógio real sem controle ou rede externa sem mock.
- **Testes de paginação**: quando houver endpoint de lista, teste skip/limit, página vazia, limites.
- **Edge cases**: lista vazia, campo no tamanho máximo, null, undefined, tipos incorretos.
- **Contrato API**: verifique campos e tipos do response. Dados sensíveis (password, token) NÃO aparecem na resposta.
- **Mocks para serviços externos**: defina quais serviços externos são mockados e como.
- **Independência**: testes não dependem de ordem de execução.
- **Estratégia de execução**: comando para rodar (ex.: `vitest`, `vitest --coverage`) e quando (pre-commit, CI).

## Regras
- Caminho feliz sem teste é BLOCKER.
- Contrato API não verificável é BLOCKER.
- Dados sensíveis em response é BLOCKER.
- Testes não podem depender de produção, relógio real sem controle ou rede externa sem mock.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## Testes

### Estratégia
- **Runner**: {vitest/jest}
- **Quando rodar**: {pre-commit / CI / manual}

### Testes unitários
| Módulo | Cenário | Input | Output esperado |
|--------|---------|-------|-----------------|
| {módulo} | caminho feliz | {input} | {output} |
| {módulo} | {cenário negativo} | {input} | {erro esperado} |

### Testes de integração / API
| Endpoint | Método | Cenário | Status esperado | Validação |
|----------|--------|---------|-----------------|-----------|
| {path} | {verbo} | {cenário} | {status} | {o que verificar} |

### Edge cases
- {edge case 1}: {comportamento esperado}
- {edge case 2}: {comportamento esperado}

### Massa de dados
- {seed/factory/fixture}: {descrição}

### Mocks
| Serviço | Ferramenta | Comportamento mockado |
|---------|-----------|----------------------|
| {serviço} | {ferramenta} | {comportamento} |

### Dados sensíveis
- Campos que NÃO devem aparecer em response: {lista}
```
