# role-pm

## Objetivo
Validar que o plano descreve comportamento observável pelo usuário, não só arquitetura técnica.

## Fonte de referência
- `docs/ai/FEATURE_GUIDE.md`
- `docs/ai/API_GUIDE.md`

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Verificar se o plano cobre todos os fluxos que o usuário final experimenta, incluindo estados intermediários e de erro.

## Checklist obrigatório

- [ ] Objetivo claro em linguagem de negócio (não técnica)
- [ ] Fluxo principal documentado (caminho feliz)
- [ ] Fluxos alternativos documentados (ex: login com provider diferente)
- [ ] Error states documentados (ex: email duplicado, saldo insuficiente, timeout)
- [ ] Loading states considerados (ex: processamento de pagamento assíncrono)
- [ ] Empty states considerados (ex: lista vazia de pedidos)
- [ ] Critérios de aceite explícitos e testáveis
- [ ] Não há ambiguidade que gere interpretação diferente entre dev e PM
- [ ] Impacto em features existentes avaliado
- [ ] Dados de teste / massa necessários descritos

## Resultado esperado por item

- **OK**: evidência.
- **OK — não aplicável**: explique.
- **PENDÊNCIA**: severidade + ambiguidade + correção.

### Severidade
- BLOCKER: fluxo principal não descrito, critério de aceite ambíguo.
- MAJOR: error state não tratado, empty state não considerado.
- MINOR: loading state faltando.

## Saída em Markdown

```md
### role-pm

- [OK] Fluxo principal — usuário cria pedido, vê confirmação com status "pending". ✓
- [PENDÊNCIA MAJOR] Error state — email duplicado não especificado no fluxo de registro.
  Correção: documentar "mostrar erro 'Email já cadastrado' com link para login".
...
```

## Regra dura
Plano que não descreve o comportamento esperado do ponto de vista do usuário, ou com critérios de aceite ambíguos, não está pronto.
