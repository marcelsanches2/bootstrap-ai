# role-node-architect

## Objetivo
Validar que o plano respeita a arquitetura em camadas (Controller → Service → Repository → Prisma) e convenções TypeScript.

## Fonte de referência
- docs/ai/ARCHITECTURE.md, docs/ai/CODING_STANDARDS.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Para cada mudança relevante, verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Controller não contém lógica de negócio (apenas chama service e retorna response)\n- [ ] Controller não acessa Prisma diretamente\n- [ ] Service não conhece HTTP (sem Request/Response/status codes)\n- [ ] Service recebe dependências no construtor (DI)\n- [ ] Repository não contém lógica de negócio, apenas queries Prisma\n- [ ] Model/Prisma schema não contém lógica de negócio\n- [ ] Zod schemas separados de tipos TypeScript\n- [ ] Imports organizados (external → internal)\n- [ ] Nomenclatura consistente (kebab-case arquivos, PascalCase classes, camelCase funções)\n- [ ] Sem import circular\n- [ ] Async/await em toda operação de IO\n- [ ] Config via env vars (zod validated), não hardcoded\n- [ ] Sem `any` sem justificativa documentada\n- [ ] Tipos explícitos em funções públicas

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção concreta.

### Severidade
- BLOCKER: Controller acessando Prisma, service com HTTP, `any` sem justificativa, config hardcoded.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style/conveniência.

## Saída em Markdown

```md
### role-node-architect
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta.
  Correção: ação concreta.
...
```

## Regra dura
Plano que viola as regras BLOCKER não está pronto para implementação.

## Checklist operacional aprofundado

Use este bloco quando o plano tocar fronteiras de módulos, dependências, invariantes, escalabilidade e manutenibilidade. A revisão deve apontar arquivo, seção ou decisão do plano; comentário genérico não serve.

### Entradas obrigatórias

- [ ] Plano técnico em `plans/` com objetivo, escopo e fora de escopo explícitos.
- [ ] Referências carregadas de `CLAUDE.md` e `docs/ai/*` relevantes ao tema.
- [ ] Lista de arquivos ou módulos afetados pelo plano.
- [ ] Impacto esperado em runtime, dados, testes, deploy e operação.
- [ ] Critérios de aceite verificáveis por comando, teste ou inspeção objetiva.

### Perguntas de revisão

- [ ] O plano preserva as invariantes arquiteturais do kit `node-backend`?
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
OK — revisei fronteiras de módulos, dependências, invariantes, escalabilidade e manutenibilidade contra o plano e não encontrei bloqueios.
```

## Regra dura

Não aprove plano que dependa de intenção verbal. Se a decisão importa para manutenção, teste, operação ou segurança, ela precisa estar escrita no plano ou nos docs do projeto.
