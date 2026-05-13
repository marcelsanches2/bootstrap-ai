# CLAUDE.md

Contrato principal para Claude Code no projeto {{PROJECT_NAME}}.

## Projeto

{{PROJECT_NAME}} é {{PROJECT_DESCRIPTION}}.

Stack principal:

{{STACK_LIST}}

## Leitura sob demanda

Os arquivos em `docs/ai/` devem ser lidos conforme o tipo da tarefa. Não leia todos automaticamente — carregue apenas os relevantes.

| Tipo de tarefa | Documento(s) a ler |
|---|---|
{{READING_TABLE}}

Se houver conflito entre documentos, a ordem de prioridade é:

{{PRIORITY_ORDER}}

## Documentação no plano

No plano inicial de qualquer tarefa, informe explicitamente quais documentos de `docs/ai/` foram lidos antes de implementar. Isso garante rastreabilidade e alinhamento.

## Prioridade atual

O projeto está em fase de fundação técnica.

Prioridade:

{{PRIORITY_LIST}}

Não implemente feature, fluxo ou visual final sem pedido explícito.

## Regras obrigatórias

{{RULES_LIST}}

## Processo

Antes de alterar:

1. inspecione a estrutura atual
2. leia os documentos de `docs/ai/` relevantes para a tarefa (conforme a tabela de leitura sob demanda)
3. entenda o escopo da tarefa
4. descreva o plano brevemente
5. implemente de forma incremental

Depois de alterar:

{{AFTER_CHANGE_STEPS}}

## Princípio de decisão

Prefira:

- simples em vez de esperto
- explícito em vez de mágico
- incremental em vez de grande reescrita
- arquitetura estável em vez de falsa velocidade
- placeholders em vez de lógica fake espalhada

Quando houver dúvida de produto, não invente. Aponte a decisão pendente.
