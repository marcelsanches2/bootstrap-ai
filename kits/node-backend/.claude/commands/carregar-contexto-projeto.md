---
name: carregar-contexto-projeto
description: Carrega automaticamente o contexto do projeto antes de agir. Procura docs em diretorios padrao e detecta skills customizadas.
---

# /carregar-contexto-projeto

Antes de responder, codar, revisar, planejar ou executar qualquer tarefa, carregue o contexto do projeto.

## 1. Procurar documentacao em diretorios padrao

Verifique, em ordem de prioridade, se estes diretorios existem:

```
<raiz>/
  CLAUDE.md                      -> contrato principal do projeto (sempre carregar)
  README.md                      -> contexto geral (fallback)
  docs/
    *.md                         -> documentacao tecnica
    ai/*.md                      -> regras de arquitetura, padroes, design
    architecture/                -> docs de arquitetura
    standards/                   -> padroes de codigo
    design/                      -> design system, tokens
    plans/                       -> planos tecnicos
    reviews/                     -> revisoes e pareceres
    e2e/                         -> relatorios de teste
    reports/                     -> relatorios diversos
  .claude/
    commands/*.md                -> skills customizadas do projeto
    commands/**/*.md             -> skills aninhadas
    scripts/                     -> scripts auxiliares
    settings.json                -> configuracoes compartilhadas
  plans/
    *.md                         -> planos tecnicos
  .github/
    *.md                         -> guias de contribuicao
  config/
    *.md                         -> docs de configuracao
```

## 2. Detectar e carregar

Para cada diretorio encontrado:

- Liste todos os arquivos `.md`.
- Carregue os que parecerem relevantes para a tarefa do usuario.
- Se houver `CLAUDE.md`, carregue por inteiro — ele e a fonte de verdade.
- Se houver `.claude/commands/`, liste todas as skills disponiveis.

## 3. Heuristica de relevancia

A tarefa do usuario envolve... | Carregue priorizando...
---|---
Arquitetura, estrutura, DI, router | `CLAUDE.md`, `docs/ai/ARCHITECTURE*`, `docs/architecture/*`
Codigo, refatoracao, review | `CLAUDE.md`, `docs/ai/CODING*`, `docs/standards/*`
Tela, componente, cor, UI | `CLAUDE.md`, `docs/ai/DESIGN*`, `docs/design/*`
Feature nova, fluxo, comportamento | `CLAUDE.md`, `docs/ai/FEATURE*`, `docs/plans/*`
Teste, E2E, mock, massa | `CLAUDE.md`, `docs/ai/TEST*`, `docs/e2e/*`
Revisar plano | `CLAUDE.md`, `plans/*.md`, `.claude/commands/jarvis-revisor*`
Validar fluxo | `CLAUDE.md`, `docs/e2e/*`, `.claude/commands/test-flow*`
Qualquer outra coisa | `CLAUDE.md`, `README.md`, todos os `.md` em `docs/`

## 4. Respeitar skills customizadas

Se `.claude/commands/` existir:

- Verifique se ha uma skill que se encaixe na tarefa.
- Se houver, use-a em vez de improvisar.
- Reporte: `Skill detectada: <nome>`.

## 5. Reportar contexto

Antes de agir, reporte em uma linha:

```
Contexto: CLAUDE.md + 4 docs + 2 skills | Projeto: <nome-do-repo>
```

Ou:

```
Contexto: nenhum doc encontrado. Agindo sem referencias.
```

## Regras

- Nao invente regra que contrarie um documento carregado.
- Se o usuario pedir algo que viole uma regra do projeto, alerte e peca confirmacao.
- Nao carregue o mesmo arquivo duas vezes na mesma sessao.
- Priorize documentos especificos do projeto sobre conhecimento generico.
