# Plano: Kickoff Flow + Design Phase para ai-project-kits

## Objetivo

Transformar o `import-project-kit` de "aplicar template em projeto existente" para "onboarding completo de projeto novo", com esteira de ideação → stack → design → kit.

## Fluxo completo

```
PASTA VAZIA
  ↓
/kickoff (novo command)
  ├── 1. clarify-requirements (7 perguntas → .hermes/requirements.json)
  ├── 2. product-brief (gera PRODUCT_BRIEF.md)
  ├── 3. choose-stack (decide stack → mapeia pra kit existente ou novo)
  └── 4. Tem front?
        ├── SIM → /design-phase (opcional)
        │     ├── "Tenho Figma Make" → link → parse → tokens + DESIGN_SYSTEM.md
        │     ├── "Crie pra mim" → gera design system do zero
        │     └── "Pula" → sem design
        └── NÃO → pula
  ↓
kit apply (existente, com PROJECT_NAME substitution)
  ↓
PROJETO INICIALIZADO
```

Para projetos que **já existem**, o fluxo atual não muda — `import-project-kit` detecta stack e aplica direto.

---

## Tarefas

### Tarefa 1: Command `kickoff.md`

**Arquivo**: `common/commands/kickoff.md` (command do Claude Code)

Conteúdo:
- Fase 1: 7 perguntas estruturadas (clarify-requirements)
- Fase 2: Gerar PRODUCT_BRIEF.md (product-brief)
- Fase 3: Decidir stack baseado nas respostas (choose-stack)
- Salva requirements em `.hermes/requirements.json`
- Pergunta se tem front e se quer design phase
- Se sim, direciona pra `/design-phase`
- Se não, chama `import-project-kit` normalmente

### Tarefa 2: Command `design-phase.md`

**Arquivo**: `common/commands/design-phase.md` (command do Claude Code)

Conteúdo:
- Pergunta: tem link do Figma Make?
  - **SIM**: pede o link → lê o design system → gera:
    - `docs/ai/DESIGN_SYSTEM.md` com tokens reais (cores, tipografia, espaçamento, componentes)
    - `design/tokens.json` com valores extraíveis
    - Diretivas no CLAUDE.md apontando pro design system
  - **NÃO (quero criar)**: gera design system do zero baseado no PRODUCT_BRIEF:
    - Paleta de cores (primária, secundária, neutros, feedback)
    - Tipografia (heading, body, mono)
    - Espaçamento e grid
    - Componentes base (button, input, card, modal, toast)
    - Salva tudo em `docs/ai/DESIGN_SYSTEM.md`
  - **PULA**: sem design, kit padrão

### Tarefa 3: Atualizar `import-project-kit.md`

**Mudança**: Adicionar detecção de pasta vazia no passo 1.

Antes de buscar kit:
- Se a pasta está vazia (ou só tem .git), direcionar pra `/kickoff`
- Se a pasta tem arquivos, fluxo normal (detect stack → apply)

### Tarefa 4: Atualizar `bin/kit apply`

**Mudança**: Respeitar `DESIGN_SYSTEM.md` e `design/tokens.json` se existirem no target.

- Se `docs/ai/DESIGN_SYSTEM.md` existe no target, não sobrescrever com o genérico do kit
- Se `design/tokens.json` existe, referenciar no CLAUDE.md

### Tarefa 5: Atualizar `import-project-kit.sh`

**Mudança**: Adicionar passo de detecção de pasta vazia que redireciona para o kickoff.

---

## Ordem de implementação

1. `common/commands/kickoff.md` — command novo
2. `common/commands/design-phase.md` — command novo
3. `bootstrap/import-project-kit.md` — atualizar passo de detecção
4. `bootstrap/import-project-kit.sh` — atualizar detecção
5. `bin/kit` — respeito ao design system existente

## Arquivos novos

```
common/commands/kickoff.md         ← Command de kickoff completo
common/commands/design-phase.md    ← Command de design phase
```

## Arquivos modificados

```
bootstrap/import-project-kit.md    ← Detecta pasta vazia → /kickoff
bootstrap/import-project-kit.sh    ← Mesma lógica no shell
bin/kit                            ← apply respeita DESIGN_SYSTEM.md existente
```
