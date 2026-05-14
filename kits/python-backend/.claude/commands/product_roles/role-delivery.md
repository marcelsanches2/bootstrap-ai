# role-delivery

## Objetivo
Validar que o plano é implementável sem surpresas: escopo claro, dependências mapeadas, rollback definido e deploy considerado.

## Fonte de referência
- `docs/ai/DEPLOYMENT_GUIDE.md`
- `docs/ai/ARCHITECTURE.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Avaliar se o plano pode ser executado sem ambiguidade, com rollback seguro e deploy limpo.

## Checklist obrigatório

- [ ] Escopo claro: o que entra e o que NÃO entra
- [ ] Arquivos listados com caminho completo
- [ ] Dependências externas identificadas (novos pacotes, serviços, APIs)
- [ ] Migration incluída e testada (upgrade + downgrade)
- [ ] Rollback definido: como reverter se der errado
- [ ] Deploy procedure descrita (variáveis novas, ordem de execução)
- [ ] Env vars novas documentadas em .env.example
- [ ] Nenhum breaking change sem versionamento de API
- [ ] Configuração nova documentada (nginx, systemd, docker)
- [ ] Critérios de aceite explícitos (como saber que funcionou)
- [ ] Riscos identificados com mitigações
- [ ] Comunicação necessária (front, mobile, outro time) quando API muda

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + risco de entrega + correção.

### Severidade
- BLOCKER: sem rollback, breaking change sem versionamento, dependência não identificada.
- MAJOR: escopo ambíguo, deploy sem procedure, env var não documentada.
- MINOR: risco sem mitigação.

## Saída em Markdown

```md
### role-delivery

- [OK] Escopo — feature de pedidos com criação e listagem. Fora: cancelamento e webhook. ✓
- [PENDÊNCIA BLOCKER] Rollback — não há procedure para reverter migration em caso de erro.
  Correção: documentar "alembic downgrade -1" + redeploy versão anterior.
...
```

## Regra dura
Plano sem rollback, ou com breaking change sem versionamento, ou com dependência não mapeada, não está pronto para entrega.

## Checklist operacional aprofundado

Use este bloco quando o plano tocar deploy, CI/CD, release, rollback, configuração e operação em produção. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

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
OK — revisei deploy, CI/CD, release, rollback, configuração e operação em produção contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
