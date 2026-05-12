# Guia de Testes Python

## Pirâmide prática

- Unit: domínio, use cases, serialização, funções puras.
- Integration: repositórios, banco, migrations, clients com fake server/mock.
- API: endpoints, auth, status codes, payloads.
- E2E: somente fluxos críticos e caros de quebrar.

## pytest

- Fixtures devem ser determinísticas.
- Teste não depende de ordem.
- Teste não acessa produção.
- Use factory/builder para dados complexos.
- Controle relógio quando regra depende de tempo.

## Banco

- Teste de repository deve rodar em banco isolado.
- Migration crítica precisa teste de upgrade/downgrade ou validação manual documentada.
- Limpe dados entre testes por transação ou recriação controlada.

## API

Para endpoint novo, cubra:

- sucesso
- validação inválida
- não autenticado
- sem permissão
- recurso inexistente
- conflito quando aplicável

## Mocks

- Mock deve substituir dependência externa, não a lógica que você quer testar.
- HTTP externo precisa de timeout e cenário de erro testado.
- Evite mockar repository em teste de endpoint se o objetivo é validar integração.

## Comandos mínimos

```bash
ruff check .
ruff format --check .
pytest
mypy .  # quando configurado
```
