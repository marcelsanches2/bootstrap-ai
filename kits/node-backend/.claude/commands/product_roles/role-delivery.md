# Role: Delivery / Operations

## Objetivo

Revisar entrega, deploy, rollback e operação em VPS/systemd/nginx quando aplicável.

## Fonte de referência

Use as referências carregadas por `product_roles/carregar-referencias.md`. Se uma referência necessária estiver ausente, marque pendência em vez de assumir padrão.

## Entrada esperada

- plano localizado
- referências carregadas
- conteúdo do plano
- contexto do projeto quando citado pelo plano

## Checklist obrigatório

### 1. Config env

Verifique env vars, `.env.example`, defaults seguros e startup fail-fast.

Resultado:

- `OK` se config está documentada e validada.
- `OK — não aplicável` se não há config nova.
- `PENDÊNCIA` se env var nova não está documentada/validada.

### 2. Migrations em deploy

Verifique ordem app/migration e estratégia expand-contract.

Resultado:

- `OK` se deploy considera migration.
- `OK — não aplicável` se não há migration.
- `PENDÊNCIA` se migration pode quebrar versão atual/rollback.

### 3. Rollback

Verifique caminho para voltar código, schema e config.

Resultado:

- `OK` se rollback é executável.
- `OK — não aplicável` se mudança não afeta deploy.
- `PENDÊNCIA` se não há plano de rollback.

### 4. systemd/nginx

Verifique serviço, usuário, working dir, restart, TLS/proxy quando aplicável.

Resultado:

- `OK` se operação self-host está coberta.
- `OK — não aplicável` se projeto não é exposto/implantado nesse escopo.
- `PENDÊNCIA` se deploy assume plataforma sem detalhar operação.

### 5. Build/release

Verifique lockfile, comando de start e healthcheck pós-deploy.

Resultado:

- `OK` se release é reproduzível e verificável.
- `OK — não aplicável` se não há entrega.
- `PENDÊNCIA` se build/start/healthcheck estão indefinidos.

## Saída esperada

```md
## Parecer Role: Delivery / Operations

- [OK/PENDÊNCIA] Config env — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Migrations em deploy — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Rollback — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] systemd/nginx — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Build/release — evidência objetiva e correção sugerida quando pendente.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | evidência do plano | ação concreta |
```

## Regra dura

Não aprove plano que não explicita o item crítico. Ausência de informação relevante é pendência, não aprovação.
