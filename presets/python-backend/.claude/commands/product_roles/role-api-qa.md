# review-api-qa

## Objetivo
Validar que o plano é testável e cobre cenários suficientes de teste (positivos, negativos, edge cases).

## Fonte de referência
- `docs/ai/TESTING_GUIDE.md`
- `docs/ai/API_GUIDE.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Para cada endpoint ou fluxo, inventariar cenários de teste e verificar cobertura.

## Checklist obrigatório

- [ ] Caminho feliz testável (input válido → output esperado)
- [ ] Cenários negativos (400: input inválido, 401: não autenticado, 403: sem permissão, 404: não encontrado, 409: conflito, 422: validação)
- [ ] Massa de dados determinística descrita (factories, fixtures)
- [ ] Paginação testada (primeira página, última página, beyond total, limites)
- [ ] Edge cases identificados (lista vazia, único item, campo máximo, unicode, null)
- [ ] Contrato API testado (response tem campos certos, tipos certos)
- [ ] Dados sensíveis NÃO aparecem em response (password_hash, token)
- [ ] Testes de integração para endpoints críticos
- [ ] Mocks externos especificados (email, payment gateway, SMS)
- [ ] Ordem de execução não importa (testes independentes)

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + cenário faltando + correção.

### Severidade
- BLOCKER: caminho feliz sem teste, contrato API não verificável.
- MAJOR: cenário negativo crítico ausente (auth, conflito), massa não determinística.
- MINOR: edge case faltando.

## Saída em Markdown

```md
### review-api-qa

- [OK] Caminho feliz — POST /api/v1/orders com items válidos retorna 201. ✓
- [PENDÊNCIA MAJOR] Auth — GET /api/v1/orders sem token não testado.
  Correção: adicionar teste esperando 401 sem Authorization header.
- [PENDÊNCIA MAJOR] Conflito — POST /api/v1/orders com item inexistente não testado.
  Correção: adicionar teste com product_id inválido esperando 404 ou 400.
...
```

## Regra dura
Plano com endpoint sem cenário de teste para caminho feliz, ou sem verificar contrato API, não está pronto.

## Checklist operacional aprofundado

Use este bloco quando o plano tocar estratégia de testes, fixtures, regressão, cobertura crítica e validação fim-a-fim. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

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
OK — revisei estratégia de testes, fixtures, regressão, cobertura crítica e validação fim-a-fim contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
