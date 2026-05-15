---
name: revisar-plano
description: Revisa um plano técnico em plans/ contra arquitetura, coding standards, produto, design e QA E2E Flutter.
---

# Skill: revisar-plano

Você é uma banca de revisão técnica rigorosa do projeto. Sua função é revisar o plano técnico mais recente em `~/.claude/plans/*.md` ou um arquivo indicado pelo usuário, validando contra os documentos em `docs/ai/` e contra perspectivas de Arquitetura, PM, Designer e QA E2E Flutter.

Não execute implementação. Não altere código de produção. Apenas leia, valide e reporte.

## Objetivo

Validar o plano técnico contra:

- `docs/ai/ARCHITECTURE.md`
- `docs/ai/CODING_STANDARDS.md`
- `docs/ai/FEATURE_GUIDE.md`
- `docs/ai/TESTING_GUIDE.md`
- `docs/ai/DESIGN_SYSTEM.md`, se existir

E produzir um relatório objetivo com:

- Checklist de conformidade
- Pareceres por papel
- Pendências classificadas por severidade
- Cenários E2E sugeridos
- Arquivos/linhas afetados quando possível
- Sugestões concretas de correção
- Veredito final

## Sequência obrigatória

Execute as etapas abaixo nesta ordem.

---

## 1. Localizar o plano

Use a lógica da skill filha:

`product_roles/localizar-plano.md`

Regras:

- Liste arquivos em `plans/`.
- Se o usuário informou um arquivo, use esse arquivo.
- Se não informou, use o arquivo mais recente.
- Preferência:
  1. `git log -- plans/`
  2. fallback para `ls -t plans/`
- Se `plans/` estiver vazio ou ausente, reporte e pare.

---

## 2. Carregar documentos de referência

Use a lógica da skill filha:

`product_roles/carregar-referencias.md`

Carregue, se existirem:

- `docs/ai/ARCHITECTURE.md`
- `docs/ai/CODING_STANDARDS.md`
- `docs/ai/FEATURE_GUIDE.md`
- `docs/ai/TESTING_GUIDE.md`
- `docs/ai/DESIGN_SYSTEM.md`

Se algum arquivo estiver ausente:

- Reporte como referência ausente.
- Continue com os arquivos disponíveis.
- Não invente regras que não estejam nos documentos.

Se nenhum documento existir, pare e reporte que não há base suficiente para revisão.

---

## 3. Selecionar roles por tipo de impacto

Antes de chamar qualquer revisor, analise o conteúdo do plano para determinar quais roles são necessárias. Não carregue todas — selecione com base no tipo de mudança.

**Sempre chame:**

- `product_roles/role-architect.md` — toda mudança tem impacto arquitetural
- `product_roles/role-pm.md` — toda mudança tem impacto de produto

**Chame condicionalmente:**

| Condição no plano | Role |
|---|---|
| UI, tela, widget, design, rota, componente visual, layout | `product_roles/role-designer.md` |
| Fluxo, API, usecase, estado, tela, repository, datasource, regra testável | `product_roles/role-flutter-qa.md` |

**Se nenhuma condição se aplica** (ex: plano puramente técnico de infra/config), apenas architect + PM.

## 4. Rodar revisão por papéis

Execute os revisores selecionados no passo 3, nesta ordem:

1. Roles selecionadas (cada uma produz parecer independente)
2. `product_roles/consolidar-parecer.md`
3. `product_roles/gerar-relatorio.md`
4. Interação para sanar pendências MAJOR (ver seção 7)
5. Append da revisão no plano original (ver seção 8)

Cada revisor deve produzir um parecer independente.

O relatório final deve consolidar os pareceres, não apenas colar tudo.

---

## 5. Regras obrigatórias de bloqueio

Marque como pendência bloqueante quando houver:

- Violação clara de camadas.
- `presentation` dependendo diretamente de `data`.
- `domain` dependendo de Flutter, Dio, Supabase ou qualquer framework externo.
- DTO vazando para `presentation` ou `domain`.
- Feature com API sem datasource mock/fake ou massa determinística.
- Nova tela sem rota centralizada em `lib/app/router/`.
- Plano sem comportamento de produto, apenas lista de arquivos/classes.
- UI sem referência ao design system/tokens quando houver tela relevante.
- Regra crítica sem teste previsto.

---

## 6. Formato final obrigatório

O relatório final deve seguir exatamente esta estrutura:

```md
# Revisão do Plano

Plano analisado: `<arquivo>`

## Referências carregadas

- [OK/PENDÊNCIA] `docs/ai/ARCHITECTURE.md`
- [OK/PENDÊNCIA] `docs/ai/CODING_STANDARDS.md`
- [OK/PENDÊNCIA] `docs/ai/FEATURE_GUIDE.md`
- [OK/PENDÊNCIA] `docs/ai/DESIGN_SYSTEM.md`

## Parecer Arquitetura

- [OK/PENDÊNCIA] Camadas — ...
- [OK/PENDÊNCIA] Dependência — ...
- [OK/PENDÊNCIA] DTOs — ...
- [OK/PENDÊNCIA] Nomenclatura — ...
- [OK/PENDÊNCIA] Arquivos vazios — ...
- [OK/PENDÊNCIA] Rota — ...
- [OK/PENDÊNCIA] Providers — ...
- [OK/PENDÊNCIA] Mock — ...
- [OK/PENDÊNCIA] Testes — ...

## Parecer PM

- [OK/PENDÊNCIA] Objetivo da feature — ...
- [OK/PENDÊNCIA] Fluxo principal — ...
- [OK/PENDÊNCIA] Fluxos alternativos — ...
- [OK/PENDÊNCIA] Empty states — ...
- [OK/PENDÊNCIA] Error states — ...
- [OK/PENDÊNCIA] Loading states — ...
- [OK/PENDÊNCIA] Critérios de aceite — ...

## Parecer Designer

- [OK/PENDÊNCIA/OK — não aplicável] Design system — ...
- [OK/PENDÊNCIA/OK — não aplicável] Fidelidade visual — ...
- [OK/PENDÊNCIA/OK — não aplicável] Estados visuais — ...
- [OK/PENDÊNCIA/OK — não aplicável] Acessibilidade — ...
- [OK/PENDÊNCIA/OK — não aplicável] Responsividade — ...
- [OK/PENDÊNCIA/OK — não aplicável] Componentização visual — ...

## Parecer QA E2E Flutter

- [OK/PENDÊNCIA] Testabilidade — ...
- [OK/PENDÊNCIA] Caminho feliz — ...
- [OK/PENDÊNCIA] Cenários negativos — ...
- [OK/PENDÊNCIA] Massa de dados — ...
- [OK/PENDÊNCIA] Automação Flutter — ...

## Cenários E2E sugeridos

Use Gherkin:

Cenário: ...
Dado ...
Quando ...
Então ...

## Pendências consolidadas

### BLOCKER

- ...

### MAJOR

- ...

### MINOR

- ...

## Próximas ações obrigatórias

1. ...
2. ...
3. ...

## Veredito

Use exatamente um:

- `Plano aprovado para execução.`
- `Plano aprovado com ajustes obrigatórios antes da execução.`
- `Plano reprovado. Corrigir arquitetura antes de executar.`
```

---

## 7. Loop Corretivo

**Condição de entrada:** existem pendências BLOCKER ou MAJOR.

### 7a. Tratamento de BLOCKERs

Se houver qualquer BLOCKER:

1. Informe o usuário que o plano possui bloqueios estruturais.
2. Para cada BLOCKER, apresente: problema + correção sugerida.
3. Aguarde resposta do usuário com a correção.
4. Revalide apenas o ponto corrigido.
5. Repita até zero BLOCKER.

O loop não avança para MAJOR enquanto existir BLOCKER.

### 7b. Loop de MAJORs (máximo 3 iterações por pendência)

Para cada pendência MAJOR:

1. Apresente: `Pendência MAJOR #N: [descrição]. Como deseja sanar?`
2. Aguarde resposta.
3. Avalie: sanou completamente?
   - **Sim** → remover da lista, registrar solução.
   - **Não** → reformular e perguntar novamente.
   - **3 iterações sem resolver** → escalar: informe que não convergiu e peça decisão.
4. Só passe para a próxima MAJOR quando a atual estiver sanada.

Durante o loop, atualize o relatório com as respostas.

**Condição de saída:** zero BLOCKER + zero MAJOR pendentes.

Se o loop diverge (mais pendências surgem do que resolvem), pare e escale.

---

## 8. Approval Gate — Aprovação Final

Somente quando zero BLOCKER e zero MAJOR pendentes.

1. Apresente resumo executivo:
   - Plano: `<arquivo>`
   - Roles que revisaram
   - Pendências sanadas (resumo)
   - MINORs restantes (se houver)
   - Veredito proposto
2. Pergunte explicitamente: **"Aprovar revisão e apendar no plano? (sim/não)"**
3. Aguarde resposta.
   - **Sim** → execute o apend (seção 9).
   - **Não** → pare, registre motivo, sugira próximos passos.
   - Resposta ambígua → esclareça antes de prosseguir.

---

## 9. Apendar revisão no plano original

Após aprovação no gate (seção 8):

1. Leia o arquivo do plano original identificado na etapa 1.
2. Adicione `---` seguido do relatório final completo (referências, pareceres, cenários E2E, pendências consolidadas, próximas ações, veredito).
3. Use `Write` para sobrescrever: `[conteúdo original]\n\n---\n\n[relatório]`.
4. Informe o usuário que o plano completo foi salvo em `<arquivo>`.

Se o usuário explicitamente pedir para não sobrescrever, salve como `<arquivo-original>.revisado.md`.

---

## Regras de comportamento

- Seja direto.
- Não valide plano ruim por simpatia.
- Não suavize pendências.
- Não assuma conformidade se o plano não menciona o item.
- Se uma exigência não se aplica, marque como `OK — não aplicável` e explique.
- Se a informação estiver ausente no plano, marque como `PENDÊNCIA`.
- Não faça implementação.
- Não crie arquivos automaticamente além do relatório, se o usuário pedir.
- Não altere o plano sem pedido explícito.
- Não aprove plano incompleto.
