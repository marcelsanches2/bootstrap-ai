# Role: Segurança

## Objetivo

Revisar planos sob a perspectiva de auth, autorização, secrets, validação de input, dados sensíveis e abuso.

## Checklist

### 1. AuthN/AuthZ

Identidade e permissão por recurso?

- `OK` — acesso protegido corretamente.
- `OK — não aplicável` — operação não protegida/exposta.
- `PENDÊNCIA` — permissão ausente ou genérica.

### 2. Input

Validação de formato e significado?

- `OK` — input inválido rejeitado.
- `OK — não aplicável` — não há input externo.
- `PENDÊNCIA` — input pode quebrar regra ou persistir lixo.

### 3. Secrets

`.env`, tokens, chaves, credenciais?

- `OK` — segredos fora de git/log/teste real.
- `OK — não aplicável` — não há segredo novo.
- `PENDÊNCIA` — segredo pode vazar.

### 4. Dados sensíveis

PII, logs, responses, dumps?

- `OK` — dados sensíveis minimizados/mascarados.
- `OK — não aplicável` — não há dado sensível.
- `PENDÊNCIA` — plano expõe dado sensível.

### 5. Abuso

Brute force, endpoint caro, upload, automação maliciosa?

- `OK` — abuso considerado.
- `OK — não aplicável` — operação não exposta/cara.
- `PENDÊNCIA` — fluxo abusável sem limite.
