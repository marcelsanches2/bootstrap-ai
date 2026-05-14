# review-database

## Objetivo
Validar banco, migrations, queries, índices e integridade.

## Fonte de referência
- docs/ai/DATABASE_GUIDE.md, docs/ai/SCALABILITY_GUIDE.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Para cada mudança relevante, verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Migration criada e testada (prisma migrate)\n- [ ] Índice em toda foreign key (@@index)\n- [ ] Índice em colunas de busca frequente\n- [ ] Sem SELECT * — sempre select explícito\n- [ ] Sem N+1 — usar include no Prisma\n- [ ] Paginação em queries de lista\n- [ ] Transação ($transaction) em operações multi-step\n- [ ] Interactive transaction para operações concorrentes (saldo, estoque)\n- [ ] Tipos corretos (Decimal para dinheiro, DateTime com timezone)\n- [ ] Sem dado sensível em texto plano\n- [ ] Seed para dados iniciais

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção concreta.

### Severidade
- BLOCKER: Migration sem rollback, N+1 em lista, saldo sem lock, dado sensível texto plano.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style/conveniência.

## Saída em Markdown

```md
### review-database
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta.
  Correção: ação concreta.
...
```

## Regra dura
Plano que viola as regras BLOCKER não está pronto para implementação.

## Checklist operacional aprofundado

Use este bloco quando o plano tocar modelagem, migrações, índices, transações, rollback e integridade de dados. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

### Entradas obrigatórias

- [ ] Plano técnico em `plans/` com objetivo, escopo e fora de escopo explícitos.
- [ ] Referências carregadas de `CLAUDE.md` e `docs/ai/*` relevantes ao tema.
- [ ] Lista de arquivos ou módulos afetados pelo plano.
- [ ] Impacto esperado em runtime, dados, testes, deploy e operação.
- [ ] Critérios de aceite verificáveis por comando, teste ou inspeção objetiva.

### Perguntas de revisão

- [ ] O plano preserva as invariantes arquiteturais do preset `node-backend`?
- [ ] O desenho evita acoplamento novo desnecessário entre camadas?
- [ ] Existe caminho incremental que reduza risco de mudança grande?
- [ ] As dependências novas são justificadas por necessidade real, não conveniência?
- [ ] A estratégia funciona no stack esperado: Node.js, TypeScript, Express/Fastify/Nest quando presentes, Prisma/Drizzle quando presentes?
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
- Validação: `npm run typecheck && npm test && npm run lint quando configurado` ou verificação equivalente
```

Se não houver achados, registre explicitamente:

```md
OK — revisei modelagem, migrações, índices, transações, rollback e integridade de dados contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
