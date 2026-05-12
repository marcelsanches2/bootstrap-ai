# Guia de Observabilidade

## Objetivo

Produção precisa responder três perguntas rápido: o serviço está vivo, o que falhou e qual request/job causou.

## Logs

- Logs estruturados quando possível.
- Inclua `request_id`/`correlation_id`.
- Inclua entidade/operation id, nunca segredo.
- Erro inesperado deve logar stack trace no servidor.
- Mensagem pública continua segura.

## Request ID

- Gere se o cliente não enviar.
- Propague para logs, respostas de erro e chamadas downstream quando possível.
- Use middleware, não código manual em cada endpoint.

## Healthcheck

Endpoints recomendados:

- `/healthz`: processo vivo, sem dependência pesada.
- `/readyz`: pronto para tráfego, pode checar banco/fila com timeout curto.

## Métricas

Quando houver volume ou operação crítica, medir:

- latência por rota/operação
- taxa de erro
- contagem de jobs/processamentos
- falha de integração externa
- uso de fila/backlog quando aplicável

## Alertabilidade

Não basta logar. Erros críticos precisam ser agregáveis por código/operação.

## Incidente

Plano deve permitir descobrir:

- versão em execução
- request/job afetado
- usuário/tenant afetado sem vazar PII
- dependência externa envolvida
- se rollback resolve
