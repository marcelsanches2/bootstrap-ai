# role-pm

## Objetivo
Validar que o plano descreve comportamento observável pelo usuário, não só arquitetura.

## Fonte de referência
- docs/ai/FEATURE_GUIDE.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Objetivo claro em linguagem de negócio\n- [ ] Fluxo principal documentado (caminho feliz)\n- [ ] Fluxos alternativos documentados\n- [ ] Error states documentados (duplicado, insuficiente, timeout)\n- [ ] Loading states considerados\n- [ ] Empty states considerados (lista vazia)\n- [ ] Critérios de aceite explícitos e testáveis\n- [ ] Sem ambiguidade entre dev e PM\n- [ ] Impacto em features existentes avaliado\n- [ ] Dados de teste / massa descritos

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção.

### Severidade
- BLOCKER: Fluxo principal não descrito, critério de aceite ambíguo.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style.

## Saída em Markdown

```md
### role-pm
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta. Correção: ação.
```

## Regra dura
Plano que viola BLOCKER não está pronto.

## Checklist operacional aprofundado

Use este bloco quando o plano tocar escopo, valor, critérios de aceite, riscos de produto e fatiamento incremental. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

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
OK — revisei escopo, valor, critérios de aceite, riscos de produto e fatiamento incremental contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
