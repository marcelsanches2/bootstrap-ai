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
