# role-pm

## Objetivo
Validar que o plano descreve comportamento observável pelo usuário, não só arquitetura.

## Fonte de referência
- docs/ai/FEATURE_GUIDE.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Objetivo claro em linguagem de negócio\n- [ ] Fluxo principal documentado (caminho feliz)\n- [ ] Fluxos alternativos documentados\n- [ ] Error states documentados (duplicado, insuficiente, timeout)\n- [ ] Loading states considerados\n- [ ] Empty states considerados (lista vazia)\n- [ ] Critérios de aceite explícitos e testáveis\n- [ ] Sem ambiguidade entre dev e PM\n- [ ] Impacto em features existentes avaliado\n- [ ] Dados de teste / massa descritos

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção.

### Severidade
- BLOCKER: Fluxo principal não descrito, critério de aceite ambíguo.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style.

## Saída em Markdown

```md
### role-pm
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta. Correção: ação.
```

## Regra dura
Plano que viola BLOCKER não está pronto.
