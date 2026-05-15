# derive-roles.md

Gere os roles de revisão em `.claude/commands/product_roles/` específicos para a stack.

## Input

- **Stack**: `{{DESCRIPTION}}`
- **Nome dO preset**: `{{PRESET_NAME}}`
- **Tipo**: backend / frontend / mobile (inferir pela descrição)

## Referência

Leia os roles dos presets existentes antes de gerar:

- `presets/python-backend/.claude/commands/product_roles/role-*.md` — backend completo
- `presets/react-web/.claude/commands/product_roles/role-*.md` — frontend completo
- `presets/node-backend/.claude/commands/product_roles/role-*.md` — backend Node
- `presets/flutter-app/.claude/commands/product_roles/role-*.md` — mobile Flutter
- `common/roles/` — roles genéricos (copiar diretamente)

## Padrão de nomenclatura

| Tipo | Prefixo | Exemplos |
|---|---|---|
| Pessoa que revisa | `role-` | `role-architect.md`, `role-pm.md`, `role-designer.md`, `role-delivery.md` |
| Pessoa + stack | `role-<stack>-` | `role-flutter-qa.md`, `role-web-qa.md`, `role-api-qa.md` |
| Ótica técnica | `review-` | `review-database.md`, `review-api.md`, `review-security.md` |

Sempre em inglês. Sempre kebab-case. Cada arquivo ~40-50 linhas (objetivo + checklist + regra dura, SEM boilerplate de Entrada/Método/Saída).

## Roles genéricos (copiar de common/roles/, não reescrever)

- `role-architect.md`
- `role-pm.md`
- `role-delivery.md`

## Reviews genéricos (copiar de common/roles/ quando aplicável)

- Backend: `review-api.md`, `review-database.md`, `review-security.md`, `review-observability.md`, `review-scalability.md`
- Frontend: `review-accessibility.md`, `review-performance.md`
- Todos: `review-testing.md`

## Roles específicos (criar para a stack)

Perspectiva de entrega:
- Objetivo: validar que o plano é implementável sem surpresas
- Checklist: escopo claro, dependências, riscos, rollback, deploy
- Regra dura: plano sem rollback ou sem considerar deploy não está pronto

## Roles por tipo de stack

### Backend (gerar TODOS)

#### review-api.md (~80+ linhas)
- Contrato HTTP (verbo, path, payload, response, status codes)
- Validação de input
- Paginação e ordenação
- Versionamento
- Error handling consistente
- Documentação automática

#### role-<stack>-architect.md (~100+ linhas)
- Separação de camadas (router/controller → service → repository/data)
- Injeção de dependência
- Error handling por camada
- Config e env vars
- Tipagem/contratos entre camadas
- Anti-patterns específicos da stack

#### review-database.md (~80+ linhas)
- Migrations (up/down, rollback)
- Índices em colunas de busca
- N+1, SELECT *, query optimization
- Constraints e integridade
- Conexões, pool, timeouts
- Seeds e dados iniciais

#### review-security.md (~80+ linhas)
- Auth e autorização
- Dados sensíveis (PII, secrets, tokens)
- Input validation e sanitização
- Rate limiting
- Headers de segurança
- Logs sem dados sensíveis

#### review-observability.md (~80+ linhas)
- Structured logging
- Métricas (latência, throughput, erro rate)
- Healthcheck endpoints
- Tracing e correlation IDs
- Alertas e thresholds

#### review-scalability.md (~100+ linhas)
- Concorrência e race conditions
- Cache e invalidação
- Filas e jobs (retry, DLQ, backpressure)
- Rate limit, timeout, bulkhead, circuit breaker
- Pool de conexões
- Graceful shutdown

#### review-api-qa.md (~80+ linhas)
- Testabilidade do plano
- Caminho feliz
- Cenários negativos (erro 400, 401, 403, 404, 500)
- Massa de dados determinística
- Contrato API (testes de integração)
- Edge cases

### Frontend (gerar TODOS)

#### role-frontend-architect.md (~100+ linhas)
- Componentização e composição
- Hooks/services para lógica
- Estado (local vs global, escopo)
- Roteamento centralizado
- Error boundaries
- Code splitting e lazy loading

#### role-designer.md (~80+ linhas)
- Design system / tokens
- Fidelidade visual
- Estados visuais (loading, error, empty, disabled)
- Responsividade
- Componentização visual

#### review-accessibility.md (~80+ linhas)
- Semântica HTML
- Navegação por teclado
- Contraste e cores
- Formulários (labels, association, errors)
- ARIA attributes

#### review-performance.md (~80+ linhas)
- Bundle size e code splitting
- Renderização (memo, virtualização, rerenders)
- Imagens e assets
- Cache de dados e invalidação
- Web Vitals

#### role-web-qa.md (~80+ linhas)
- Testabilidade
- Caminho feliz via UI
- Cenários negativos
- Responsividade
- Acessibilidade

### Mobile (gerar TODOS)

#### role-architect.md (~100+ linhas)
- Feature-first + clean architecture
- Separação presentation/domain/data
- DI e providers
- Navegação centralizada
- Mocks e overrides

#### role-designer.md (~80+ linhas)
- Design system / tokens
- Fidelidade visual
- Estados visuais
- Plataformas (iOS/Android)

#### role-qa-e2e-<stack>.md (~80+ linhas)
- Integration test
- Mocks determinísticos
- Caminho feliz
- Cenários negativos
- Massa de dados

## Formato obrigatório de cada role

```md
# role-<nome>

## Objetivo
<1 frase>

## Fonte de referência
- `docs/ai/<GUIDE>.md`

## Entrada esperada
<o que o role precisa receber para revisar>

## Método
<como o role avalia>

## Checklist obrigatório
- [ ] Item 1 — descrição
- [ ] Item 2 — descrição
...

## Resultado esperado por item
Para cada item do checklist:
- **OK**: evidência de conformidade
- **OK — não aplicável**: por que não se aplica
- **PENDÊNCIA (severidade, evidência, correção concreta)**

## Saída em Markdown
<formato do parecer>

## Regra dura
<uma restrição que reprova o plano se violada>
```

## Regras de qualidade

- Cada role deve ter pelo menos 80 linhas.
- Checklist com pelo menos 8 itens.
- Referência a docs/ai específicos, não genéricos.
- Exemplos concretos da stack, não abstrações.
