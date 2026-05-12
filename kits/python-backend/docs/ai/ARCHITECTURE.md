# Arquitetura Backend Python

Este documento define a arquitetura técnica de um backend Python em {{PROJECT_NAME}}.

## Objetivo

Separar regra de negócio, transporte HTTP, persistência e integrações externas sem criar camadas cerimoniais inúteis.

## Estrutura base recomendada

```txt
src/
  {{project_package}}/
    main.py                  # app factory/entrypoint
    config.py                # settings tipadas
    api/
      routes/
      dependencies.py
      errors.py
    application/
      services/
      use_cases/
    domain/
      entities/
      value_objects/
      repositories.py
      errors.py
    infrastructure/
      db/
        models.py
        session.py
        repositories/
      integrations/
      clock.py
      logging.py
    observability/
      health.py
      middleware.py
alembic/
  versions/
tests/
  unit/
  integration/
  api/
```

Ajuste nomes à realidade do projeto, mas preserve boundaries.

## Camadas

### API / Transport

Responsável por FastAPI routers, request/response schemas, status codes e tradução de erros.

Não pode conter:

- regra de negócio complexa
- query SQL direta
- transação espalhada em endpoint
- chamada direta a SDK externo quando houver caso de uso

### Application

Orquestra casos de uso, transações e chamadas a repositórios/serviços externos.

Use para operações como `CreateUser`, `ChargeSubscription`, `SyncProviderData`.

### Domain

Contém entidades, value objects, políticas e contratos. Não depende de FastAPI, SQLAlchemy, Pydantic de API ou SDK externo.

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

- Não marque função como `async` se ela só chama código bloqueante.
- Em FastAPI async, evite bloquear event loop com I/O síncrono pesado.
- Background jobs precisam de retry, idempotência e logging por job id.

## Anti-patterns bloqueantes

- Endpoint com SQL, regra de negócio e chamada externa no mesmo arquivo.
- Model SQLAlchemy usado como schema público.
- Pydantic request usado como entidade de domínio.
- Repository que decide regra de negócio.
- Config global mutável espalhada.
- Exception genérica capturada e ignorada.
