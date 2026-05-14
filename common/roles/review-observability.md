# Role: Observabilidade

## Objetivo

Revisar planos sob a perspectiva de logs, métricas, tracing, healthcheck, alertas e diagnóstico operacional.

## Checklist

### 1. Logs

Eventos, contexto e ausência de segredo?

- `OK` — logs explicam sucesso/falha sem vazar dados.
- `OK — não aplicável` — mudança não exige log.
- `PENDÊNCIA` — falha ficaria invisível.

### 2. Correlação

Request id, job id ou correlation id?

- `OK` — identificador para rastrear execução.
- `OK — não aplicável` — não há request/job.
- `PENDÊNCIA` — não será possível ligar erro ao fluxo.

### 3. Healthcheck

Impacto em saúde/prontidão?

- `OK` — saúde cobre dependência relevante.
- `OK — não aplicável` — mudança não afeta disponibilidade.
- `PENDÊNCIA` — dependência crítica não verificável.

### 4. Métricas/alertas

Latência, erro, contagem ou backlog em fluxo crítico?

- `OK` — sinal operacional definido.
- `OK — não aplicável` — fluxo não crítico.
- `PENDÊNCIA` — degradação não detectável.

### 5. Diagnóstico

Erro tem causa acionável?

- `OK` — erro permite ação objetiva.
- `OK — não aplicável` — não há erro novo.
- `PENDÊNCIA` — erro genérico demais para operar.
