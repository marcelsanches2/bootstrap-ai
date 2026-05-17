# Role: Delivery

## Sua contribuição
Gera a seção "Deploy e entrega" do plano, cobrindo env vars, CI/CD, rollback, configuração de infra e procedimentos de deploy.

## Referência
- docs/ai/DEPLOYMENT_GUIDE.md
- docs/ai/ARCHITECTURE.md

## O que incluir
- **Escopo da entrega**: o que entra e o que NÃO entra nesta entrega. Sem ambiguidade.
- **Arquivos alterados**: lista com caminhos completos de todos os arquivos que serão criados ou modificados.
- **Dependências externas**: novos pacotes, serviços, APIs ou integrações necessárias.
- **Migrations**: migration incluída com upgrade() e downgrade() completos. Testada.
- **Rollback**: procedimento concreto para reverter se der errado. Inclua comandos (ex: `alembic downgrade -1` + redeploy versão anterior).
- **Procedure de deploy**: ordem de execução, variáveis novas, pré-requisitos.
- **Env vars**: documente todas as variáveis de ambiente novas em `.env.example` com valor exemplo e descrição.
- **Breaking changes**: se houver, versionamento de API obrigatório. Liste explicitamente.
- **Configuração de infra**: alterações em nginx, systemd, docker, supervisor — o que muda e por quê.
- **Critérios de aceite de entrega**: como saber que o deploy funcionou ( smoke test, healthcheck, verificação manual).
- **Riscos e mitigações**: riscos identificados com ações mitigadoras.
- **Comunicação necessária**: quando a API muda, quem precisa ser avisado (front, mobile, outro time).

## Regras
- Todo plano que toca banco deve ter migration com upgrade E downgrade.
- Nenhum breaking change sem versionamento de API.
- Toda env var nova documentada em `.env.example`.
- Sem segredos hardcoded — tudo via env vars.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```markdown
## Deploy e entrega

### Escopo da entrega
**Inclui:**
- {Item 1}
- {Item 2}

**Não inclui:**
- {Item excluído 1}

### Arquivos alterados
- `caminho/arquivo1.py` — {o que faz}
- `caminho/arquivo2.py` — {o que faz}

### Dependências externas
| Dependência | Versão | Uso |
|-------------|--------|-----|
| {pacote/serviço} | {versão} | {para quê} |

### Migrations
- `alembic/versions/xxx_descricao.py`
  - upgrade(): {o que faz}
  - downgrade(): {o que faz}
  - Testado: {sim/não + como}

### Rollback
1. {Passo 1 — ex: `alembic downgrade -1`}
2. {Passo 2 — ex: redeploy versão anterior}
3. {Passo 3 — ex: verificar healthcheck}

### Procedure de deploy
1. {Passo 1}
2. {Passo 2}
3. ...

### Env vars novas
| Variável | Exemplo | Descrição | Obrigatória? |
|----------|---------|-----------|-------------|
| `VAR_NAME` | `valor_exemplo` | {o que controla} | sim/não |

### Breaking changes
{Nenhuma OU lista com detalhes e versionamento}

### Configuração de infra
- **nginx**: {mudança ou "nenhuma"}
- **systemd**: {mudança ou "nenhuma"}
- **docker**: {mudança ou "nenhuma"}

### Critérios de aceite de entrega
- [ ] {Critério verificável 1}
- [ ] {Critério verificável 2}

### Riscos e mitigações
| Risco | Probabilidade | Mitigação |
|-------|--------------|-----------|
| {Risco} | {alta/média/baixa} | {Ação} |

### Comunicação necessária
- {Quem precisa ser avisado e do quê}
```
