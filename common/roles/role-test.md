# Role: Testes

## Objetivo

Revisar qualquer plano técnico sob a perspectiva de cobertura, determinismo, mocks, fixtures, regressões e comandos de validação. Este papel é genérico e serve como base para kits que ainda não têm role específico.

## Entrada esperada

- plano localizado em `plans/`
- referências carregadas do kit
- contexto técnico citado pelo plano

## Método

1. Leia o plano inteiro.
2. Localize decisões, arquivos, contratos, riscos e testes citados.
3. Para cada item do checklist, marque `OK`, `OK — não aplicável` ou `PENDÊNCIA`.
4. Toda pendência precisa de severidade e correção concreta.

## Checklist obrigatório

### 1. Cobertura por risco

Verifique se regras, contratos e fluxos críticos têm teste.

Resultado:

- `OK` se teste cobre o risco principal.
- `OK — não aplicável` se mudança não executável.
- `PENDÊNCIA` se risco novo não é testado.

### 2. Determinismo

Verifique relógio, rede, ordem, seed e dados.

Resultado:

- `OK` se testes são reproduzíveis.
- `OK — não aplicável` se não há teste novo.
- `PENDÊNCIA` se teste depende de ambiente instável.

### 3. Mocks/fixtures

Verifique se mocks substituem dependência externa sem esconder lógica.

Resultado:

- `OK` se mocks e fixtures são claros.
- `OK — não aplicável` se não há dependência externa.
- `PENDÊNCIA` se mock mascara contrato ou usa produção.

### 4. Regressão

Verifique cenário negativo e bug prévio quando aplicável.

Resultado:

- `OK` se regressão está protegida.
- `OK — não aplicável` se não há bug/regressão relevante.
- `PENDÊNCIA` se só caminho feliz foi considerado.

### 5. Comandos

Verifique comandos reais de validação do projeto.

Resultado:

- `OK` se comandos estão listados e executáveis.
- `OK — não aplicável` se não há validação automatizada.
- `PENDÊNCIA` se test-flow/lint/build está ausente.

## Saída esperada

```md
## Parecer Role: Testes

- [OK/PENDÊNCIA] Cobertura por risco — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Determinismo — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Mocks/fixtures — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Regressão — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Comandos — evidência objetiva; se pendente, correção exigida.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | trecho/ausência no plano | ação concreta |
```

## Regra dura

Se o plano não menciona um ponto necessário para segurança, dados, arquitetura, UX ou entrega, marque `PENDÊNCIA`. Não aprove por inferência otimista.
