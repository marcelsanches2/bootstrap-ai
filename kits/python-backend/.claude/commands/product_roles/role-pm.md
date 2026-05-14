# role-pm

## Objetivo
Validar que o plano descreve comportamento observável pelo usuário, não só arquitetura técnica.

## Fonte de referência
- `docs/ai/FEATURE_GUIDE.md`
- `docs/ai/API_GUIDE.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar se o plano cobre todos os fluxos que o usuário final experimenta, incluindo estados intermediários e de erro.

## Checklist obrigatório

- [ ] Objetivo claro em linguagem de negócio (não técnica)
- [ ] Fluxo principal documentado (caminho feliz)
- [ ] Fluxos alternativos documentados (ex: login com provider diferente)
- [ ] Error states documentados (ex: email duplicado, saldo insuficiente, timeout)
- [ ] Loading states considerados (ex: processamento de pagamento assíncrono)
- [ ] Empty states considerados (ex: lista vazia de pedidos)
- [ ] Critérios de aceite explícitos e testáveis
- [ ] Não há ambiguidade que gere interpretação diferente entre dev e PM
- [ ] Impacto em features existentes avaliado
- [ ] Dados de teste / massa necessários descritos

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + ambiguidade + correção.

### Severidade
- BLOCKER: fluxo principal não descrito, critério de aceite ambíguo.
- MAJOR: error state não tratado, empty state não considerado.
- MINOR: loading state faltando.

## Saída em Markdown

```md
### role-pm

- [OK] Fluxo principal — usuário cria pedido, vê confirmação com status "pending". ✓
- [PENDÊNCIA MAJOR] Error state — email duplicado não especificado no fluxo de registro.
  Correção: documentar "mostrar erro 'Email já cadastrado' com link para login".
...
```

## Regra dura
Plano que não descreve o comportamento esperado do ponto de vista do usuário, ou com critérios de aceite ambíguos, não está pronto.

## Checklist operacional aprofundado

Use este bloco quando o plano tocar escopo, valor, critérios de aceite, riscos de produto e fatiamento incremental. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

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
OK — revisei escopo, valor, critérios de aceite, riscos de produto e fatiamento incremental contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
