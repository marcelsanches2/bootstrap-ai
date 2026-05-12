# /refactor

Planeja e conduz uma refatoração segura em projeto existente.

Use quando este kit for aplicado em um projeto já em andamento e o objetivo for alinhar o código ao lifecycle, arquitetura, docs `docs/ai/`, roles e padrões do kit.

## Regra principal

Não comece refatorando código. Primeiro inventarie, gere plano, rode revisão e só então execute incrementalmente.

## Sequência obrigatória

### 0. Classificar escopo

Classifique a refatoração:

- `PEQUENA`: módulo/feature isolado, sem mudança pública de contrato.
- `MÉDIA`: múltiplos arquivos/features, mas sem alterar arquitetura central.
- `GRANDE`: arquitetura, pastas, DI, router, banco, API pública, build/deploy ou mudança transversal.

Se for `GRANDE`, não execute tudo em uma tacada. Divida em fases pequenas.

### 1. Carregar contexto

Leia obrigatoriamente:

- `CLAUDE.md`
- `docs/ai/ARCHITECTURE.md`
- `docs/ai/CODING_STANDARDS.md`
- `docs/ai/FEATURE_GUIDE.md`
- `docs/ai/TESTING_GUIDE.md`
- demais guias específicos da stack, se existirem

Liste também:

- estrutura de diretórios principal
- comandos de teste/build disponíveis
- dependências principais
- pontos de entrada
- arquivos de configuração

### 2. Inventário técnico

Crie um inventário objetivo:

- padrões atuais do projeto
- divergências contra `docs/ai/`
- dívidas técnicas visíveis
- duplicações
- violações de camada/boundary
- código morto ou arquivos vazios
- testes ausentes ou frágeis
- riscos de segurança/observabilidade/deploy, se aplicável

Não confunda opinião com regra. Se uma regra não estiver nos docs, marque como recomendação.

### 3. Gerar plano de refatoração

Crie arquivo em:

```txt
plans/YYYY-MM-DD-refactor-<slug>.md
```

Formato obrigatório:

```md
# Plano de Refatoração: <título>

## Objetivo
## Contexto carregado
## Estado atual
## Problemas encontrados
## Fora de escopo
## Estratégia
## Fases incrementais
## Arquivos prováveis
## Testes por fase
## Riscos
## Rollback
## Critérios de aceite
```

Cada fase deve ser pequena o suficiente para validar com `/test-flow`.

### 4. Rodar revisão multi-role

Rode `/jarvis-revisor` no plano criado.

- Se houver BLOCKER: pare.
- Se houver MAJOR: sane com o usuário antes de executar.
- Só implemente depois do plano revisado.

### 5. Executar incrementalmente

Para cada fase aprovada:

1. aplicar mudança mínima
2. rodar validação específica
3. rodar `/test-flow` quando a fase alterar comportamento, arquitetura, testes, build ou contrato
4. registrar resultado no plano ou relatório
5. parar se a causa raiz exigir ampliar escopo

### 6. Relatório final

Criar ou atualizar:

```txt
docs/refactor_report_<slug>.md
```

Conteúdo:

- plano usado
- fases executadas
- arquivos alterados
- comandos executados
- problemas encontrados
- decisões tomadas
- pendências restantes
- próximo passo recomendado

## Regras duras

- Não fazer big-bang refactor.
- Não misturar refatoração com feature nova.
- Não alterar comportamento sem teste ou justificativa explícita.
- Não apagar código sem confirmar uso/referências.
- Não mexer em `.env` ou secrets.
- Não usar `--no-verify`.
- Não fazer push force.
- Se o projeto já tem padrão divergente dos docs, registre o conflito antes de mudar.


## Regras específicas React Web

Validar especialmente:

- componentização e boundaries por feature
- data fetching explícito
- estado global só quando necessário
- design system/tokens
- loading/empty/error/success states
- acessibilidade: foco, teclado, labels, contraste
- performance: bundle, lazy loading, renderizações
- lint, typecheck, testes e build production
