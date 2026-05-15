# role-delivery

## Objetivo
Validar que o plano é implementável sem surpresas.

## Fonte de referência
- docs/ai/DEPLOYMENT_GUIDE.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Escopo claro: o que entra e o que NÃO entra\n- [ ] Arquivos listados com caminho completo\n- [ ] Dependências externas identificadas\n- [ ] Migration incluída e testada\n- [ ] Rollback definido\n- [ ] Deploy procedure descrita\n- [ ] Env vars novas documentadas em .env.example\n- [ ] Sem breaking change sem versionamento\n- [ ] Critérios de aceite explícitos\n- [ ] Riscos identificados com mitigações

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção.

### Severidade
- BLOCKER: Sem rollback, breaking change sem versionamento, dependência não mapeada.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style.

## Saída em Markdown

```md
### role-delivery
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta. Correção: ação.
```

## Regra dura
Plano que viola BLOCKER não está pronto.
