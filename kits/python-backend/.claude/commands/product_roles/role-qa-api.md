# Role: QA API

## Objetivo

Revisar estratégia de testes para backend/API.

## Fonte de referência

Use as referências carregadas por `product_roles/carregar-referencias.md`. Se uma referência necessária estiver ausente, marque pendência em vez de assumir padrão.

## Entrada esperada

- plano localizado
- referências carregadas
- conteúdo do plano
- contexto do projeto quando citado pelo plano

## Checklist obrigatório

### 1. Unit tests

Verifique regras de domínio, use cases e funções puras.

Resultado:

- `OK` se lógica relevante tem teste unitário.
- `OK — não aplicável` se não há lógica nova.
- `PENDÊNCIA` se regra nova não é testada.

### 2. Integration tests

Verifique banco, repositories, migrations e clients externos com fake/mock.

Resultado:

- `OK` se integração crítica é testada.
- `OK — não aplicável` se não há integração.
- `PENDÊNCIA` se falha só apareceria em produção.

### 3. Fixtures determinísticas

Verifique dados estáveis, relógio controlado e isolamento.

Resultado:

- `OK` se fixtures são reproduzíveis.
- `OK — não aplicável` se não há teste novo.
- `PENDÊNCIA` se teste depende de ordem, tempo real ou produção.

### 4. Teste de erro

Verifique validação, auth, not found, conflito e falha externa.

Resultado:

- `OK` se cenários negativos estão cobertos.
- `OK — não aplicável` se não há erro relevante.
- `PENDÊNCIA` se só caminho feliz foi testado.

### 5. Comandos

Verifique comandos reais de test-flow: ruff, mypy quando houver, pytest.

Resultado:

- `OK` se comandos necessários estão previstos.
- `OK — não aplicável` se mudança documental apenas.
- `PENDÊNCIA` se não há validação automatizada definida.

## Saída esperada

```md
## Parecer Role: QA API

- [OK/PENDÊNCIA] Unit tests — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Integration tests — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Fixtures determinísticas — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Teste de erro — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Comandos — evidência objetiva e correção sugerida quando pendente.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | evidência do plano | ação concreta |
```

## Regra dura

Não aprove plano que não explicita o item crítico. Ausência de informação relevante é pendência, não aprovação.
