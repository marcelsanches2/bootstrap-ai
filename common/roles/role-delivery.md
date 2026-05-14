# Role: Delivery

## Objetivo

Revisar planos sob a perspectiva de deploy, rollback, migrações, config e riscos operacionais.

## Checklist

### 1. Build/release

Artefato, comandos e lockfile definidos?

- `OK` — release é reproduzível.
- `OK — não aplicável` — não há entrega executável.
- `PENDÊNCIA` — build/start indefinidos.

### 2. Config

Env vars e defaults seguros?

- `OK` — config documentada e validada.
- `OK — não aplicável` — não há config nova.
- `PENDÊNCIA` — config só quebra em runtime.

### 3. Migrations/dados

Schema, backup e rollout?

- `OK` — dados protegidos.
- `OK — não aplicável` — não toca dados.
- `PENDÊNCIA` — mudança de dados sem plano.

### 4. Rollback

Como voltar código/config/schema?

- `OK` — rollback executável.
- `OK — não aplicável` — mudança sem risco operacional.
- `PENDÊNCIA` — sem retorno seguro.

### 5. Operação

Deploy, CI/CD, monitoramento?

- `OK` — operação considerada.
- `OK — não aplicável` — não se aplica.
- `PENDÊNCIA` — plano assume deploy mágico.
