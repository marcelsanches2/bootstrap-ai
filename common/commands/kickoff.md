# /kickoff

Inicializa um projeto do zero: coleta requisitos, gera product brief, decide stack e direciona para o preset correto.

## Quando usar

- Projeto é uma pasta vazia ou quase vazia (só `.git`)
- Usuário diz "novo projeto", "começar do zero", "quero criar um app"
- `/import-project-preset` detectou pasta vazia

**NÃO usar quando** o projeto já tem stack definida (arquivos de código, package.json, pubspec.yaml, etc.). Nesses casos, use `/import-project-preset` direto.

---

## Fase 1 — Clarify Requirements

**MODO INTERATIVO OBRIGATÓRIO — VIOLAÇÃO = BUG:**
- Sua resposta deve ser SOMENTE a pergunta 1, nada mais. Sem texto adicional, sem prólogo.
- **PARE após cada pergunta.** Não escreva mais nada até o usuário responder.
- Só depois da resposta do usuário, confirme em 1 linha e faça a próxima pergunta.
- **NUNCA** faça 2+ perguntas na mesma mensagem.
- **NUNCA** continue para a Fase 2 sem o usuário confirmar todas as respostas.

Faça **uma pergunta por vez**. Espere a resposta antes de seguir. Não proponha implementação durante esta fase.

### Pergunta 1 — Problema
```
Qual problema este projeto resolve? Quem experiencia esse problema e com que frequência?
```

### Pergunta 2 — Usuários
```
Quem são os usuários primários? Seja específico — "empreendedores solo construindo SaaS" não "desenvolvedores".
```

### Pergunta 3 — Features do V1
```
Quais são as 3 features mais importantes para a versão 1? Em ordem de prioridade.
```

### Pergunta 4 — Fora de escopo
```
O que está explicitamente FORA de escopo para esta versão?
```

### Pergunta 5 — Stack e restrições técnicas
```
Tem preferência de stack técnica? Tem restrições (deadline, orçamento, precisa integrar com algo específico)?
```

### Pergunta 6 — Plataforma
```
Qual plataforma? Web, mobile (iOS/Android), desktop, API-only, CLI?
```

### Pergunta 7 — Sucesso
```
O que significa sucesso 30 dias depois do lançamento? Seja mensurável.
```

Após as 7 respostas, valide com o usuário:

```
Resumo dos requisitos:

1. Problema: [resumo]
2. Usuários: [resumo]
3. Features V1: [lista]
4. Fora de escopo: [lista]
5. Stack: [resumo + restrições]
6. Plataforma: [resumo]
7. Sucesso: [resumo]

Isso está correto? Posso seguir para o product brief?
```

**Não salve nada até o usuário confirmar.**

---

## Fase 2 — Product Brief

Gere `PRODUCT_BRIEF.md` na raiz do projeto com:

```markdown
# Product Brief — {{PROJECT_NAME}}

## Problema
[1 parágrafo: problema, quem, frequência]

## Usuários alvo
[descrição específica]

## Features do V1 (prioridade)
1. [feature] — [1 frase]
2. [feature] — [1 frase]
3. [feature] — [1 frase]

## Fora de escopo (V1)
- [item]
- [item]

## Stack técnica
| Camada | Tecnologia | Por quê |
|---|---|---|
| [camada] | [tech] | [1 frase] |

## Plataforma
[plataforma(s)]

## Critérios de sucesso (30 dias)
- [critério mensurável]
- [critério mensurável]

## Questões abertas
- [se houver, senão "Nenhuma"]
```

Salve os requisitos também em `.hermes/requirements.json`:

```json
{
  "project_name": "{{PROJECT_NAME}}",
  "collected_at": "[ISO timestamp]",
  "answers": {
    "problem": "...",
    "users": "...",
    "features_v1": ["...", "...", "..."],
    "out_of_scope": ["...", "..."],
    "stack_preference": "...",
    "platform": "...",
    "success_criteria": "..."
  }
}
```

---

## Fase 3 — Choose Stack

Baseado nas respostas (especialmente pergunta 5 e 6), decida a stack:

### Tabela de mapeamento

| Plataforma | Stack sugerida | Preset correspondente |
|---|---|---|
| Mobile iOS/Android | Flutter + Dart | `flutter-app` |
| Web app (frontend-only) | React + TypeScript + Vite | `react-web` |
| Full-stack web (monolito) | Next.js / Remix / Nuxt / SvelteKit | `fullstack-web` |
| API / Backend | Node + TypeScript + Express | `node-backend` |
| API / Backend (Python) | Python + FastAPI | `python-backend` |
| Desktop | Electron (React) ou Flutter desktop | depende |
| CLI | Go, Rust ou Python puro | criar novo |

### Regras de decisão

1. Se o usuário especificou stack → use a preferência dele
2. Se não especificou → sugira baseado na tabela acima
3. Se não tem preset correspondente → avise que vai criar um novo via `skill-creator`
4. Apresente a decisão:

```
Stack decidida: [stack]
Preset: [nome do preset ou "será criado novo"]

Tem front-end? [SIM/NÃO]
```

---

## Fase 4 — Design Phase (condicional)

**Pergunte:** "Este projeto tem interface visual? Se sim, quer definir o design system agora?"

### Se SIM → direcione para `/design-phase`

Explique as opções:
1. **"Tenho Figma"** → `/design-phase` vai extrair tokens do link
2. **"Quero que crie"** → `/design-phase` vai gerar design system do zero
3. **"Depois"** → pula, pode rodar `/design-phase` a qualquer momento

### Se NÃO → pule para preset apply

---

## Fase 5 — Kit Apply

Após design phase (ou se pulou), aplique o preset:

```bash
# Se o preset existe
[BOOTSTRAP_AI_DIR]/bin/bootstrap-ai apply [preset-name] [project-dir] --project-name "[PROJECT_NAME]"

# Se não existe, crie primeiro
[BOOTSTRAP_AI_DIR]/bin/bootstrap-ai create [preset-name] --from "[descrição da stack]"
[BOOTSTRAP_AI_DIR]/bin/bootstrap-ai apply [preset-name] [project-dir] --project-name "[PROJECT_NAME]"
```

---

## Resumo final

Após tudo concluído, mostre:

```
Projeto inicializado: {{PROJECT_NAME}}
────────────────────────────────
Product Brief: PRODUCT_BRIEF.md
Requisitos: .hermes/requirements.json
Preset aplicado: [preset-name]
Design system: [SIM - docs/ai/DESIGN_SYSTEM.md | NÃO]

Próximos passos:
1. /plan — criar primeiro plano técnico
2. /jarvis-plan — gerar plano com perspectivas embutidas (manual)
3. Implementar plano
4. /ship — checklist de entrega
```

## Pitfalls

- Não pule perguntas. 7 perguntas, todas respondidas.
- Não proponha solução técnica durante clarify. Redirecione: "Vamos terminar os requisitos primeiro."
- Se o usuário não souber responder, marque como `[QUESTÃO ABERTA: ...]` — não invente.
- Não crie preset novo sem antes verificar se um existente serve. Use `analyze` para confirmar.
- DESIGN_SYSTEM.md existente (da design phase) NÃO deve ser sobrescrito pelo preset genérico.
