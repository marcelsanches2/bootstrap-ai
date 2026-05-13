# AI Operating Model

Documento comum dos project-kits. Define como agentes devem trabalhar dentro de projetos versionados.

## Ciclo operacional

```txt
contexto -> plano -> revisão por papéis -> execução incremental -> jarvis-test-flow -> ship
```

## Princípios

- Simples primeiro.
- Explícito > implícito.
- Testes determinísticos.
- Sem secrets no git.
- Planos ruins não passam por simpatia.
- Mudanças grandes viram fases pequenas.
- Documento do projeto vence opinião genérica.

## Antes de implementar

1. Leia `CLAUDE.md`.
2. Leia os `docs/ai/` relevantes.
3. Inspecione arquivos existentes antes de sobrescrever.
4. Crie plano em `plans/` para mudança não trivial.
5. Rode `/jarvis-plan-revisor` quando o kit existir.

## Durante implementação

- Mantenha escopo fechado.
- Não misture refactor grande com feature.
- Não crie placeholder morto.
- Não adicione dependência sem justificativa.
- Registre decisões que afetam arquitetura, dados, segurança ou operação.

## Depois de implementar

- Rode comandos do `/jarvis-test-flow`.
- Corrija erro introduzido.
- Gere resumo com arquivos, comandos, resultado e pendências.
- Rode `/ship` antes de considerar pronto para merge/deploy.
