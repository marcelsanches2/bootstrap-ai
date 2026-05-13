# Performance Web

## Princípio

Otimize o que afeta experiência ou custo. Não transforme código simples em labirinto por micro-otimização.

## Bundle

- Dependência nova precisa considerar tamanho.
- Use lazy loading para rotas/áreas pesadas.
- Evite importar biblioteca inteira para uma função pequena.

## Renderização

- Evite estado duplicado que força renders desnecessários.
- Virtualize listas grandes.
- Debounce para busca/input que dispara rede.
- Memoização precisa de motivo claro.

## Imagens/assets

- Dimensões definidas quando possível.
- Formato moderno quando o pipeline suporta.
- Lazy load para imagens fora da dobra.
- Não suba asset gigante sem compressão.

## Web Vitals

Mudança que afeta primeira tela deve considerar:

- LCP
- CLS
- INP

## Medição

Quando performance é objetivo da tarefa, o plano deve indicar métrica antes/depois ou ferramenta de validação.

## Aplicações grandes

Quando a aplicação cresce, revise também:

- divisão por rotas/features para reduzir bundle inicial
- cache de server state com invalidação clara
- listas grandes com paginação, infinite loading controlado ou virtualização
- formulários grandes sem renderização global a cada tecla
- provider/context em escopo pequeno para evitar rerender em árvore inteira
- assets e dependências compartilhadas sem duplicação
- observabilidade frontend: erro, rota, versão e Web Vitals quando aplicável

Plano de frontend grande que só fala em componente visual e ignora dados/cache/renderização deve virar pendência em `role-performance`.

---

## Performance — checklist de produção

Este guia existe para orientar implementação real em `react-web`. Ele deve ser usado por `/plan`, `/jarvis-revisor`, `/refactor` e `/test-flow` antes de qualquer mudança relevante.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **bundle**: declarar regra, exceção permitida e evidência esperada.
- **renderização**: declarar regra, exceção permitida e evidência esperada.
- **cache**: declarar regra, exceção permitida e evidência esperada.
- **medição**: declarar regra, exceção permitida e evidência esperada.
- **orçamento**: declarar regra, exceção permitida e evidência esperada.

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
