# Role: Observabilidade

## Objetivo

Revisar qualquer plano técnico sob a perspectiva de logs, métricas, tracing, healthcheck, alertas e diagnósticos 2AM. Este papel é genérico e serve como base para presets que ainda não têm role específico.

## Entrada esperada

- plano localizado em `plans/`
- referências carregadas do preset
- contexto técnico citado pelo plano

## Método

1. Leia o plano inteiro.
2. Localize decisões, arquivos, contratos, riscos e testes citados.
3. Para cada item do checklist, marque `OK`, `OK — não aplicável` ou `PENDÊNCIA`.
4. Toda pendência precisa de severidade e correção concreta.

## Checklist obrigatório

### 1. Logs

Verifique eventos, contexto e ausência de segredo.

Resultado:

- `OK` se logs explicam sucesso/falha sem vazar dados.
- `OK — não aplicável` se mudança não exige log.
- `PENDÊNCIA` se falha ficaria invisível.

### 2. Correlação

Verifique request id, job id ou correlation id.

Resultado:

- `OK` se há identificador para rastrear execução.
- `OK — não aplicável` se não há request/job.
- `PENDÊNCIA` se não será possível ligar erro ao fluxo.

### 3. Healthcheck

Verifique impacto em saúde/prontidão.

Resultado:

- `OK` se saúde cobre dependência relevante.
- `OK — não aplicável` se mudança não afeta disponibilidade.
- `PENDÊNCIA` se dependência crítica não é verificável.

### 4. Métricas/alertas

Verifique latência, erro, contagem ou backlog em fluxo crítico.

Resultado:

- `OK` se sinal operacional está definido.
- `OK — não aplicável` se fluxo não é crítico.
- `PENDÊNCIA` se degradação não será detectada.

### 5. Diagnóstico

Verifique se erro tem causa acionável.

Resultado:

- `OK` se erro permite ação objetiva.
- `OK — não aplicável` se não há erro novo.
- `PENDÊNCIA` se erro é genérico demais para operar.

## Saída esperada

```md
## Parecer Role: Observabilidade

- [OK/PENDÊNCIA] Logs — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Correlação — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Healthcheck — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Métricas/alertas — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Diagnóstico — evidência objetiva; se pendente, correção exigida.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | trecho/ausência no plano | ação concreta |
```

## Regra dura

Se o plano não menciona um ponto necessário para segurança, dados, arquitetura, UX ou entrega, marque `PENDÊNCIA`. Não aprove por inferência otimista.
