# Definition Of Done

Um plano ou implementação só está pronto quando pode ser entendido, validado e revertido por outra pessoa.

## Para plano técnico

- Escopo explícito.
- Arquivos/áreas afetadas listados.
- Riscos de arquitetura, dados, segurança e operação considerados.
- Testes/comandos de validação definidos.
- Critérios de aceite verificáveis.
- `/jarvis-revisor` sem `BLOCKER` e sem `MAJOR` pendente.

## Para implementação

- Escopo implementado sem feature creep.
- Comandos do `/test-flow` executados ou limitação documentada.
- Erros introduzidos corrigidos.
- Secrets fora do git.
- Migrations/rollback documentados quando toca dados.
- Logs/health/diagnóstico considerados para fluxo crítico.
- Resumo final lista arquivos alterados, comandos e pendências.

## Não está pronto se

- Só caminho feliz foi considerado.
- Teste depende de produção ou rede externa sem mock.
- Mudança breaking não tem migração/compatibilidade.
- Deploy não tem rollback.
- UI relevante está sem loading/error/empty/focus.
