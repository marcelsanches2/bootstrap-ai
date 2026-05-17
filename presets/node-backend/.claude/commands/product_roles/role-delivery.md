# Role: Delivery

## Sua contribuição
Gera a seção "Deploy e entrega" do plano, cobrindo env vars, CI/CD, rollback, procedimento de deploy e riscos.

## Referência
- docs/ai/DEPLOYMENT_GUIDE.md

## O que incluir
- **Escopo de entrega**: o que entra nesta entrega (arquivos com caminho completo) e o que NÃO entra.
- **Dependências externas**: pacotes npm novos, serviços, integrações. Identifique cada uma.
- **Migrations**: migração de banco incluída, testada, com caminho de rollback/downgrade documentado.
- **Rollback**: procedimento claro de rollback se algo der errado em produção.
- **Deploy procedure**: passo a passo do deploy (comando, CI/CD pipeline, ou manual).
- **Env vars novas**: cada variável nova documentada em `.env.example` com nome, tipo, descrição e valor default quando aplicável.
- **Breaking changes**: se houver, documente e garanta versionamento (ex.: /api/v2/).
- **Critérios de aceite de entrega**: como validar que o deploy foi bem-sucedido.
- **Riscos e mitigações**: riscos identificados com ações mitigadoras concretas.

## Regras
- Sem rollback definido é BLOCKER.
- Breaking change sem versionamento é BLOCKER.
- Dependência externa não mapeada é BLOCKER.
- Toda env var nova deve estar em `.env.example`.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## Deploy e entrega

### Arquivos alterados/criados
- `{caminho/completo/do/arquivo}` — {o que faz}

### Dependências externas
| Pacote/Serviço | Versão | Motivo |
|----------------|--------|--------|
| {nome} | {versão} | {motivo} |

### Migrations
- **Up**: {comando ou descrição}
- **Down**: {comando ou descrição}
- **Rollback de dados**: {como reverter se necessário}

### Env vars novas
| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| {NOME} | {tipo} | {default} | {descrição} |

### Deploy procedure
1. {passo}
2. {passo}
3. {passo}

### Rollback
1. {passo}
2. {passo}

### Breaking changes
{Nenhuma / lista com versionamento}

### Critérios de aceite de entrega
- [ ] {critério}
- [ ] {critério}

### Riscos e mitigações
| Risco | Probabilidade | Mitigação |
|-------|--------------|-----------|
| {risco} | {alta/média/baixa} | {ação} |
```
