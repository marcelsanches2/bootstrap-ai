# Padrões de Código Node.js/TypeScript

## Versão e estilo

- Node.js/TypeScript 3.12+.
- Type hints em funções públicas, services, repositories e clients.
- `ESLint` para lint/format quando configurado.
- `typecheck` para módulos críticos quando configurado.
- Imports absolutos preferidos dentro do pacote.

## Funções e classes

- Função deve ter uma responsabilidade verificável.
- Prefira dataclasses/Zod/class-validator/value objects para dados com significado.
- Não use dict solto atravessando camadas quando o shape é conhecido.
- Evite herança; prefira composição e protocolos simples.

## Erros

- Exceções de domínio devem ter nome específico.
- Não capture `Exception` sem logar e sem re-raise/tradução.
- Erro externo deve virar erro da aplicação antes de chegar à API.
- Mensagem pública não deve revelar stack trace, SQL, token ou regra interna sensível.

## Tipagem

- Use `Optional[T]`/`T | None` apenas quando `None` for estado real.
- Não use `Any` para fugir de modelagem; se inevitável, limite a borda.
- Protocols são úteis para contratos de repositório/client, mas não crie se não houver substituição real.

## Dependências

- Dependência nova precisa de justificativa: problema resolvido, alternativa stdlib, impacto operacional.
- Pin/lockfile deve ser respeitado.
- Não adicione SDK pesado para uma chamada HTTP simples sem motivo.

## Logging

- Logue evento, contexto e identificador; não logue segredo.
- Use logger do módulo, não `print`.
- Erros inesperados precisam de stack trace no servidor e mensagem segura no cliente.

## Anti-patterns

- Service gigante com 20 métodos não relacionados.
- Endpoint fazendo tudo.
- `datetime.now()` direto em regra testável; injete relógio quando necessário.
- Teste dependendo da ordem de execução.
- Mock escondendo bug de contrato.
