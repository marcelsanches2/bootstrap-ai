# Role: QA Web

## Sua contribuição
Gera a seção "Testes" do plano, definindo testes unitários, de componente e E2E necessários com ferramentas específicas (Vitest/Jest, Playwright/Cypress).

## Referência
- docs/ai/TESTING_GUIDE.md

## O que incluir

- **Testes unitários**: funções puras, hooks customizados e utilitários. Defina o que testar e o comportamento esperado. Use Vitest ou Jest conforme o projeto.
- **Testes de componente**: componentes React com comportamento — renderização condicional, interações, props. Use Testing Library (RTL) para testar comportamento visível ao usuário, não detalhes de implementação.
- **Testes E2E**: jornadas críticas do usuário com Playwright ou Cypress. Defina o fluxo, pré-condições e asserções. Todo fluxo crítico deve ter E2E ou justificativa explícita.
- **Mocks determinísticos**: APIs mockadas de forma estável com MSW ou equivalente. Testes não devem depender de rede real.
- **Cenários negativos**: erro de API, dados vazios, permissão negada, validação de form — além do caminho feliz.
- **Validação de build**: lint, typecheck e build como gate de qualidade antes/depois da implementação.

## Regras

- Teste comportamento visível ao usuário, não detalhes internos do componente.
- Todo fluxo crítico deve ter E2E — se não tem, justifique.
- Mocks devem ser determinísticos — sem depender de API real ou timing.
- Não ignore cenários negativos — erro, vazio e validação são obrigatórios quando relevantes.
- Scripts de validação (lint, typecheck, build) devem ser comandos explícitos.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Testes

### Validação de build
- Lint: `{comando}`
- Typecheck: `{comando}`
- Build: `{comando}`

### Testes unitários
| Arquivo | O que testa | Casos |
|---------|------------|-------|
| {name}.test.ts | {responsabilidade} | {casos: happy path, edge cases} |

### Testes de componente
| Arquivo | Componente | Comportamentos testados |
|---------|-----------|------------------------|
| {Name}.test.tsx | {Componente} | {renderização, interações, estados} |

### Testes E2E
| Fluxo | Pré-condição | Passos | Asserções |
|-------|-------------|--------|-----------|
| {nome do fluxo} | {estado inicial} | {passos do usuário} | {o que verifica} |

### Mocks
| API/Recurso | Ferramenta | Comportamento mockado |
|-------------|-----------|----------------------|
| {endpoint} | {MSW / handler} | {resposta simulada} |

### Cenários negativos
| Cenário | Onde testa | Resultado esperado |
|---------|-----------|-------------------|
| erro de API | {teste} | {UI de erro + retry} |
| dados vazios | {teste} | {empty state} |
| validação | {teste} | {mensagem de erro} |
```
