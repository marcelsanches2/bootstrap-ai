# Role: Node Architect

## Sua contribuição
Gera a seção de patterns Node/TypeScript backend do plano, definindo camadas, middleware, serviços, ORM, migrations e convenções de código.

## Referência
- docs/ai/ARCHITECTURE.md
- docs/ai/CODING_STANDARDS.md

## O que incluir
- **Camadas**: Controller → Service → Repository → Prisma. Cada camada com responsabilidade clara.
  - Controller: recebe request, chama service, retorna response. Sem lógica de negócio, sem acesso direto ao Prisma.
  - Service: lógica de negócio pura. Não conhece HTTP (sem Request/Response/status codes). Recebe dependências via construtor (DI).
  - Repository: queries Prisma sem lógica de negócio. Apenas acesso a dados.
- **Zod schemas**: separados de tipos TypeScript. Schemas validam input em boundaries (controller), tipos derivam dos schemas.
- **Imports**: organizados (external → internal), sem import circular.
- **Nomenclatura**: kebab-case para arquivos, PascalCase para classes, camelCase para funções.
- **Async/await**: em toda operação de IO.
- **Config**: via env vars validadas com Zod, nunca hardcoded.
- **Tipos explícitos**: em funções públicas, sem `any` sem justificativa documentada.

## Regras
- Controller jamais acessa Prisma diretamente.
- Service jamais conhece HTTP.
- `any` sem justificativa documentada é bloqueante.
- Config hardcoded é bloqueante.
- Se a task não envolve backend Node: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Backend — Patterns

### Camadas
| Camada | Arquivo | Responsabilidade |
|---|---|---|
| Controller | {path} | {o que faz} |
| Service | {path} | {o que faz} |
| Repository | {path} | {o que faz} |

### Schemas (Zod)
{lista de schemas com nome, arquivo e o que validam}

### Dependências (DI)
{quais serviços recebem quais dependências no construtor}

### Config
{env vars necessárias com validação Zod}

### Convenções
{nomenclatura, imports, async/await — diferenças do padrão se houver}
```
