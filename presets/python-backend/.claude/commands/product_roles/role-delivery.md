# role-delivery

## Objetivo
Validar que o plano é implementável sem surpresas: escopo claro, dependências mapeadas, rollback definido e deploy considerado.

## Fonte de referência
- `docs/ai/DEPLOYMENT_GUIDE.md`
- `docs/ai/ARCHITECTURE.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Avaliar se o plano pode ser executado sem ambiguidade, com rollback seguro e deploy limpo.

## Checklist obrigatório

- [ ] Escopo claro: o que entra e o que NÃO entra
- [ ] Arquivos listados com caminho completo
- [ ] Dependências externas identificadas (novos pacotes, serviços, APIs)
- [ ] Migration incluída e testada (upgrade + downgrade)
- [ ] Rollback definido: como reverter se der errado
- [ ] Deploy procedure descrita (variáveis novas, ordem de execução)
- [ ] Env vars novas documentadas em .env.example
- [ ] Nenhum breaking change sem versionamento de API
- [ ] Configuração nova documentada (nginx, systemd, docker)
- [ ] Critérios de aceite explícitos (como saber que funcionou)
- [ ] Riscos identificados com mitigações
- [ ] Comunicação necessária (front, mobile, outro time) quando API muda

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + risco de entrega + correção.

### Severidade
- BLOCKER: sem rollback, breaking change sem versionamento, dependência não identificada.
- MAJOR: escopo ambíguo, deploy sem procedure, env var não documentada.
- MINOR: risco sem mitigação.

## Saída em Markdown

```md
### role-delivery

- [OK] Escopo — feature de pedidos com criação e listagem. Fora: cancelamento e webhook. ✓
- [PENDÊNCIA BLOCKER] Rollback — não há procedure para reverter migration em caso de erro.
  Correção: documentar "alembic downgrade -1" + redeploy versão anterior.
...
```

## Regra dura
Plano sem rollback, ou com breaking change sem versionamento, ou com dependência não mapeada, não está pronto para entrega.
