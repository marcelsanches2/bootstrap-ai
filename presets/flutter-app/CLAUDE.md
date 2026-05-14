# CLAUDE.md

Contrato principal para Claude Code no projeto {{PROJECT_NAME}}.

## Projeto

{{PROJECT_NAME}} é um app mobile Flutter de corrida competitiva baseada em disputas territoriais.

Stack principal:

- Flutter
- Dart
- Riverpod
- GoRouter
- Dio
- Feature-first architecture
- Clean Architecture pragmática

## Leitura sob demanda

Os arquivos em `docs/ai/` devem ser lidos conforme o tipo da tarefa. Não leia todos automaticamente — carregue apenas os relevantes.

| Tipo de tarefa | Documento(s) a ler |
|---|---|
| Alteração de arquitetura, estrutura de pastas, DI, router, network, config ou core | `docs/ai/ARCHITECTURE.md` |
| Alteração visual, tema, componente, tela, cor, tipografia ou UI | `docs/ai/DESIGN_SYSTEM.md` |
| Implementação ou refatoração de código | `docs/ai/CODING_STANDARDS.md` |
| Criação ou alteração de feature | `docs/ai/FEATURE_GUIDE.md` |
| Tarefa misturando áreas | Todos os documentos relevantes |

Se houver conflito entre documentos, a ordem de prioridade é:

1. `CLAUDE.md`
2. `ARCHITECTURE.md`
3. `CODING_STANDARDS.md`
4. `FEATURE_GUIDE.md`
5. `DESIGN_SYSTEM.md`

## Documentação no plano

No plano inicial de qualquer tarefa, informe explicitamente quais documentos de `docs/ai/` foram lidos antes de implementar. Isso garante rastreabilidade e alinhamento.

## Prioridade atual

O projeto está em fase de fundação técnica.

Prioridade:

1. estrutura técnica
2. organização feature-first
3. separação de camadas
4. navegação base
5. injeção de dependência
6. network foundation
7. preparação para design system

Não implemente feature, fluxo, mapa, GPS ou visual final sem pedido explícito.

## Regras obrigatórias

- Não misturar UI com regra de negócio.
- Não chamar Dio em widgets, pages ou controllers.
- Não acessar datasource fora da camada data.
- Não vazar DTO para presentation.
- Não criar arquitetura paralela.
- Não criar fluxo grande sem pedido explícito.
- Não implementar design final em tarefa técnica.
- Não adicionar dependência sem justificar.
- Não sobrescrever arquivos sem inspecionar antes.
- Não criar arquivos grandes.
- Não duplicar lógica entre features.
- Não usar laranja no app.

## Processo

Antes de alterar:

1. inspecione a estrutura atual
2. leia os documentos de `docs/ai/` relevantes para a tarefa (conforme a tabela de leitura sob demanda)
3. entenda o escopo da tarefa
4. descreva o plano brevemente
5. implemente de forma incremental

Depois de alterar:

1. rode `flutter pub get` se mexeu no `pubspec.yaml`
2. rode `flutter analyze`
3. rode `flutter test` se existirem testes
4. corrija erros introduzidos
5. informe arquivos criados/modificados, comandos executados e pendências

## Princípio de decisão

Prefira:

- simples em vez de esperto
- explícito em vez de mágico
- incremental em vez de grande reescrita
- arquitetura estável em vez de falsa velocidade
- placeholders em vez de lógica fake espalhada

Quando houver dúvida de produto, não invente. Aponte a decisão pendente.