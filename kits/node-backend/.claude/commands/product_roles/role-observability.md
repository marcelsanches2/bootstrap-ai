# Role: Observability

## Objetivo

Revisar diagnósticos operacionais: logs, request id, métricas e saúde.

## Fonte de referência

Use as referências carregadas por `product_roles/carregar-referencias.md`. Se uma referência necessária estiver ausente, marque pendência em vez de assumir padrão.

## Entrada esperada

- plano localizado
- referências carregadas
- conteúdo do plano
- contexto do projeto quando citado pelo plano

## Checklist obrigatório

### 1. Logs estruturados

Verifique eventos relevantes, contexto e ausência de segredo/PII.

Resultado:

- `OK` se logs ajudam debug sem vazar dados.
- `OK — não aplicável` se mudança sem evento operacional relevante.
- `PENDÊNCIA` se falhas ficam invisíveis ou vazam dados.

### 2. Correlation/request id

Verifique propagação em request, erro e logs.

Resultado:

- `OK` se request_id/correlation_id está previsto.
- `OK — não aplicável` se não há request/job.
- `PENDÊNCIA` se não há correlação para investigar falha.

### 3. Healthcheck

Verifique impacto em `/healthz`/`/readyz` ou equivalente.

Resultado:

- `OK` se saúde do serviço cobre a mudança.
- `OK — não aplicável` se mudança não afeta disponibilidade.
- `PENDÊNCIA` se não há forma de saber se dependência crítica está pronta.

### 4. Métricas

Verifique contadores, latência e taxa de erro para fluxo crítico.

Resultado:

- `OK` se métricas essenciais foram previstas.
- `OK — não aplicável` se fluxo não é crítico/operacional.
- `PENDÊNCIA` se não será possível detectar degradação.

### 5. Erros acionáveis

Verifique códigos internos, stack server-side e mensagem segura client-side.

Resultado:

- `OK` se erro permite ação.
- `OK — não aplicável` se não há erro novo.
- `PENDÊNCIA` se erro genérico impede diagnóstico.

## Saída esperada

```md
## Parecer Role: Observability

- [OK/PENDÊNCIA] Logs estruturados — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Correlation/request id — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Healthcheck — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Métricas — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Erros acionáveis — evidência objetiva e correção sugerida quando pendente.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | evidência do plano | ação concreta |
```

## Regra dura

Não aprove plano que não explicita o item crítico. Ausência de informação relevante é pendência, não aprovação.
