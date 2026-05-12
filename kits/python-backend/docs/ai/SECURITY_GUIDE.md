# Guia de Segurança

## Princípios

- Autenticação prova identidade.
- Autorização prova permissão para aquele recurso.
- Validação de input ocorre na borda e regra crítica no domínio/aplicação.
- Segredo nunca vai para git, log, response ou teste fixture real.

## AuthN/AuthZ

- Endpoint protegido deve declarar dependência de autenticação.
- Permissão deve ser checada por recurso, não só por papel global.
- `user_id` vindo do path/body não substitui identidade autenticada.
- Admin bypass precisa ser explícito e testado.

## Input

- Schemas Pydantic validam formato.
- Regras de negócio validam significado.
- Normalize strings quando unicidade depende disso.
- Defina limite de tamanho para campos livres/upload.

## Secrets

- `.env` real no `.gitignore`.
- Rotação possível sem mudança de código.
- Testes usam segredo fake.

## Logs e PII

Nunca logar:

- Authorization header
- cookie/session id
- senha/token/API key
- documento, cartão, dados financeiros sensíveis sem mascaramento

## Dependências

- Nova lib de auth/crypto precisa justificativa forte.
- Não implemente criptografia caseira.
- Hash de senha deve usar algoritmo apropriado como argon2/bcrypt via lib madura.

## Checklist de revisão

- AuthN/AuthZ testados.
- Validação negativa testada.
- Erros não vazam detalhe sensível.
- Secrets fora do git.
- Operação sensível tem log seguro/auditável.
