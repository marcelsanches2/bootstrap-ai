# review-api

## Objetivo
Validar que o plano segue as convenções REST e os contratos HTTP estão completos e consistentes.

## Fonte de referência
- `docs/ai/API_GUIDE.md`
- `docs/ai/ARCHITECTURE.md`

## Entrada esperada
Plano técnico em `plans/*.md` com endpoints documentados.

## Método
Para cada endpoint mencionado no plano, verificar se o contrato está completo e segue as convenções.

## Checklist obrigatório

- [ ] Verbo HTTP correto (GET para leitura, POST para criação, PUT/PATCH para atualização, DELETE para remoção)
- [ ] Path segue convenção (plural, kebab-case, max 2 níveis de nesting)
- [ ] Versionamento presente (/api/v1/)
- [ ] Schema de request definido (Pydantic com tipos, validação e exemplos)
- [ ] Schema de response definido (sem campos sensíveis)
- [ ] Status codes documentados (201 para POST, 204 para DELETE, 404/409/422 quando aplicável)
- [ ] Paginação em endpoints de lista (skip/limit com limites claros)
- [ ] Filtros e ordenação documentados quando aplicável
- [ ] Erro segue formato padronizado (ErrorDetail com code/message/field)
- [ ] Autenticação/autorização especificada (público, autenticado, role específica)
- [ ] Rate limiting especificado para endpoints sensíveis (login, reset password)
- [ ] Não há dados sensíveis em response (password_hash, token interno)
- [ ] Não há campo booleano "success" em response (usar status code)
- [ ] Não há lógica de negócio no router (deve estar em service)

## Resultado esperado por item

Para cada item:
- **OK**: evidência de conformidade (cite o endpoint e a especificação).
- **OK — não aplicável**: explique por que não se aplica a este plano.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta, em qual endpoint, e correção concreta.

### Severidade

- BLOCKER: endpoint sem schema, verbo errado, dados sensíveis expostos, auth faltando em endpoint protegido.
- MAJOR: paginação ausente em lista, status code inconsistente, erro sem formato padrão, rate limiting ausente.
- MINOR: nomenclatura fora de padrão, exemplo ausente no schema.

## Saída em Markdown

```md
### review-api

- [OK] Verbo HTTP — POST /api/v1/orders para criação. ✓
- [OK] Path — /api/v1/orders segue convenção. ✓
- [PENDÊNCIA MAJOR] Paginação — GET /api/v1/orders não documenta skip/limit.
  Correção: adicionar query params skip (default 0) e limit (default 20, max 100).
...
```

## Regra dura
Plano com endpoint sem schema de request E response, ou com dados sensíveis em response, não está pronto para implementação.

## Checklist operacional aprofundado

Use este bloco quando o plano tocar contratos HTTP, serialização, erros, versionamento e compatibilidade de clientes. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

### Entradas obrigatórias

- [ ] Plano técnico em `plans/` com objetivo, escopo e fora de escopo explícitos.
- [ ] Referências carregadas de `CLAUDE.md` e `docs/ai/*` relevantes ao tema.
- [ ] Lista de arquivos ou módulos afetados pelo plano.
- [ ] Impacto esperado em runtime, dados, testes, deploy e operação.
- [ ] Critérios de aceite verificáveis por comando, teste ou inspeção objetiva.

### Perguntas de revisão

- [ ] O plano preserva as invariantes arquiteturais do preset `python-backend`?
- [ ] O desenho evita acoplamento novo desnecessário entre camadas?
- [ ] Existe caminho incremental que reduza risco de mudança grande?
- [ ] As dependências novas são justificadas por necessidade real, não conveniência?
- [ ] A estratégia funciona no stack esperado: Python, FastAPI, Pydantic, SQLAlchemy/Alembic quando presentes?
- [ ] Há tratamento explícito para erro, timeout, retry e estado parcial?
- [ ] O plano descreve como observar falha em produção sem debugger local?
- [ ] O plano define rollback ou mitigação se o deploy quebrar?
- [ ] Migrações, contratos ou flags têm ordem segura de aplicação?
- [ ] A mudança mantém compatibilidade com consumidores existentes?
- [ ] Testes cobrem caminho feliz, bordas e falhas prováveis?
- [ ] Fixtures/mocks são determinísticos e não dependem de rede externa?
- [ ] Secrets, tokens e configuração ficam fora do git?
- [ ] Logs não vazam PII, credenciais, payload sensível ou dados financeiros?
- [ ] A solução mantém simplicidade operacional para alguém debugar às 2h?

### Severidade

- **BLOCKER**: quebra segurança, dados, deploy, contrato público ou impede rollback.
- **MAJOR**: aumenta dívida técnica relevante, fragiliza testes ou cria acoplamento caro.
- **MINOR**: melhoria local que não bloqueia execução segura.
- **NIT**: ajuste textual, nomenclatura ou clareza sem impacto técnico.

### Saída obrigatória

Para cada achado, responda neste formato:

```md
### <SEVERIDADE> — <título curto>

- Evidência: `<arquivo ou seção>`
- Risco: <efeito concreto se ignorar>
- Correção: <mudança específica no plano>
- Validação: `ruff check && mypy/pyright quando configurado && pytest` ou verificação equivalente
```

Se não houver achados, registre explicitamente:

```md
OK — revisei contratos HTTP, serialização, erros, versionamento e compatibilidade de clientes contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
