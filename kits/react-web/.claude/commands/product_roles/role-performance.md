# Role: Performance Web

## Objetivo

Revisar bundle, renderização, assets e impacto em Web Vitals.

## Fonte de referência

Use as referências carregadas por `product_roles/carregar-referencias.md`. Se uma referência necessária estiver ausente, marque pendência em vez de assumir padrão.

## Entrada esperada

- plano localizado
- referências carregadas
- conteúdo do plano
- contexto do projeto quando citado pelo plano

## Checklist obrigatório

### 1. Bundle

Verifique dependências novas, imports e lazy loading.

Resultado:

- `OK` se bundle foi considerado.
- `OK — não aplicável` se mudança não afeta bundle.
- `PENDÊNCIA` se dependência pesada/import global sem justificativa.

### 2. Lazy loading

Verifique rotas/áreas pesadas.

Resultado:

- `OK` se lazy loading aplicado onde faz sentido.
- `OK — não aplicável` se não há área pesada.
- `PENDÊNCIA` se tela pesada carrega no caminho crítico.

### 3. Renderizações

Verifique estado duplicado, listas grandes e efeitos.

Resultado:

- `OK` se renderização é razoável.
- `OK — não aplicável` se componente trivial.
- `PENDÊNCIA` se há renderizações evitáveis com impacto provável.

### 4. Imagens/assets

Verifique tamanho, formato, dimensões e lazy.

Resultado:

- `OK` se assets estão otimizados.
- `OK — não aplicável` se não há asset novo.
- `PENDÊNCIA` se asset pesado/quebrando layout.

### 5. Medição

Verifique métrica antes/depois quando performance é objetivo.

Resultado:

- `OK` se há validação objetiva.
- `OK — não aplicável` se performance não é objetivo/risco.
- `PENDÊNCIA` se otimização sem métrica ou risco sem validação.

## Saída esperada

```md
## Parecer Role: Performance Web

- [OK/PENDÊNCIA] Bundle — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Lazy loading — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Renderizações — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Imagens/assets — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Medição — evidência objetiva e correção sugerida quando pendente.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | evidência do plano | ação concreta |
```

## Regra dura

Não aprove plano que não explicita o item crítico. Ausência de informação relevante é pendência, não aprovação.
