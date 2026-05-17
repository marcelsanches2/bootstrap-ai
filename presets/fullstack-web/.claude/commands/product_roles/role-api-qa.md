# Role: QA API

## Sua contribuição
Gera a seção "Testes backend" do plano, definindo testes unit, integration e de API para o backend.

## Referência
- docs/ai/TESTING_GUIDE.md

## O que incluir
- **Caminho feliz**: input válido → output esperado. Cada endpoint novo com teste de caminho feliz.
- **Cenários negativos**: 400 (bad request), 401 (unauthorized), 403 (forbidden), 404 (not found), 409 (conflict), 422 (unprocessable). Liste quais se aplicam a cada endpoint.
- **Massa de dados determinística**: seed/factory que garante repetibilidade. Testes independentes, sem ordem.
- **Paginação testada**: quando endpoint tem lista, teste com skip/limit.
- **Edge cases**: lista vazia, campo máximo, null, boundary values.
- **Contrato API verificado**: campos e tipos do response validados.
- **Dados sensíveis**: nenhum dado sensível em response (passwordHash, token).
- **Mocks para serviços externos**: chamadas externas mockadas, sem dependência de rede.

## Regras
- Caminho feliz sem teste é bloqueante.
- Contrato API não verificável é bloqueante.
- Teste que depende de rede externa sem mock é bloqueante.
- Dados sensíveis em response é bloqueante.
- Se a task não envolve backend/API testável: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Testes — Backend

### Caminho feliz
| Endpoint | Input | Output esperado | Arquivo |
|---|---|---|---|
| {VERB /path} | {body/params} | {status + body} | {caminho do teste} |

### Cenários negativos
| Endpoint | Cenário | Status esperado | Arquivo |
|---|---|---|---|
| {VERB /path} | {400/401/403/404/409/422} | {status} | {caminho} |

### Massa de dados
| Dado | Factory/seed | Arquivo |
|---|---|---|
| {entidade} | {como cria} | {caminho} |

### Edge cases
| Caso | Teste | Arquivo |
|---|---|---|
| {lista vazia / campo máximo / null / ...} | {o que verifica} | {caminho} |

### Contrato API
| Endpoint | Campos response | Tipos verificados |
|---|---|---|
| {VERB /path} | {lista de campos} | {sim/não + como} |

### Mocks
| Serviço externo | Estratégia | Arquivo |
|---|---|---|
| {serviço} | {mock/stub} | {caminho} |
```
