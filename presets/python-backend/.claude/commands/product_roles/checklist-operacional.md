# Checklist operacional

Verificação transversal que nenhum role individual cobre sozinho. Aplique uma vez, depois dos pareceres por papel.

## Perguntas transversais

- [ ] Existe caminho incremental ou o plano é uma mudança grande única?
- [ ] O plano define rollback ou mitigação se o deploy quebrar?
- [ ] Migrações, contratos ou flags têm ordem segura de aplicação?
- [ ] A solução mantém simplicidade operacional para alguém debugar às 2h?

Se nenhuma pergunta se aplica à mudança, registre:

```md
OK — nenhum risco operacional transversal identificado.
```
