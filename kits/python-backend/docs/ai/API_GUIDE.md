# Guia de API

## Objetivo

APIs devem ter contrato previsível para cliente humano e máquina: rotas nomeadas, schemas explícitos, status codes corretos e erro padronizado.

## Rotas

- Use substantivos no plural para recursos: `/users`, `/orders/{order_id}`.
- Use verbo no path só para ação que não é CRUD natural: `/orders/{id}/cancel`.
- Versione contrato público quando houver risco de quebra: `/v1/<evidência objetiva do plano>`.
- Path params devem ser estáveis e tipados.

## Status codes

- `200`: leitura/ação concluída com corpo.
- `201`: recurso criado, preferencialmente com corpo e/ou `Location`.
- `204`: sucesso sem corpo.
- `400`: input malformado ou regra de request inválida.
- `401`: não autenticado.
- `403`: autenticado sem permissão.
- `404`: recurso inexistente ou invisível para o usuário.
- `409`: conflito de estado/idempotência.
- `422`: validação de schema quando o framework usar esse padrão.
- `500`: erro inesperado, sem detalhe sensível.

## Schemas

- Request e response são modelos separados.
- Não exponha model SQLAlchemy diretamente.
- Campos monetários precisam de semântica clara: centavos int ou Decimal serializado.
- Datas em ISO 8601 com timezone quando representam instante.
- Enum público precisa ter valores documentados.

## Erro padrão

Formato recomendado:

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "Mensagem segura para cliente.",
    "details": {},
    "request_id": "<request_id>"
  }
}
```

## Paginação e filtros

- Coleções que podem crescer precisam de paginação desde o primeiro contrato público.
- Defina limite máximo.
- Ordenação default deve ser determinística.
- Filtros precisam de índice ou justificativa de cardinalidade.

## Compatibilidade

Mudança breaking exige plano de migração: rota nova, feature flag, compat layer ou versionamento.

## Checklist antes de aprovar endpoint

- Contrato request/response explícito.
- Erros esperados mapeados.
- AuthN/AuthZ definidos.
- Teste de sucesso, erro de validação e autorização.
- OpenAPI coerente quando FastAPI estiver em uso.
