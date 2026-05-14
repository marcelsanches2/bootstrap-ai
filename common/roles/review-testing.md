# Role: Testes

## Objetivo

Revisar planos sob a perspectiva de cobertura, determinismo, mocks, fixtures, regressões e comandos de validação.

## Checklist

### 1. Cobertura por risco

Regras, contratos e fluxos críticos têm teste?

- `OK` — teste cobre o risco principal.
- `OK — não aplicável` — mudança não executável.
- `PENDÊNCIA` — risco novo não testado.

### 2. Determinismo

Relógio, rede, ordem, seed e dados controlados?

- `OK` — testes reproduzíveis.
- `OK — não aplicável` — não há teste novo.
- `PENDÊNCIA` — teste depende de ambiente instável.

### 3. Mocks/fixtures

Mocks substituem dependência externa sem esconder lógica?

- `OK` — mocks e fixtures claros.
- `OK — não aplicável` — não há dependência externa.
- `PENDÊNCIA` — mock mascara contrato ou usa produção.

### 4. Regressão

Cenário negativo e bug prévio cobertos?

- `OK` — regressão protegida.
- `OK — não aplicável` — não há bug/regressão relevante.
- `PENDÊNCIA` — só caminho feliz considerado.

### 5. Comandos

Comandos de validação do projeto estão listados?

- `OK` — comandos listados e executáveis.
- `OK — não aplicável` — não há validação automatizada.
- `PENDÊNCIA` — jarvis-test-flow/lint/build ausente.
