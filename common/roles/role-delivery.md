# Role: Delivery

## Objetivo

Revisar qualquer plano técnico sob a perspectiva de deploy, rollback, migrações, feature flags e riscos operacionais. Este papel é genérico e serve como base para presets que ainda não têm role específico.

## Entrada esperada

- plano localizado em `plans/`
- referências carregadas do preset
- contexto técnico citado pelo plano

## Método

1. Leia o plano inteiro.
2. Localize decisões, arquivos, contratos, riscos e testes citados.
3. Para cada item do checklist, marque `OK`, `OK — não aplicável` ou `PENDÊNCIA`.
4. Toda pendência precisa de severidade e correção concreta.

## Checklist obrigatório

### 1. Build/release

Verifique artefato, comandos e lockfile.

Resultado:

- `OK` se release é reproduzível.
- `OK — não aplicável` se não há entrega executável.
- `PENDÊNCIA` se build/start estão indefinidos.

### 2. Config

Verifique env vars e defaults seguros.

Resultado:

- `OK` se config está documentada e validada.
- `OK — não aplicável` se não há config nova.
- `PENDÊNCIA` se config quebra só em runtime.

### 3. Migrations/dados

Verifique schema, backup e rollout.

Resultado:

- `OK` se dados estão protegidos.
- `OK — não aplicável` se não toca dados.
- `PENDÊNCIA` se mudança de dados sem plano.

### 4. Rollback

Verifique como voltar código/config/schema.

Resultado:

- `OK` se rollback é executável.
- `OK — não aplicável` se mudança sem risco operacional.
- `PENDÊNCIA` se não há retorno seguro.

### 5. Operação

Verifique systemd/nginx/CI/CD/monitoramento conforme stack.

Resultado:

- `OK` se operação foi considerada.
- `OK — não aplicável` se não se aplica.
- `PENDÊNCIA` se plano assume deploy mágico.

## Saída esperada

```md
## Parecer Role: Delivery

- [OK/PENDÊNCIA] Build/release — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Config — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Migrations/dados — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Rollback — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Operação — evidência objetiva; se pendente, correção exigida.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | trecho/ausência no plano | ação concreta |
```

## Regra dura

Se o plano não menciona um ponto necessário para segurança, dados, arquitetura, UX ou entrega, marque `PENDÊNCIA`. Não aprove por inferência otimista.
