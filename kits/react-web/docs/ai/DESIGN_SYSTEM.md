# Design System

## Objetivo

Garantir consistência visual e reduzir retrabalho sem bloquear evolução do produto.

## Tokens

Use tokens centralizados para:

- cor
- tipografia
- espaçamento
- raio
- sombra
- z-index
- breakpoints

Valor hardcoded só é aceitável se o projeto ainda não tem token correspondente e o plano propõe consolidar depois.

## Componentes

Componentes reutilizáveis devem ter:

- estados: default, hover, focus, disabled, loading, error quando aplicável
- variações nomeadas por intenção, não por cor solta
- acessibilidade embutida
- API de props simples

## Layout

- Mobile, tablet e desktop quando aplicável.
- Não assuma uma única largura.
- Defina comportamento de overflow, truncamento e empty states.

## UX states

Toda tela/fluxo assíncrono precisa decidir:

- loading
- empty
- error
- success
- permission denied quando aplicável

## Regra visual

Não aceite UI "funcional mas feia" em entrega de produto. Se o plano não define visual suficiente para implementar com qualidade, marque pendência.

---

## Design system — checklist de produção

Este guia existe para orientar implementação real em `react-web`. Ele deve ser usado por `/plan`, `/jarvis-revisor`, `/refactor` e `/test-flow` antes de qualquer mudança relevante.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **tokens**: declarar regra, exceção permitida e evidência esperada.
- **componentes**: declarar regra, exceção permitida e evidência esperada.
- **layout**: declarar regra, exceção permitida e evidência esperada.
- **estados**: declarar regra, exceção permitida e evidência esperada.
- **responsividade**: declarar regra, exceção permitida e evidência esperada.

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
