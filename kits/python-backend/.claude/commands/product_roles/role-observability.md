# role-observability

## Objetivo
Validar que o plano inclui logging estruturado, métricas, healthcheck e rastreabilidade suficientes para operar em produção.

## Fonte de referência
- `docs/ai/OBSERVABILITY_GUIDE.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar se cada fluxo novo ou alterado tem logging, métricas e healthcheck adequados.

## Checklist obrigatório

- [ ] Eventos de negócio logados com structured logging (structlog)
- [ ] Erros logados com contexto (order_id, user_id, etc.)
- [ ] Nenhum dado sensível nos logs (senha, token, PII)
- [ ] Request ID propagado em todas as chamadas (X-Request-ID)
- [ ] Latência monitorada em endpoints novos (P50, P95, P99)
- [ ] Healthcheck atualizado se nova dependência adicionada (Redis, fila, serviço externo)
- [ ] Métricas de negócio quando aplicável (orders/min, signups/min)
- [ ] Alertas configurados para thresholds críticos (5xx rate, latência, pool)
- [ ] External calls com timeout e log de falha
- [ ] Graceful shutdown tratado para conexões e workers

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + impacto operacional + correção.

### Severidade
- BLOCKER: dado sensível em log, healthcheck faltando com dependência nova.
- MAJOR: evento de negócio sem log, external call sem timeout.
- MINOR: métrica de negócio ausente.

## Saída em Markdown

```md
### role-observability

- [OK] Logging — service usa structlog com user_id e order_id. ✓
- [PENDÊNCIA MAJOR] External call sem timeout — gateway de pagamento.
  Correção: adicionar timeout=30 no httpx.AsyncClient e logar falhas.
...
```

## Regra dura
Plano que adiciona dependência sem healthcheck, ou loga dados sensíveis, ou faz external call sem timeout, não está pronto.

## Checklist operacional aprofundado

Use este bloco quando o plano tocar logs, métricas, traces, alertas, SLOs e diagnóstico de produção. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

### Entradas obrigatórias

- [ ] Plano técnico em `plans/` com objetivo, escopo e fora de escopo explícitos.
- [ ] Referências carregadas de `CLAUDE.md` e `docs/ai/*` relevantes ao tema.
- [ ] Lista de arquivos ou módulos afetados pelo plano.
- [ ] Impacto esperado em runtime, dados, testes, deploy e operação.
- [ ] Critérios de aceite verificáveis por comando, teste ou inspeção objetiva.

### Perguntas de revisão

- [ ] O plano preserva as invariantes arquiteturais do kit `python-backend`?
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
OK — revisei logs, métricas, traces, alertas, SLOs e diagnóstico de produção contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
