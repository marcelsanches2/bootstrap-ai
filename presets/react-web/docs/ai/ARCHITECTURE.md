# Arquitetura React Web

## Objetivo

Organizar UI, estado, data fetching e regras de apresentação sem transformar cada tela em framework próprio.

## Estrutura recomendada

```txt
src/
  app/
    routes/
    providers/
    config/
  shared/
    components/
    hooks/
    utils/
    api/
    styles/
  features/
    billing/
      components/
      hooks/
      api/
      model/
      pages/
      tests/
```

Adapte ao framework. Em Next.js, respeite `app/`/`pages/`, mas preserve boundaries por feature.

## Componentes

- Page/container coordena dados e layout de alto nível.
- Componentes de UI recebem props explícitas.
- Componentes puros não chamam API diretamente.
- Hooks encapsulam data fetching, eventos e integração com browser.

## Data fetching

- Centralize client HTTP e tratamento de erro.
- Use TanStack Query ou padrão equivalente para cache/server state.
- Não confunda server state com estado global client-side.
- Defina loading, error, empty e retry.

## Estado

- `useState/useReducer`: estado local.
- URL/search params: filtros e estado navegável.
- TanStack Query: dados remotos/cache.
- Zustand/Redux/context: estado global real e raro.

## Rotas

- Rotas públicas/protegidas precisam estar explícitas.
- Tela nova deve declarar path, params e comportamento de navegação.
- Não use strings soltas repetidas quando houver mapa de rotas.

## Erros

- Erro de API deve virar estado renderizável.
- Boundary de erro deve existir em áreas críticas.
- Mensagem técnica não deve vazar para usuário final.

## Anti-patterns

- Componente de 500 linhas fazendo fetch, regra, layout e formatação.
- `useEffect` para derivar estado que poderia ser calculado.
- Context global para evitar passar duas props.
- API client duplicado por feature sem motivo.

---

## Arquitetura operacional — checklist de produção

Este guia existe para orientar implementação real em `react-web`. Ele deve ser usado por `/plan`, `/jarvis-plan-revisor`, `/refactor` e `/jarvis-test-flow` antes de qualquer mudança relevante.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **camadas**: declarar regra, exceção permitida e evidência esperada.
- **dependências permitidas**: declarar regra, exceção permitida e evidência esperada.
- **fronteiras de domínio**: declarar regra, exceção permitida e evidência esperada.
- **pontos de extensão**: declarar regra, exceção permitida e evidência esperada.
- **anti-patterns**: declarar regra, exceção permitida e evidência esperada.

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
