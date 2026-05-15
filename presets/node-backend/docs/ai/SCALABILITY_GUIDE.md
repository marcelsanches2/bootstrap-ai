# Guia de Escalabilidade e Produção

## Objetivo

Este documento força a revisão dos pontos que normalmente quebram quando uma aplicação sai do ambiente pequeno e começa a receber carga real: banco, concorrência, filas, cache, latência, throughput, limites e operação.

Escalabilidade aqui não significa microservices por padrão. Significa saber onde o sistema vai falhar primeiro e deixar o plano preparado para diagnosticar, limitar e recuperar.

## Banco de dados

### Queries

Verifique:

- filtros usam colunas indexadas quando volume justificar
- ordenação é determinística
- paginação não degrada com offset profundo quando volume for alto
- joins têm cardinalidade entendida
- N+1 foi evitado
- query crítica tem teste, `EXPLAIN` ou justificativa

### Índices

Índice deve existir para:

- lookup frequente por chave externa
- unicidade que protege regra de negócio
- paginação/ordenação crítica
- filtros usados em endpoint quente

Não crie índice por reflexo. Índice acelera leitura e custa escrita, storage e manutenção.

### Crescimento de dados

Planos que criam ou expandem tabelas devem responder:

- qual volume esperado em 3, 6 e 12 meses?
- há retenção, arquivamento ou limpeza?
- queries antigas continuam aceitáveis com 10x dados?
- campos grandes ficam fora de tabela quente?

## Concorrência e consistência

Verifique operações com risco de corrida:

- read-modify-write
- criação com unicidade lógica
- consumo de crédito/saldo/estoque
- webhook reentregável
- job que pode rodar em paralelo
- retry automático

Mitigações possíveis:

- constraint única
- lock otimista por versão
- lock pessimista curto
- transação bem delimitada
- idempotency key
- outbox/inbox pattern
- fila com deduplicação

Regra: se duplicar a request causa efeito duplicado, o plano precisa tratar idempotência.

## Pool, conexões e limites

Em produção, falha comum é esgotar recurso compartilhado.

Verifique:

- pool de conexão com banco tem tamanho explícito
- workers/processos não multiplicam conexões além do limite do banco
- timeouts existem para banco, HTTP externo e fila
- endpoint caro tem limite de payload, paginação ou rate limit
- upload/exportação não carrega tudo em memória
- backpressure existe para fila/job quando downstream degrada

## Cache

Cache só ajuda quando há estratégia de invalidação.

Plano com cache deve definir:

- chave
- TTL
- escopo por usuário/tenant quando aplicável
- invalidação
- comportamento em cache miss
- risco de dado stale
- métrica de hit/miss quando relevante

Não use cache para esconder query ruim antes de entender a query.

## Filas e jobs

Para processamento assíncrono, verifique:

- job é idempotente
- payload é pequeno e versionado
- retry tem limite e backoff
- dead-letter ou estado de falha existe
- concorrência máxima é definida
- logs incluem job id e entidade afetada
- backlog é monitorável

## Integrações externas

Toda chamada externa crítica precisa de:

- timeout explícito
- retry com backoff quando seguro
- circuit breaker ou degradação controlada quando necessário
- fallback/erro claro para usuário/cliente
- métrica de latência e erro
- teste de timeout/falha

## Performance de API

Verifique:

- payload não retorna campos desnecessários
- endpoint de coleção tem paginação e limite máximo
- serialização não domina custo
- compressão faz sentido para resposta grande
- operações caras não rodam no request síncrono sem necessidade
- endpoint quente tem métrica de latência p95/p99 quando aplicável

## Observabilidade para escala

Escala sem observabilidade vira chute.

Mínimo para fluxo crítico:

- latência por endpoint/job
- taxa de erro por código/operação
- contagem de requests/jobs
- pool/conexões quando aplicável
- backlog de fila
- tempo de dependência externa
- logs com request id/job id

## Anti-patterns bloqueantes

- Listar tabela crescente sem paginação.
- Fazer `SELECT *` em endpoint público quente.
- Usar offset profundo para feed grande sem reconhecer custo.
- Criar job não idempotente com retry.
- Fazer chamada externa sem timeout.
- Resolver concorrência só “checando antes” sem constraint/transação.
- Cache sem invalidação.
- Exportação carregando tudo em memória.
- Plano “vamos escalar depois” para fluxo já crítico.
