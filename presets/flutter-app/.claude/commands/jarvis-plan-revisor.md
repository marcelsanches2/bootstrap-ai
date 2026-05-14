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
- `docs/ai/DESIGN_SYSTEM.md`

Se algum arquivo estiver ausente:

- Reporte como referência ausente.
- Continue com os arquivos disponíveis.
- Não invente regras que não estejam nos documentos.

Se nenhum documento existir, pare e reporte que não há base suficiente para revisão.

---

## 3. Rodar revisão por papéis

Depois de carregar o plano e referências, execute os revisores abaixo:

1. `product_roles/role-architect.md`
2. `product_roles/role-pm.md`
3. `product_roles/role-designer.md`, se houver UI, tela, widget, design ou rota
4. `product_roles/role-flutter-qa.md`, se houver fluxo, API, usecase, estado, tela, repository, datasource ou regra testável
5. `product_roles/consolidar-parecer.md`
6. `product_roles/gerar-relatorio.md`
7. Interacao para sanar pendencias MAJOR (ver secao 7)
8. Append da revisao no plano original (ver secao 8)

Cada revisor deve produzir um parecer independente.

O relatório final deve consolidar os pareceres, não apenas colar tudo.

---

## 4. Regras obrigatórias de bloqueio

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

## 5. Formato final obrigatório

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

## 7. Sanar pendências MAJOR (interativo)

Após gerar o relatório e a consolidação:

- Se houver **qualquer BLOCKER**:
  - Informe o usuário que o plano possui bloqueios estruturais que impedem aprovação.
  - Pare aqui. Não inicie a interação de MAJOR enquanto existir BLOCKER não resolvido.
  - O apend da revisão só ocorre quando zero BLOCKER existir.
- Se houver **pendências MAJOR** e zero BLOCKER:
  - Apresente **cada** pendência MAJOR como uma pergunta concreta ao usuário.
  - Formato sugerido:  
    `Pendência MAJOR #N: [descrição do problema]. Como você deseja sanar este ponto?`
  - Aguarde a resposta do usuário antes de passar para a próxima pendência.
  - Avalie se a resposta sanou completamente a pendência. Se não sanou, reformule e pergunte novamente.
  - Só prossiga para a próxima MAJOR quando a atual estiver sanada.
  - Repita até que **todas** as pendências MAJOR tenham sido sanadas.
  - Durante esse processo, vá atualizando mentalmente o relatório com as respostas do usuário (elas serão refletidas no plano completo final).

---

## 8. Apendar revisão no plano original

Somente quando:
- Zero BLOCKER
- Zero MAJOR pendentes (todas sanadas na etapa 7 ou inexistentes)

Ações:
1. Leia o arquivo do plano original identificado na etapa 1.
2. Localize o final do arquivo.
3. Adicione uma separação `---` e, em seguida, o relatório final completo da revisão (referências, pareceres por papel, cenários E2E, pendências consolidadas — incluindo as MAJOR sanadas, próximas ações e veredito).
4. Use `Write` para sobrescrever o arquivo do plano com a concatenação:  
   `[conteúdo original do plano]\n\n---\n\n[relatório da revisão]`
5. Informe o usuário que o plano completo foi salvo em `<arquivo>`.

Se o usuário explicitamente pedir para não sobrescrever, salve como `<arquivo-original>.revisado.md` ao lado do original.

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
