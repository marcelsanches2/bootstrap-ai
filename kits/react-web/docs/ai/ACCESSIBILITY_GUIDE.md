# Acessibilidade

## Mínimo obrigatório

- HTML semântico antes de ARIA.
- Botões são botões; links são links.
- Toda ação via mouse deve ser possível por teclado.
- Foco visível e ordem de foco lógica.
- Inputs com label associado.
- Erros de formulário anunciáveis e próximos do campo.
- Contraste suficiente para texto e controles.

## ARIA

Use ARIA para complementar semântica, não para consertar HTML errado.

- `aria-label` quando texto visível não existe.
- `aria-describedby` para ajuda/erro.
- `aria-live` para feedback assíncrono importante.

## Modais/dropdowns

- Trap de foco em modal.
- Escape fecha quando seguro.
- Foco retorna ao gatilho.
- Clique fora não deve destruir dados sem confirmação.

## Testes manuais mínimos

- Navegar com Tab/Shift+Tab.
- Ativar ações com Enter/Espaço.
- Verificar foco após submit/erro/modal.
- Inspecionar labels e nomes acessíveis.

---

## Acessibilidade — checklist de produção

Este guia existe para orientar implementação real em `react-web`. Ele deve ser usado por `/plan`, `/jarvis-revisor`, `/refactor` e `/test-flow` antes de qualquer mudança relevante.

### Princípios

1. **Explícito vence implícito**: decisões importantes devem aparecer no plano ou neste guia.
2. **Falha observável vence falha silenciosa**: toda operação crítica precisa deixar rastro em log, métrica ou teste.
3. **Rollback é parte da feature**: se a mudança altera contrato, dados ou deploy, descreva como voltar.
4. **Teste documenta contrato**: comportamento importante sem teste é comportamento acidental.
5. **Menos dependência é melhor**: biblioteca nova precisa reduzir risco ou complexidade total.

### Áreas de revisão

- **semântica**: declarar regra, exceção permitida e evidência esperada.
- **teclado**: declarar regra, exceção permitida e evidência esperada.
- **contraste**: declarar regra, exceção permitida e evidência esperada.
- **screen readers**: declarar regra, exceção permitida e evidência esperada.
- **forms**: declarar regra, exceção permitida e evidência esperada.

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
