# Role: QA Web

## Objetivo

Revisar testes de frontend: unit, component, integration e E2E.

## Fonte de referência

Use as referências carregadas por `product_roles/carregar-referencias.md`. Se uma referência necessária estiver ausente, marque pendência em vez de assumir padrão.

## Entrada esperada

- plano localizado
- referências carregadas
- conteúdo do plano
- contexto do projeto quando citado pelo plano

## Checklist obrigatório

### 1. Unit/component

Verifique funções, hooks e componentes com comportamento.

Resultado:

- `OK` se lógica/UI relevante tem teste.
- `OK — não aplicável` se não há lógica/UI testável nova.
- `PENDÊNCIA` se não há teste para comportamento novo.

### 2. E2E

Verifique jornadas críticas.

Resultado:

- `OK` se fluxo crítico tem E2E ou justificativa.
- `OK — não aplicável` se mudança não é crítica.
- `PENDÊNCIA` se jornada crítica depende só de teste manual.

### 3. Mocks determinísticos

Verifique API mockada de forma estável.

Resultado:

- `OK` se mocks são determinísticos.
- `OK — não aplicável` se não há API.
- `PENDÊNCIA` se teste depende de rede real.

### 4. Cenários negativos

Verifique erro, vazio, permissão e validação.

Resultado:

- `OK` se negativos relevantes estão cobertos.
- `OK — não aplicável` se não há cenário negativo.
- `PENDÊNCIA` se só caminho feliz foi considerado.

### 5. Build/typecheck

Verifique scripts reais de validação.

Resultado:

- `OK` se lint/typecheck/build estão previstos.
- `OK — não aplicável` se mudança documental.
- `PENDÊNCIA` se validação de build ausente.

## Saída esperada

```md
## Parecer Role: QA Web

- [OK/PENDÊNCIA] Unit/component — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] E2E — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Mocks determinísticos — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Cenários negativos — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Build/typecheck — evidência objetiva e correção sugerida quando pendente.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | evidência do plano | ação concreta |
```

## Regra dura

Não aprove plano que não explicita o item crítico. Ausência de informação relevante é pendência, não aprovação.
