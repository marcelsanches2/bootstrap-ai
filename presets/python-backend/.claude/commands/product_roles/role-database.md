# role-database

## Objetivo
Validar que o plano trata corretamente banco de dados, migrations, queries, índices e integridade dos dados.

## Fonte de referência
- `docs/ai/DATABASE_GUIDE.md`
- `docs/ai/SCALABILITY_GUIDE.md` quando houver volume/concorrência

## Entrada esperada
Plano técnico em `plans/*.md` que menciona dados, tabelas, queries ou migrations.

## Método
Para cada mudança que envolve banco, verificar se migration, índice, query e integridade estão tratados.

## Checklist obrigatório

- [ ] Migration criada com upgrade() E downgrade() completos
- [ ] Índice em toda foreign key
- [ ] Índice em colunas de busca frequente (WHERE, JOIN)
- [ ] Constraint de unicidade onde faz sentido (email, slug, código)
- [ ] Nenhum SELECT * — colunas explícitas
- [ ] Nenhuma query N+1 — eager loading (selectinload/joinedload) quando acessa relacionamento
- [ ] Paginação em queries de lista (offset para <1M, cursor para >1M)
- [ ] Timeout em queries (statement timeout em produção)
- [ ] Transação explícita em operações multi-step (create + update relacionados)
- [ ] Pessimistic lock (with_for_update) em operações concorrentes (saldo, estoque)
- [ ] Tipo correto para colunas (Numeric para dinheiro, String com limite, DateTime com timezone)
- [ ] Não há dado sensível em texto plano (hash de senha, PII criptografado)
- [ ] Seed ou fixture para dados iniciais necessários

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + o que falta + correção concreta.

### Severidade
- BLOCKER: migration sem downgrade, N+1 em endpoint de lista, saldo sem lock, dado sensível em texto plano.
- MAJOR: índice faltando em FK, paginação ausente, tipo incorreto para dinheiro.
- MINOR: seed faltando, comment faltando em migration.

## Saída em Markdown

```md
### role-database

- [OK] Migration — upgrade() e downgrade() presentes. ✓
- [PENDÊNCIA BLOCKER] N+1 — GET /api/v1/orders lista items sem eager loading.
  Correção: adicionar .options(selectinload(Order.items)) na query.
- [PENDÊNCIA MAJOR] Índice — FK order_items.order_id sem índice.
  Correção: adicionar op.create_index("ix_order_items_order_id", ...) na migration.
...
```

## Regra dura
Plano que toca banco sem migration com downgrade, ou com N+1 em endpoint de lista, ou com saldo/estoque sem lock, não está pronto.

## Checklist operacional aprofundado

Use este bloco quando o plano tocar modelagem, migrações, índices, transações, rollback e integridade de dados. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

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
OK — revisei modelagem, migrações, índices, transações, rollback e integridade de dados contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
