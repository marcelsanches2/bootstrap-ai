# role-backend-architect

## Objetivo
Validar que o plano respeita a arquitetura em camadas (Router → Service → Repository → Model) e as convenções estruturais do Python backend.

## Fonte de referência
- `docs/ai/ARCHITECTURE.md`
- `docs/ai/CODING_STANDARDS.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar se cada mudança proposta respeita separação de camadas, injeção de dependência e convenções de nomenclatura.

## Checklist obrigatório

- [ ] Router não contém lógica de negócio (apenas chama service e retorna response)
- [ ] Router não acessa models ou banco diretamente
- [ ] Service não conhece HTTP (sem Request/Response/status codes)
- [ ] Service recebe dependências no construtor, não via import global
- [ ] Repository não contém lógica de negócio, apenas queries
- [ ] Repository não chama commit/rollback (delegado ao service)
- [ ] Model não contém lógica de negócio
- [ ] Schemas Pydantic separados de models SQLAlchemy
- [ ] Imports seguem ordem: stdlib → third-party → local
- [ ] Nomenclatura consistente (snake_case arquivos/funções, PascalCase classes)
- [ ] Sem import circular (TYPE_CHECKING quando necessário)
- [ ] Async em toda operação de IO (banco, HTTP, arquivo)
- [ ] Config via Settings (pydantic-settings), não hardcoded
- [ ] Dependências injetáveis em dependencies.py

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que viola, em qual arquivo/camada, e correção.

### Severidade
- BLOCKER: pular camada, import circular, sync em async, config hardcoded.
- MAJOR: lógica no lugar errado, nomenclatura inconsistente.
- MINOR: import desordenado, type hint faltando.

## Saída em Markdown

```md
### role-backend-architect

- [OK] Separação de camadas — Service orquestra, Repository faz queries. ✓
- [PENDÊNCIA BLOCKER] Router acessa banco diretamente em POST /api/v1/orders.
  Correção: mover query para OrderRepository e chamar via OrderService.
...
```

## Regra dura
Plano que propõe router acessando banco, service com HTTP, ou model com lógica de negócio não está pronto.
