# Role: API Designer

## Sua contribuição
Gera a seção "API" do plano, definindo endpoints, contratos HTTP, status codes, schemas, paginação e documentação OpenAPI.

## Referência
- docs/ai/API_GUIDE.md
- docs/ai/ARCHITECTURE.md

## O que incluir
- **Endpoints**: para cada endpoint, defina verbo HTTP, path, descrição e se é público ou protegido.
- **Versionamento**: todos os paths sob `/api/v1/`.
- **Paths**: plural, kebab-case, máximo 2 níveis de nesting.
- **Schemas de request**: Pydantic com tipos explícitos, validação (ranges, tamanhos, regex) e exemplos (`model_config = ConfigDict(json_schema_extra=...)`).
- **Schemas de response**: sem campos sensíveis. Separados de models SQLAlchemy.
- **Status codes**: documente cada status code possível por endpoint (201 para POST, 204 para DELETE, 404/409/422 quando aplicável). Não usar campo booleano `"success"` — o status code já indica.
- **Paginação**: em endpoints de lista, defina query params skip (default 0) e limit (default 20, max 100) com response paginada.
- **Filtros e ordenação**: quando aplicável, documente query params de filtro e sort.
- **Formato de erro**: padronizado — `ErrorDetail` com `code`, `message`, `field` (quando validação).
- **Autenticação/autorização**: especifique para cada endpoint — público, autenticado (`Depends(get_current_user)`), role específica.
- **Rate limiting**: em endpoints sensíveis (login, reset password, registro), especifique limites.
- **Dados sensíveis**: nenhum `password_hash`, token interno ou PII em response.

## Regras
- Todo endpoint precisa de schema de request E response definidos.
- Nenhum dado sensível em response (password_hash, token interno).
- Endpoints protegidos devem especificar auth.
- Erros seguem formato padronizado `ErrorDetail`.
- Nenhum campo `"success"` em response — usar status code.
- Nenhuma lógica de negócio no router.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## API

### Endpoints

#### POST /api/v1/{resource}
- **Descrição**: {o que faz}
- **Auth**: {público / autenticado / role específica}
- **Rate limit**: {quando aplicável}

**Request body:**
```json
{
  "field1": "valor_exemplo",
  "field2": 42
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "field1": "valor",
  "created_at": "2025-01-01T00:00:00Z"
}
```

**Erros:**
| Status | Código | Quando |
|--------|--------|--------|
| 400 | INVALID_INPUT | {condição} |
| 401 | UNAUTHORIZED | Sem token |
| 409 | CONFLICT | {condição} |
| 422 | VALIDATION_ERROR | Campo inválido |

#### GET /api/v1/{resource}
- **Descrição**: {o que faz}
- **Auth**: {público / autenticado}
- **Paginação**: skip=0, limit=20 (max 100)
- **Filtros**: {quando aplicável}
- **Ordenação**: {quando aplicável}

**Response 200:**
```json
{
  "items": [...],
  "total": 42,
  "skip": 0,
  "limit": 20
}
```

{... repetir para cada endpoint}

### Schemas Pydantic
{Liste schemas com campos, tipos, validação e exemplos}

### Formato de erro padronizado
```json
{
  "code": "ERROR_CODE",
  "message": "Descrição legível",
  "field": "campo_com_erro"  // opcional, apenas para 422
}
```
```
