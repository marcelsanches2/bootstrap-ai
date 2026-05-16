# Role: Delivery Fullstack

## Objetivo

Verifico que o plano é implementável sem surpresas: build, env, deploy, rollback, migrations e riscos cobertos.

## Fonte de referência

Referências carregadas por `product_roles/carregar-referencias.md`. Se referência necessária estiver ausente, marco pendência em vez de assumir padrão.

## Checklist obrigatório

### 1. Escopo claro

Verifico o que entra e o que NÃO entra no escopo desta entrega.

- `OK` se limites estão explícitos.
- `PENDÊNCIA` se escopo é ambíguo ou aberto.

### 2. Arquivos listados

Verifico que todos os arquivos alterados estão listados com caminho completo (frontend e backend).

- `OK` se lista está completa.
- `PENDÊNCIA` se arquivos relevantes estão omitidos.

### 3. Dependências externas

Verifico dependências novas (npm packages, APIs, serviços) identificadas com justificativa.

- `OK` se não há deps novas ou todas estão justificadas.
- `PENDÊNCIA` se dep não mapeada pode causar surpresa.

### 4. Env/config

Verifico env vars (frontend e backend) documentadas em `.env.example`, sem segredos expostos.

- `OK` se config está documentada e segura.
- `NA` se não há config nova.
- `PENDÊNCIA` se env var/segredo está ambíguo.

### 5. Build production

Verifico que build de produção está previsto e comando de saída/start está definido.

- `OK` se build está coberto (frontend + backend).
- `NA` se mudança sem impacto de build.
- `PENDÊNCIA` se não há validação de build.

### 6. Deploy procedure

Verifico procedimento de deploy descrito (CI/CD, comandos, ordem de services).

- `OK` se procedure está documentada.
- `NA` se deploy é automático e inalterado.
- `PENDÊNCIA` se assume deploy sem detalhes.

### 7. Migration

Verifico migration incluída, testada e com caminho de rollback/downgrade.

- `OK` se migration está coberta.
- `NA` se não há mudança de schema.
- `PENDÊNCIA` se migration ausente ou não testada.

### 8. Rollback

Verifico retorno para versão anterior (build anterior + compatibilidade API/cache/db).

- `OK` se rollback é claro para frontend e backend.
- `NA` se mudança não afeta deploy.
- `PENDÊNCIA` se rollback não foi considerado.

### 9. Cache/CDN

Verifico cache de assets, HTML/entrypoint e invalidação.

- `OK` se cache não quebra atualização.
- `NA` se sem cache/CDN no escopo.
- `PENDÊNCIA` se cache pode servir versão incompatível.

### 10. Nginx/hosting

Verifico fallback SPA, TLS, headers e proxy quando self-host.

- `OK` se hosting está coberto.
- `NA` se não se aplica.
- `PENDÊNCIA` se assume deploy sem detalhes operacionais.

### 11. Breaking changes

Verifico ausência de breaking change sem versionamento explícito.

- `OK` se sem breaking changes ou versionadas.
- `PENDÊNCIA` se breaking change sem versão/aviso.

### 12. Riscos e mitigações

Verifico riscos identificados com mitigações concretas.

- `OK` se riscos relevantes estão cobertos.
- `NA` se mudança trivial sem risco.
- `PENDÊNCIA` se riscos óbvios foram ignorados.

## Saída

```md
## Parecer Role: Delivery Fullstack

- [OK/NA/PENDÊNCIA] Escopo claro — evidência.
- [OK/NA/PENDÊNCIA] Arquivos listados — evidência.
- [OK/NA/PENDÊNCIA] Dependências externas — evidência.
- [OK/NA/PENDÊNCIA] Env/config — evidência.
- [OK/NA/PENDÊNCIA] Build production — evidência.
- [OK/NA/PENDÊNCIA] Deploy procedure — evidência.
- [OK/NA/PENDÊNCIA] Migration — evidência.
- [OK/NA/PENDÊNCIA] Rollback — evidência.
- [OK/NA/PENDÊNCIA] Cache/CDN — evidência.
- [OK/NA/PENDÊNCIA] Nginx/hosting — evidência.
- [OK/NA/PENDÊNCIA] Breaking changes — evidência.
- [OK/NA/PENDÊNCIA] Riscos e mitigações — evidência.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item | evidência | ação concreta |
```

## Regra dura

Não aprovo plano que não explicita o item crítico. BLOCKER: sem rollback, breaking change sem versão, dependência não mapeada, migration sem teste. Ausência de informação relevante é pendência, não aprovação.
