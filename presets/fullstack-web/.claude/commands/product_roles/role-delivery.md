# Role: Delivery

## Sua contribuição
Gera a seção "Deploy e entrega" do plano, cobrindo env vars, CI/CD, build, migrations, rollback e riscos operacionais.

## Referência
- docs/ai/DEPLOYMENT_GUIDE.md

## O que incluir
- **Escopo da entrega**: o que entra e o que NÃO entra nesta entrega.
- **Arquivos alterados**: lista completa com caminho (frontend e backend).
- **Dependências externas**: npm packages, APIs, serviços novos — com justificativa.
- **Env/config**: variáveis de ambiente (frontend e backend) documentadas em `.env.example`, sem segredos expostos.
- **Build production**: comando de build previsto (frontend + backend), com saída/start definido.
- **Deploy procedure**: CI/CD, comandos, ordem de services.
- **Migration**: migration incluída, testada e com caminho de rollback/downgrade documentado.
- **Rollback**: como retornar à versão anterior — build anterior + compatibilidade API/cache/db.
- **Cache/CDN**: cache de assets, HTML/entrypoint e estratégia de invalidação.
- **Hosting**: fallback SPA, TLS, headers, proxy quando self-host.
- **Breaking changes**: breaking changes versionadas e comunicadas.
- **Riscos e mitigações**: riscos identificados com mitigações concretas.

## Regras
- Sem rollback documentado é bloqueante.
- Breaking change sem versão/aviso é bloqueante.
- Dependência não mapeada é bloqueante.
- Migration sem teste é bloqueante.
- Nunca commitar secrets, tokens, dumps, `.env` real ou credenciais.
- Se a mudança não tem impacto de deploy: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Deploy e entrega

### Escopo
- **Inclui**: {itens}
- **Não inclui**: {itens}

### Arquivos alterados
- {caminho/completo/do/arquivo}
- ...

### Dependências externas novas
| Pacote/Serviço | Justificativa |
|---|---|
| {nome} | {por quê} |

### Env vars
| Variável | Ambiente | Descrição | Exemplo (.env.example) |
|---|---|---|---|
| {NOME} | {dev/prod} | {o que faz} | {valor de exemplo} |

### Build
{comandos de build para frontend e backend}

### Deploy procedure
{passo a passo do deploy, ordem de services}

### Migration
| Migration | Comando | Rollback |
|---|---|---|
| {nome} | {comando up} | {comando down} |

### Rollback
{procedimento de rollback completo}

### Cache/CDN
{estratégia de cache e invalidação}

### Hosting
{configuração de nginx/hosting se aplicável}

### Breaking changes
{lista ou "Nenhuma"}

### Riscos e mitigações
| Risco | Probabilidade | Mitigação |
|---|---|---|
| {risco} | {alta/média/baixa} | {ação concreta} |
```
