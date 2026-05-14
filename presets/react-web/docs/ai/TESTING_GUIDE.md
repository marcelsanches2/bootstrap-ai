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

---

## Estratégia de testes — checklist de produção

Este guia existe para orientar implementação real em `react-web`. Ele deve ser usado por `/plan`, `/jarvis-plan-revisor`, `/refactor` e `/jarvis-test-flow` antes de qualquer mudança relevante.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **pirâmide de testes**: declarar regra, exceção permitida e evidência esperada.
- **fixtures**: declarar regra, exceção permitida e evidência esperada.
- **mocks**: declarar regra, exceção permitida e evidência esperada.
- **contratos**: declarar regra, exceção permitida e evidência esperada.
- **regressão**: declarar regra, exceção permitida e evidência esperada.

### Regras específicas para frontend React/TypeScript

- Use o runtime esperado: React, TypeScript, Vite/Next quando presentes, TanStack Query/Zustand/Router quando presentes.
- Não introduza framework paralelo sem justificar migração e custo de manutenção.
- Padronize validação na borda do sistema; dentro do domínio, trabalhe com tipos já confiáveis.
- Trate erro com categoria operacional: entrada inválida, regra de negócio, dependência externa, bug interno ou indisponibilidade.
- Centralize configuração por ambiente e mantenha secrets fora do repositório.
- Prefira funções pequenas com contrato claro a helpers genéricos difíceis de testar.
- Evite estado global mutável; quando inevitável, documente ciclo de vida e concorrência.
- Registre decisões que afetem deploy, segurança, dados ou compatibilidade em `plans/`.

### Validação mínima

Antes de considerar uma mudança pronta, execute ou justifique por que não executou:

```bash
npm run typecheck && npm test && npm run build quando configurado
```

Além disso:

- [ ] Teste unitário cobre regra de negócio principal.
- [ ] Teste de integração cobre fronteira externa relevante.
- [ ] Caso de erro previsível tem teste ou simulação.
- [ ] Build/typecheck passa sem warnings novos relevantes.
- [ ] Documentação alterada quando contrato ou operação mudou.

### Revisão de risco

Classifique cada mudança antes de implementar:

- **Baixo risco**: arquivo isolado, sem contrato externo, sem estado persistente.
- **Médio risco**: altera fluxo, API interna, componente compartilhado ou configuração.
- **Alto risco**: altera schema, autenticação, autorização, pagamento, deploy, cache, fila, storage ou contrato público.

Para risco alto, o plano precisa conter:

- sequência de deploy;
- rollback;
- migração/backfill quando aplicável;
- métrica ou log para confirmar sucesso;
- teste de regressão;
- responsável por validar produção.

### Anti-patterns bloqueantes

- Capturar exceção genérica e continuar sem log estruturado.
- Criar abstração antes de existir segundo uso real.
- Misturar validação de entrada, regra de negócio e acesso externo no mesmo bloco.
- Depender de ordem implícita de execução sem teste.
- Adicionar dependência que só economiza poucas linhas de código trivial.
- Fazer mudança de schema sem rollback ou sem compatibilidade temporária.
- Usar dado real em teste automatizado.
- Commitar `.env`, token, dump, fixture sensível ou configuração local.

### Como o Jarvis deve usar este guia

Ao revisar um plano, o Jarvis deve produzir achados com:

```md
- Evidência: arquivo/seção do plano
- Violação: regra deste guia
- Impacto: risco concreto
- Correção: alteração objetiva
- Validação: comando ou teste esperado
```

Comentário sem evidência deve ser descartado.
