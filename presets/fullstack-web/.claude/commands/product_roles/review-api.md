# Role: API

## Sua contribuição
Gera a seção "API" do plano, definindo endpoints, contratos, status codes, schemas e padrões REST completos.

## Referência
- docs/ai/API_GUIDE.md

## O que incluir
- **Endpoints**: tabela completa com verbo HTTP, path, descrição. Verbo correto (GET leitura, POST criação, PUT/PATCH atualização, DELETE remoção).
- **Paths**: plural, kebab-case, máximo 2 níveis de nesting. Versionamento presente (`/api/v1/`).
- **Request schema**: Zod schema definido com tipos e validação para cada endpoint.
- **Response schema**: tipada, sem campos sensíveis (passwordHash, token), sem campo booleano `success`.
- **Status codes**: corretos por verbo (201 POST, 204 DELETE, 404/409/422). Tabela de erros padronizada (code/message/field).
- **Paginação**: em endpoints de lista (skip/limit ou cursor).
- **Auth**: especificada em endpoints protegidos (middleware, role).
- **Rate limiting**: em endpoints sensíveis (login, reset).
- **Lógica de negócio**: no service, nunca no controller.

## Regras
- Endpoint sem schema de request/response é bloqueante.
- Dados sensíveis em response são bloqueantes.
- Auth faltando em endpoint protegido é bloqueante.
- Sem campo booleano `success` no response.
- Se a task não envolve API nova/alterada: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## API

### Endpoints
| Verbo | Path | Descrição | Auth | Rate limit |
|---|---|---|---|---|
| {VERB} | {/api/v1/path} | {o que faz} | {público/auth/role} | {sim/não} |

### Request schemas
| Endpoint | Schema | Campos obrigatórios | Validações |
|---|---|---|---|
| {VERB /path} | {nome do schema} | {campos} | {regras} |

### Response schemas
| Endpoint | Status | Body |
|---|---|---|
| {VERB /path} | {200/201/...} | {campos e tipos} |

### Paginação
| Endpoint | Método | Parâmetros | Default |
|---|---|---|---|
| {GET /path} | {skip/limit ou cursor} | {params} | {valores} |

### Erros padronizados
| Status | Code | Message | Quando |
|---|---|---|---|
| {400} | {VALIDATION_ERROR} | {mensagem} | {cenário} |
| {401} | {UNAUTHORIZED} | {mensagem} | {cenário} |
| ... | ... | ... | ... |
```
