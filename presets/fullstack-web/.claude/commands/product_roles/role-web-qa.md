# Role: QA Web

## Sua contribuição
Gera a seção "Testes frontend" do plano, definindo testes unit/component, E2E, mocks e cenários negativos para o frontend.

## Referência
- docs/ai/TESTING_GUIDE.md

## O que incluir
- **Unit/component**: funções, hooks e componentes com comportamento — cada lógica/UI relevante tem teste. Descreva arquivo de teste, o que testa e ferramenta (Vitest/Jest/RTL).
- **E2E**: jornadas críticas cobertas com Playwright/Cypress. Fluxo que não pode depender de teste manual.
- **Mocks determinísticos**: API mockada de forma estável (MSW, handler, fixture). Teste nunca depende de rede real.
- **Cenários negativos**: erro, vazio, permissão e validação testados. Não apenas caminho feliz.
- **Build/typecheck/lint**: scripts de validação previstos e comandos listados.

## Regras
- Jornada crítica sem E2E (e sem justificativa) é bloqueante.
- Teste que depende de rede real é bloqueante.
- Só caminho feliz testado é pendência.
- Se a task não tem UI/lógica frontend testável: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Testes — Frontend

### Unit/component
| Arquivo | Testa | Ferramenta |
|---|---|---|
| {caminho} | {comportamento} | {vitest/jest/RTL} |

### E2E
| Jornada | Arquivo | Criticidade |
|---|---|---|
| {descrição do fluxo} | {caminho} | {crítica/alta/média} |

### Mocks
| API/dado | Estratégia | Arquivo |
|---|---|---|
| {endpoint/dado} | {MSW/fixture/handler} | {caminho} |

### Cenários negativos
| Cenário | Teste | Arquivo |
|---|---|---|
| {erro/vazio/permissão} | {o que verifica} | {caminho} |

### Validação de build
- [ ] `typecheck` — {comando}
- [ ] `lint` — {comando}
- [ ] `build` — {comando}
```
