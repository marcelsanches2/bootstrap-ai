# /refactor

Planeja e conduz uma refatoração segura em projeto existente.

Use quando este preset for aplicado em um projeto já em andamento e o objetivo for alinhar o código ao lifecycle, arquitetura, docs `docs/ai/`, roles e padrões do preset.

## Regra principal

Não comece refatorando código. Primeiro inventarie, gere plano, rode revisão e só então execute incrementalmente.

## Sequência obrigatória

### 0. Classificar escopo

- `PEQUENA`: módulo isolado, sem mudança pública de contrato.
- `MÉDIA`: múltiplos arquivos/features, sem alterar arquitetura central.
- `GRANDE`: arquitetura, pastas, DI, banco, API pública ou mudança transversal.

Se for `GRANDE`, divida em fases pequenas.

### 1. Carregar contexto

Leia obrigatoriamente:

- `CLAUDE.md`
- `docs/ai/ARCHITECTURE.md`
- `docs/ai/CODING_STANDARDS.md`
- `docs/ai/TESTING_GUIDE.md`
- demais guias da stack

### 2. Inventário técnico

- Padrões atuais do projeto
- Divergências contra `docs/ai/`
- Dívidas técnicas
- Duplicações
- Violações de camada
- Código morto
- Testes ausentes

### 3. Gerar plano de refatoração

Salvar em `plans/YYYY-MM-DD-refactor-<slug>.md`:

```md
# Plano de Refatoração: <título>
## Objetivo / Contexto / Estado atual / Problemas / Fora de escopo
## Estratégia / Fases incrementais / Arquivos / Testes / Riscos / Rollback / Critérios
```

### 4. Rodar `/jarvis-plan` no plano.

### 5. Executar incrementalmente por fase.

### 6. Relatório final em `docs/refactor_report_<slug>.md`.

## Regras duras

- Não fazer big-bang refactor.
- Não misturar refatoração com feature nova.
- Não alterar comportamento sem teste.
- Não apagar código sem confirmar uso.
- Não mexer em `.env` ou secrets.
- Não usar `--no-verify`.
- Não fazer push force.

## Regras específicas {{STACK}}

{{STACK_SPECIFIC_RULES}}
