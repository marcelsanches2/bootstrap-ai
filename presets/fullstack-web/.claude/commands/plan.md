# /plan

Crie um plano técnico para a tarefa solicitada.

## Pré-check: /grill necessário?

Analise a task antes de planejar. Se encontrar UMA destas condições, sugira `/grill`:

- Feature nova sem especificação clara
- Múltiplas abordagens viáveis com trade-offs reais
- Termos ambíguos que o agente não consegue resolver lendo o codebase
- Decisão de arquitetura potencialmente irreversível

Resposta sugerida: "Essa task tem decisões de design abertas. Quer fazer um `/grill` antes de alinhar os detalhes?"

Se o user disser não, segue o fluxo normalmente.

## Obrigatório

1. Identificar escopo.
2. Ler documentos relevantes em `docs/ai/`.
3. Descrever comportamento esperado.
4. Listar arquivos prováveis.
5. Listar riscos.
6. Listar testes necessários.
7. Salvar em `plans/YYYY-MM-DD-slug.md`.

## Saída

- Objetivo
- Contexto lido
- Escopo
- Fora de escopo
- Arquitetura proposta
- Plano incremental
- Testes
- Riscos
- Critérios de aceite
