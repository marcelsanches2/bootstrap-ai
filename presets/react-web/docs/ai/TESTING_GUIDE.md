# Guia de Testes React Web

## Camadas

- Unit: funções, formatadores, hooks simples.
- Component: estados visuais, interação e acessibilidade básica.
- Integration: tela com dados mockados.
- E2E: jornada crítica realista.

## O que testar

Para feature de UI, cubra:

- render inicial
- loading
- empty
- error
- success
- interação principal
- cenário negativo relevante
- acessibilidade básica quando possível

## Mocks

- MSW ou equivalente para API quando disponível.
- Mock determinístico, sem depender de rede real.
- Não mockar componente que é justamente o alvo do teste.

## Build e regressão

Mudança grande precisa de build production. Teste unitário não substitui build.

## Comandos típicos

```bash
npm run lint
npm run typecheck
npm test
npm run build
npx playwright test  # quando houver E2E
```

Use os scripts reais do projeto.

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Não mockar o alvo do teste**: nunca mockar o componente/função que é justamente o que está sendo testado.
- **Build production obrigatório para mudança grande**: teste unitário não substitui build; rode `npm run build`.
- **Mocks determinísticos**: testes não devem depender de rede real; use MSW ou equivalente.
- **Cobrir estados de UI**: render, loading, empty, error, success e interação principal devem ser testados.
