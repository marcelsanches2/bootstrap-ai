# Role: QA de API

## Sua contribuição
Gera a seção "Testes" do plano, detalhando cenários de teste unitário, integração, API e E2E com massa de dados determinística.

## Referência
- docs/ai/TESTING_GUIDE.md
- docs/ai/API_GUIDE.md

## O que incluir
- **Estratégia de teste**: quais tipos de teste se aplicam (unit, integration, API, E2E) e por quê.
- **Testes unitários**: funções/methods de service e lógica de domínio. Listar cenários com input → output esperado.
- **Testes de integração**: fluxos que envolvem banco, DI, múltiplas camadas. Usar banco de teste (SQLite ou PostgreSQL de teste) com transação rollback.
- **Testes de API**: para cada endpoint, caminho feliz com contrato completo (status code, body de request, body de response). Verificar tipos e campos.
- **Cenários negativos**: para cada endpoint, listar cenários de erro — 400 (input inválido), 401 (não autenticado), 403 (sem permissão), 404 (não encontrado), 409 (conflito), 422 (validação Pydantic).
- **Edge cases**: lista vazia, único item, campo no limite máximo, unicode, null em campo opcional.
- **Paginação**: testar primeira página, última página, beyond total, limites de skip/limit.
- **Massa de dados determinística**: factories, fixtures, seeds. Sem depender de produção, relógio real ou rede externa.
- **Dados sensíveis**: verificar que password_hash, tokens e PII NÃO aparecem em responses de teste.
- **Mocks externos**: quais serviços externos (email, payment gateway, SMS) precisam ser mockados e como.
- **Independência**: testes não dependem de ordem de execução.

## Regras
- Todo endpoint deve ter teste de caminho feliz + pelo menos um cenário negativo.
- Contrato API deve ser verificado (campos e tipos corretos na response).
- Massa de dados deve ser determinística (factories/fixtures, não produção).
- Testes não podem depender de rede externa sem mock.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## Testes

### Estratégia
| Tipo | Quando usar | Ferramenta |
|------|------------|------------|
| Unitário | Lógica de service/domínio | pytest |
| Integração | Fluxo com banco/DI | pytest + AsyncSession de teste |
| API | Contrato de endpoint | pytest + httpx TestClient |
| E2E | Fluxo completo跨camadas | pytest + TestClient |

### Testes por endpoint

#### POST /api/v1/{resource}
**Caminho feliz:**
- Input: `{body exemplo}`
- Esperado: status 201, response com `{campos esperados}`

**Cenários negativos:**
| Cenário | Input | Status esperado | Detalhe |
|---------|-------|----------------|---------|
| Input inválido | {body} | 422 | {campo inválido} |
| Não autenticado | sem header | 401 | — |
| Conflito | {body} | 409 | {motivo} |

**Edge cases:**
- {Edge case 1}: {resultado esperado}

#### GET /api/v1/{resource}
**Paginação:**
- skip=0, limit=10 → primeira página
- skip=100, limit=10 com 50 total → lista vazia
- skip=-1 → 422

{... repetir para cada endpoint}

### Massa de dados
- `{fixture/factory}`: {o que gera}
- `{fixture/factory}`: {o que gera}

### Mocks externos
| Serviço | Mock | Quando |
|---------|------|--------|
| {serviço} | {como mockar} | {qual teste} |

### Verificações de segurança
- Password_hash não aparece em nenhuma response
- Token não é exposto em body de response
```
