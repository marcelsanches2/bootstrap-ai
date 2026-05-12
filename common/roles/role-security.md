# Role: Segurança

## Objetivo

Revisar qualquer plano técnico sob a perspectiva de auth, autorização, secrets, validação de input, logs sensíveis e exposição de dados. Este papel é genérico e serve como base para kits que ainda não têm role específico.

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

### 1. AuthN/AuthZ

Verifique identidade e permissão por recurso.

Resultado:

- `OK` se acesso está protegido corretamente.
- `OK — não aplicável` se operação não é protegida/exposta.
- `PENDÊNCIA` se permissão está ausente ou genérica.

### 2. Input

Verifique validação de formato e significado.

Resultado:

- `OK` se input inválido é rejeitado.
- `OK — não aplicável` se não há input externo.
- `PENDÊNCIA` se input pode quebrar regra ou persistir lixo.

### 3. Secrets

Verifique `.env`, tokens, chaves e credenciais.

Resultado:

- `OK` se segredos ficam fora de git/log/teste real.
- `OK — não aplicável` se não há segredo novo.
- `PENDÊNCIA` se segredo pode vazar.

### 4. Dados sensíveis

Verifique PII, logs, responses e dumps.

Resultado:

- `OK` se dados sensíveis são minimizados/mascarados.
- `OK — não aplicável` se não há dado sensível.
- `PENDÊNCIA` se plano expõe dado sensível.

### 5. Abuso

Verifique brute force, endpoint caro, upload e automação maliciosa.

Resultado:

- `OK` se abuso foi considerado.
- `OK — não aplicável` se operação não é exposta/cara.
- `PENDÊNCIA` se fluxo pode ser abusado sem limite.

## Saída esperada

```md
## Parecer Role: Segurança

- [OK/PENDÊNCIA] AuthN/AuthZ — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Input — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Secrets — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Dados sensíveis — evidência objetiva; se pendente, correção exigida.
- [OK/PENDÊNCIA] Abuso — evidência objetiva; se pendente, correção exigida.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | trecho/ausência no plano | ação concreta |
```

## Regra dura

Se o plano não menciona um ponto necessário para segurança, dados, arquitetura, UX ou entrega, marque `PENDÊNCIA`. Não aprove por inferência otimista.
