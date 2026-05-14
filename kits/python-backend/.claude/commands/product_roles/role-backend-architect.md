# role-backend-architect

## Objetivo
Validar que o plano respeita a arquitetura em camadas (Router → Service → Repository → Model) e as convenções estruturais do Python backend.

## Fonte de referência
- `docs/ai/ARCHITECTURE.md`
- `docs/ai/CODING_STANDARDS.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar se cada mudança proposta respeita separação de camadas, injeção de dependência e convenções de nomenclatura.

## Checklist obrigatório

- [ ] Router não contém lógica de negócio (apenas chama service e retorna response)
- [ ] Router não acessa models ou banco diretamente
- [ ] Service não conhece HTTP (sem Request/Response/status codes)
- [ ] Service recebe dependências no construtor, não via import global
- [ ] Repository não contém lógica de negócio, apenas queries
- [ ] Repository não chama commit/rollback (delegado ao service)
- [ ] Model não contém lógica de negócio
- [ ] Schemas Pydantic separados de models SQLAlchemy
- [ ] Imports seguem ordem: stdlib → third-party → local
- [ ] Nomenclatura consistente (snake_case arquivos/funções, PascalCase classes)
- [ ] Sem import circular (TYPE_CHECKING quando necessário)
- [ ] Async em toda operação de IO (banco, HTTP, arquivo)
- [ ] Config via Settings (pydantic-settings), não hardcoded
- [ ] Dependências injetáveis em dependencies.py

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que viola, em qual arquivo/camada, e correção.

### Severidade
- BLOCKER: pular camada, import circular, sync em async, config hardcoded.
- MAJOR: lógica no lugar errado, nomenclatura inconsistente.
- MINOR: import desordenado, type hint faltando.

## Saída em Markdown

```md
### role-backend-architect

- [OK] Separação de camadas — Service orquestra, Repository faz queries. ✓
- [PENDÊNCIA BLOCKER] Router acessa banco diretamente em POST /api/v1/orders.
  Correção: mover query para OrderRepository e chamar via OrderService.
...
```

## Regra dura
Plano que propõe router acessando banco, service com HTTP, ou model com lógica de negócio não está pronto.

## Checklist operacional aprofundado

Use este bloco quando o plano tocar fronteiras de módulos, dependências, invariantes, escalabilidade e manutenibilidade. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

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
OK — revisei fronteiras de módulos, dependências, invariantes, escalabilidade e manutenibilidade contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
