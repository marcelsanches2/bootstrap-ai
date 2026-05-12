# Arquitetura Backend Node.js/TypeScript

Este documento define a arquitetura técnica de um backend Node.js/TypeScript em {{PROJECT_NAME}}.

## Objetivo

Separar regra de negócio, transporte HTTP, persistência e integrações externas sem criar camadas cerimoniais inúteis.

## Estrutura base recomendada

```txt
src/
  app/
    server.ts                 # entrypoint/app factory
    config.ts                 # settings tipadas e validadas
    api/
      routes/
      middleware/
      errors.ts
    application/
      services/
      use-cases/
    domain/
      entities/
      value-objects/
      repositories.ts
      errors.ts
    infrastructure/
      db/
        schema.ts             # Prisma/Drizzle/ORM quando aplicável
        client.ts
        repositories/
      integrations/
      clock.ts
      logger.ts
    observability/
      health.ts
      request-id.ts
migrations/                   # ou prisma/migrations, drizzle/, conforme stack real
tests/
  unit/
  integration/
  api/
```

Ajuste nomes à realidade do projeto, mas preserve boundaries.

## Camadas

### API / Transport

Responsável por Fastify/Express/Nest routes/controllers, request/response schemas, status codes, middleware e tradução de erros.

Não pode conter:

- regra de negócio complexa
- query SQL direta
- transação espalhada em handler/controller
- chamada direta a SDK externo quando houver caso de uso

### Application

Orquestra casos de uso, transações e chamadas a repositórios/serviços externos.

Use para operações como `CreateUser`, `ChargeSubscription`, `SyncProviderData`.

### Domain

Contém entidades, value objects, políticas e contratos. Não depende de Express/Fastify/Nest, Prisma/Drizzle, Zod/class-validator de API ou SDK externo.

### Infrastructure

Implementa banco, repositórios, clients HTTP, filas, storage e adapters externos.

## Regra de dependência

```txt
api -> application -> domain
infrastructure -> domain
application -> contracts/interfaces
```

O domínio não aponta para fora. Infra implementa contratos definidos para dentro.

## Configuração

- Settings devem ser tipadas e validadas no startup.
- `.env` real nunca entra no git.
- Variável obrigatória ausente deve falhar no boot, não na primeira request.
- Config de teste deve ser isolada da produção.

## Transações

- Toda escrita relevante precisa de fronteira transacional explícita.
- Não abra transação dentro de loops longos sem justificar.
- Não misture commit automático em repository com caso de uso que precisa atomicidade.
- Idempotência é obrigatória para webhooks, retries e comandos que podem ser repetidos.

## Integrações externas

- Use client dedicado por integração.
- Configure timeout explícito.
- Traduza erro externo para erro de domínio/aplicação.
- Não deixe SDK externo vazar para domínio.

## Assincronia

- `async` precisa propagar erro corretamente.
- Evite bloquear event loop com I/O síncrono pesado.
- Background jobs precisam de retry, idempotência e logging por job id.
- Promise sem `await`/tratamento explícito é risco operacional.

## Anti-patterns bloqueantes

- Handler/controller com SQL, regra de negócio e chamada externa no mesmo arquivo.
- Model Prisma/Drizzle usado como schema público.
- Zod/class-validator request usado como entidade de domínio.
- Repository que decide regra de negócio.
- Config global mutável espalhada.
- `catch` genérico que engole erro.
