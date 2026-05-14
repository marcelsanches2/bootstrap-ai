# bootstrap-ai

Kits versionados de lifecycle para projetos com Claude Code e Hermes.

O objetivo não é só copiar arquivos. Cada preset instala um processo operacional no projeto alvo:

```txt
bootstrap → /plan → /jarvis-plan-revisor → implementação → /jarvis-test-flow → /ship

Manual: `/jarvis-revisor` (audit global), `/jarvis-full-test` (regressão completa)
```

Os kits são arquivos de operação do projeto: `CLAUDE.md`, `.claude/commands/*`, `.claude/settings.json`, `docs/ai/*` e `plans/`.

---

## 1. O que este repositório entrega

Kits disponíveis:

- `flutter-app` — app Flutter; baseado no padrão real do `pacebattle_app@master`.
- `python-backend` — backend Python/FastAPI com API, DB, segurança, observabilidade e deploy.
- `react-web` — frontend React/TypeScript com UX, acessibilidade, performance e build/testes.
- `node-backend` — backend Node.js/TypeScript com API, DB, segurança, observabilidade e deploy.

Cada preset instala no projeto alvo:

```txt
CLAUDE.md
.claude/settings.json
.claude/commands/plan.md
.claude/commands/jarvis-plan-revisor.md
.claude/commands/refactor.md
.claude/commands/jarvis-test-flow.md
.claude/commands/jarvis-revisor.md
.claude/commands/jarvis-full-test.md
.claude/commands/ship.md
.claude/commands/carregar-contexto-projeto.md
.claude/commands/product_roles/*
docs/ai/*
plans/.gitkeep
.bootstrap-ai.lock
```

Política de escrita padrão:

- arquivo ausente → cria;
- arquivo igual → ignora;
- arquivo diferente → cria `<arquivo>.kit-new`;
- nada é sobrescrito silenciosamente;
- `--force` só deve ser usado depois de revisar diff.

---

## 2. Setup inicial do `bootstrap-ai`

Execute uma vez na sua máquina/agente:

```bash
git clone https://github.com/marcelsanches2/bootstrap-ai.git
cd bootstrap-ai
```

Se o repo já existir localmente:

```bash
cd /path/para/bootstrap-ai
git pull --ff-only
```

Onde executar os comandos:

- comandos `./bin/bootstrap-ai ...` devem ser executados **dentro do repositório `bootstrap-ai`**;
- comandos `/plan`, `/jarvis-plan-revisor`, `/refactor`, `/jarvis-test-flow`, `/jarvis-revisor`, `/jarvis-full-test`, `/ship` devem ser executados **dentro do projeto alvo**, depois do preset aplicado;
- o importer `/import-project-preset` também roda **dentro do projeto alvo** no Claude Code.

---

## 3. Caminho recomendado: importer de arquivo único

Use este fluxo quando você estiver dentro de um projeto novo ou existente e quiser importar o preset sem lembrar caminho do CLI.

### 3.1 Instalar o importer no projeto alvo

A partir do `bootstrap-ai`:

```bash
cd /path/para/bootstrap-ai
./bin/bootstrap-ai install-importer /path/do/projeto-alvo
```

Isso cria:

```txt
/path/do/projeto-alvo/.claude/commands/import-project-preset.md
```

Alternativa manual:

```bash
mkdir -p /path/do/projeto-alvo/.claude/commands
cp bootstrap/import-project-preset.md /path/do/projeto-alvo/.claude/commands/import-project-preset.md
```

### 3.2 Executar no Claude Code

Entre no projeto alvo e abra o Claude Code nesse diretório:

```bash
cd /path/do/projeto-alvo
claude
```

Dentro do Claude Code:

```txt
/import-project-preset
```

O importer faz:

1. acha a raiz do projeto alvo;
2. usa o **source embutido** (path absoluto gravado na instalação) ou localiza/clona `marcelsanches2/bootstrap-ai`;
3. atualiza o repo com `git pull --ff-only`;
4. roda `analyze` para detectar stack e bibliotecas estruturais;
5. roda `select --create-missing` para escolher ou criar preset específico;
6. detecta o **nome do projeto** (`package.json`, `pubspec.yaml`, `pyproject.toml` ou nome do diretório);
7. mostra diff não destrutivo;
8. aplica o preset com **substituição de `{{PROJECT_NAME}}`** pelo nome real do projeto;
9. verifica arquivos principais gerados.

Use este caminho para a maioria dos casos.

---

## 4. Projeto do zero — Greenfield Flow

Para quando a pasta está **vazia** (ou só tem `.git`) e você quer criar um projeto inteiro: ideia → stack → design → preset aplicado → pronto pra codar.

### Fluxo

```
PASTA VAZIA
  → /kickoff
     ├─ 7 perguntas estruturadas (problema, usuários, features V1, escopo, stack, plataforma, sucesso)
     ├─ PRODUCT_BRIEF.md + .hermes/requirements.json
     ├─ Decide stack → mapeia pra preset existente ou cria novo
     └─ Tem interface visual?
        ├─ SIM → /design-phase
        │     ├─ "Tenho Figma Make" → extrai tokens do link
        │     ├─ "Crie pra mim" → gera design system do zero
        │     └─ "Pula" → sem design por agora
        └─ NÃO → pula
  → preset apply
  → PROJETO INICIALIZADO
```

### 4.1 Rodar o kickoff

No Claude Code, dentro da pasta vazia do projeto:

```txt
/kickoff
```

O comando faz 7 perguntas uma por vez, gera o product brief, decide a stack e pergunta se quer design system. Ao final, aplica o preset automaticamente.

### 4.2 Design Phase (opcional)

Se o projeto tem interface visual, o kickoff pergunta se você quer definir o design system. Se sim:

```txt
/design-phase
```

Três modos:

| Modo | Quando usar | O que gera |
|---|---|---|
| **Figma Make** | Você tem um link de design system no Figma | `docs/ai/DESIGN_SYSTEM.md` + `design/tokens.json` com tokens reais extraídos |
| **Criar do zero** | Quer que o AI gere baseado no product brief | Design system completo (paleta, tipografia, espaçamento, componentes) |
| **Pular** | Sem design por agora | Nada — pode rodar `/design-phase` depois |

### 4.3 Resultado

Após o greenfield flow, o projeto terá:

```txt
PRODUCT_BRIEF.md                      # Requisitos do produto
.hermes/requirements.json              # Respostas estruturadas
CLAUDE.md                              # Contrato do projeto
.claude/settings.json                  # Hooks automáticos
.claude/commands/*                     # Comandos de lifecycle
docs/ai/ARCHITECTURE.md                # Estrutura do projeto
docs/ai/CODING_STANDARDS.md            # Padrões de código
docs/ai/TESTING_GUIDE.md              # Padrões de teste
docs/ai/DESIGN_SYSTEM.md              # Design system (se não pulou)
design/tokens.json                    # Tokens visuais consumíveis (se não pulou)
plans/.gitkeep
.bootstrap-ai.lock
```

Próximos passos no Claude Code:

```txt
/plan                    → cria primeiro plano técnico
/jarvis-plan-revisor     → revisa plano (dispara automático)
(implementa)             → hooks rodam lint/typecheck a cada edição
/jarvis-test-flow        → validação antes de commit (dispara automático)
/ship                    → checklist de entrega
```

### 4.4 Projetos existentes vs. do zero

| Cenário | Comando |
|---|---|
| Pasta vazia, sem nada | `/import-project-preset` (detecta vazio → redireciona pra `/kickoff` automaticamente) |
| Projeto com código, sem kit | `/import-project-preset` (seção 6) |
| Projeto com preset, quer atualizar | `./bin/bootstrap-ai apply auto /path --refresh` (seção 6) |

> **Nota:** Você não precisa lembrar de rodar `/kickoff` direto. Basta rodar `/import-project-preset` em qualquer pasta — se estiver vazia, ele redireciona pro flow completo automaticamente.

> **Nota:** O `/kickoff` está disponível nos kits `flutter-app`, `react-web`, `node-backend` e `python-backend`. Para stacks não cobertas, o kickoff propõe criar um novo preset via `skill-creator`.

---

## 5. Importar preset em projeto novo

Projeto novo aqui significa: repo recém-criado que já tem arquivos de stack (`package.json`, `pyproject.toml`, `pubspec.yaml`) mas ainda sem os arquivos de lifecycle (`CLAUDE.md`, `.claude/commands`, `docs/ai`). Se a pasta está completamente vazia, use o **Greenfield Flow** (seção 4).

### 5.1 Preparar o projeto alvo

Exemplo Python:

```bash
mkdir -p ~/workspace/minha-api
cd ~/workspace/minha-api
git init
printf '[project]\nname = "minha-api"\n' > pyproject.toml
```

Exemplo React/Node:

```bash
mkdir -p ~/workspace/meu-projeto
cd ~/workspace/meu-projeto
git init
printf '{"scripts":{"test":"echo test"}}\n' > package.json
```

O detector usa arquivos como `pubspec.yaml`, `pyproject.toml`, `requirements.txt`, `package.json`, `vite.config.*`, `next.config.*`, `tsconfig.json` e conteúdo desses arquivos para escolher o preset.

### 5.2 Ver o que seria aplicado

Execute dentro do `bootstrap-ai`:

```bash
cd /path/para/bootstrap-ai
./bin/bootstrap-ai detect /path/do/projeto-alvo
./bin/bootstrap-ai analyze /path/do/projeto-alvo
./bin/bootstrap-ai select /path/do/projeto-alvo --create-missing
./bin/bootstrap-ai diff auto /path/do/projeto-alvo
```

### 5.3 Aplicar o preset

```bash
./bin/bootstrap-ai apply auto /path/do/projeto-alvo --refresh
```

### 5.4 Verificar no projeto alvo

```bash
cd /path/do/projeto-alvo
git status --short
```

Confira se foram criados:

```txt
CLAUDE.md
.claude/settings.json
.claude/commands/plan.md
.claude/commands/jarvis-plan-revisor.md
.claude/commands/refactor.md
.claude/commands/jarvis-test-flow.md
.claude/commands/jarvis-revisor.md
.claude/commands/jarvis-full-test.md
.claude/commands/ship.md
docs/ai/ARCHITECTURE.md
docs/ai/CODING_STANDARDS.md
docs/ai/TESTING_GUIDE.md
plans/.gitkeep
.bootstrap-ai.lock
```

Se aparecer `*.kit-new`, existe conflito com arquivo já existente. Revise manualmente antes de substituir.

---

## 6. Importar preset em projeto existente

Projeto existente aqui significa: já tem código, histórico, talvez docs próprias, talvez `.claude/` parcial.

Regra: **nunca comece com `--force`**.

### 6.1 Criar uma branch

No projeto alvo:

```bash
cd /path/do/projeto-existente
git status --short
git switch -c chore/import-project-preset
```

Se houver mudanças locais, commit ou stash antes. O preset não foi feito para misturar bootstrap com trabalho solto.

### 6.2 Inspecionar detecção

No `bootstrap-ai`:

```bash
cd /path/para/bootstrap-ai
git pull --ff-only
./bin/bootstrap-ai analyze /path/do/projeto-existente
./bin/bootstrap-ai select /path/do/projeto-existente --create-missing
```

### 6.3 Ver diff sem aplicar

```bash
./bin/bootstrap-ai diff auto /path/do/projeto-existente
```

Leia o diff. Ele mostra o que será criado e onde pode haver conflito.

### 6.4 Aplicar sem sobrescrever

```bash
./bin/bootstrap-ai apply auto /path/do/projeto-existente --refresh
```

### 6.5 Resolver conflitos

No projeto alvo:

```bash
cd /path/do/projeto-existente
git status --short
find . -name '*.kit-new' -print
```

Para cada `*.kit-new`:

1. abra o arquivo original;
2. abra o `.kit-new`;
3. mergeie o que fizer sentido;
4. remova o `.kit-new` depois de resolver.

Não use `--force` para resolver conflito em lote. Isso pode substituir documentação ou comandos já customizados.

### 6.6 Commitar o bootstrap

```bash
git add CLAUDE.md .claude docs/ai plans .bootstrap-ai.lock
git commit -m "chore: import project lifecycle preset"
```

---

## 7. Usar depois de importar

Depois que o preset estiver no projeto alvo, o fluxo normal é dentro do Claude Code, na raiz do projeto alvo:

```txt
/carregar-contexto-projeto
/plan
/jarvis-plan-revisor
/jarvis-test-flow
/jarvis-revisor
/jarvis-full-test
/ship
```

Para projeto existente que precisa organização/refatoração:

```txt
/refactor
```

O `/refactor` não sai alterando código diretamente. Ele primeiro:

1. carrega `CLAUDE.md` e `docs/ai/*`;
2. inventaria arquitetura, testes, configs e dívidas;
3. cria `plans/YYYY-MM-DD-refactor-<slug>.md`;
4. roda `/jarvis-plan-revisor`;
5. saneia `BLOCKER` e `MAJOR` com o usuário;
6. executa por fases pequenas;
7. roda `/jarvis-test-flow` por fase relevante;
8. gera `docs/refactor_report_<slug>.md`.

Regra: sem big-bang refactor, sem feature nova misturada, sem sobrescrever comportamento sem teste.

---

## 8. Lista de comandos do CLI

Execute estes comandos dentro do repo `bootstrap-ai`.

### `detect`

Detecta o preset provável para um projeto.

```bash
./bin/bootstrap-ai detect /path/do/projeto
```

Use antes de aplicar para saber o que o CLI enxergou.

### `analyze`

Detecta stack e bibliotecas estruturais.

```bash
./bin/bootstrap-ai analyze /path/do/projeto
./bin/bootstrap-ai analyze /path/do/projeto --json
```

Use quando o projeto tiver libs que mudam arquitetura: Prisma, Drizzle, SQLAlchemy, Alembic, Riverpod, TanStack Query, etc.

### `select`

Seleciona o preset adequado. Pode criar preset ausente.

```bash
./bin/bootstrap-ai select /path/do/projeto
./bin/bootstrap-ai select /path/do/projeto --print-preset
./bin/bootstrap-ai select /path/do/projeto --create-missing
```

Use `--create-missing` quando a tecnologia principal ainda não tiver preset.

### `diff`

Mostra o que seria aplicado sem escrever arquivos.

```bash
./bin/bootstrap-ai diff auto /path/do/projeto
./bin/bootstrap-ai diff python-backend /path/do/projeto
```

Use sempre antes de aplicar em projeto existente.

### `apply`

Aplica o preset no projeto alvo. Substitui `{{PROJECT_NAME}}` pelo nome real do projeto em todos os arquivos de texto.

```bash
./bin/bootstrap-ai apply auto /path/do/projeto --refresh
./bin/bootstrap-ai apply react-web /path/do/projeto --refresh
./bin/bootstrap-ai apply auto /path/do/projeto --refresh --project-name "meu-app"
```

Detecção automática do nome (nesta ordem): `package.json` → `pubspec.yaml` → `pyproject.toml` → basename do diretório. Use `--project-name` para forçar um nome específico.

Sem `--force`, conflitos viram `<arquivo>.kit-new`.

Com `--force`:

```bash
./bin/bootstrap-ai apply auto /path/do/projeto --refresh --force
```

Use somente se você quer substituir arquivos existentes. Isso pode apagar customizações locais.

### `refresh`

Atualiza material de um preset antes de aplicar.

```bash
./bin/bootstrap-ai refresh python-backend
```

Use quando for revisar se padrões de stack ainda fazem sentido.

### `create`

Cria preset para tecnologia nova.

```bash
./bin/bootstrap-ai create go-service --from "Go backend com chi, pgx, goose, PostgreSQL e deploy via systemd"
./bin/bootstrap-ai create rails-app --from "Rails 8 com PostgreSQL, Sidekiq, RSpec e deploy via systemd"
```

Isso cria `kits/<nome>/` com `CLAUDE.md`, comandos, roles, `docs/ai`, manifest e `jarvis-test-flow` inicial.

### `install-importer`

Instala o importer de arquivo único em um projeto. O path absoluto do repo `bootstrap-ai` é embutido no arquivo, então o importer sempre encontra o CLI independente de onde o repo foi clonado.

```bash
./bin/bootstrap-ai install-importer /path/do/projeto
./bin/bootstrap-ai install-importer /path/do/projeto --force
```

Use `--force` apenas para substituir um importer antigo.

---

## 9. Comandos disponíveis no projeto alvo

Depois de aplicar um preset, estes comandos passam a existir no Claude Code do projeto alvo.

### `/carregar-contexto-projeto`

Carrega `CLAUDE.md`, docs relevantes e estado do projeto antes de qualquer tarefa.

### `/plan`

Cria plano técnico em `plans/` antes de implementar.

### `/jarvis-plan-revisor`

Revisa plano com papéis especializados em `.claude/commands/product_roles/*`.

### `/refactor`

Planeja e executa refatoração incremental em projeto existente.

### `/jarvis-test-flow`

Pipeline de validação E2E. Roda automaticamente via hook **Stop** quando há diff em arquivos da stack. Valida lint, tipos, testes unitários, integração e build.

### `/jarvis-revisor`

Auditoria global do projeto. Revisão profunda sob múltiplas perspectivas (arquiteto, PM, QA, security, performance, DevOps). Gera relatório com score de saúde e plano de ação priorizado. **Manual apenas** — use quando quiser um checkup completo.

### `/jarvis-full-test`

Regressão completa. Executa todas as camadas: lint, type check, formatação, testes unitários, integração, E2E e build. Gera relatório com PASS/PARTIAL/FAIL por fase. **Manual apenas** — use após mudanças grandes ou antes de releases.

### `/ship`

Checklist final de entrega.

### `/import-project-preset`

Só existe se você instalou o importer. Serve para puxar o preset correto para dentro do projeto alvo.

---

## 10. Bibliotecas estruturais

O `analyze` considera também bibliotecas que definem arquitetura, não só linguagem/framework.

Exemplos:

```txt
Flutter: dio, riverpod, go_router, freezed, json_serializable, drift, firebase, mocktail
React: axios, tanstack-query, zustand, redux, react-router, zod, react-hook-form, vitest, playwright
Python: sqlalchemy, alembic, pydantic, celery, httpx, pytest, ruff, mypy
Node backend: prisma, drizzle, zod, jest, vitest
Ruby/Rails: sidekiq, devise, graphql, rspec, rubocop
Go: chi, gin, fiber, pgx, gorm, goose, sqlc
```

Regra: biblioteca auxiliar comum não cria kit novo sozinha. Biblioteca estrutural não coberta pelo preset selecionado cria um preset específico antes da importação.

---

## 11. Fluxos prontos

### Novo backend Python

```bash
cd /path/para/bootstrap-ai
./bin/bootstrap-ai analyze /path/minha-api
./bin/bootstrap-ai diff auto /path/minha-api
./bin/bootstrap-ai apply auto /path/minha-api --refresh

cd /path/minha-api
git status --short
```

Depois no Claude Code:

```txt
/plan
```

### App React existente

```bash
cd /path/app-react
git switch -c chore/import-project-preset

cd /path/para/bootstrap-ai
./bin/bootstrap-ai diff auto /path/app-react
./bin/bootstrap-ai apply auto /path/app-react --refresh

cd /path/app-react
find . -name '*.kit-new' -print
git status --short
```

Depois no Claude Code:

```txt
/refactor
```

### Usando só o importer

```bash
cd /path/para/bootstrap-ai
./bin/bootstrap-ai install-importer /path/projeto

cd /path/projeto
claude
```

Dentro do Claude Code:

```txt
/import-project-preset
```

---

## 12. Troubleshooting

### O preset errado foi detectado

Rode:

```bash
./bin/bootstrap-ai analyze /path/do/projeto --json
./bin/bootstrap-ai select /path/do/projeto --print-preset
```

Verifique arquivos de sinalização: `package.json`, `pyproject.toml`, `pubspec.yaml`, `tsconfig.json`, `vite.config.*`, `next.config.*`.

### Apareceram arquivos `.kit-new`

Isso é esperado em projeto existente. Significa: o arquivo já existia e era diferente.

```bash
find /path/do/projeto -name '*.kit-new' -print
```

Faça merge manual. Não apague sem revisar.

### Quero substituir tudo mesmo assim

```bash
./bin/bootstrap-ai apply auto /path/do/projeto --refresh --force
```

Isso sobrescreve arquivos existentes. Só use depois de commit/backup.

### O projeto usa tecnologia sem preset

```bash
./bin/bootstrap-ai select /path/do/projeto --create-missing
```

Depois rode o fluxo normal: `diff`, `apply` e revise os arquivos criados no projeto alvo.

### O importer não achou o `bootstrap-ai`

O `install-importer` embute o path absoluto do repo no arquivo do importer, então isso só acontece se o importer foi copiado manualmente (sem `install-importer`).

Se precisar resolver manualmente:

```bash
# Opção 1: exportar variável de ambiente
export BOOTSTRAP_AI_DIR=/path/para/bootstrap-ai

# Opção 2: rodar o script de bootstrap
/path/para/bootstrap-ai/bootstrap/import-project-preset.sh /path/do/projeto

# Opção 3: clone manual
git clone https://github.com/marcelsanches2/bootstrap-ai.git ~/workspace/bootstrap-ai
```

---

## 13. Manutenção do repo

Esta seção é para quem for editar o `bootstrap-ai`, não para quem só vai importar um preset em um projeto.

- `flutter-app` é referência; não reescreva casualmente.
- `docs/ai/*.md` devem ter conteúdo operacional real, não placeholder.
- `role-*.md` precisam apontar evidência, risco, correção e validação.
- Não commitar `.env`, `.bootstrap-ai.lock`, `.refresh-reports/` ou `*.kit-new`.
- README é documentação de uso para humanos; `CLAUDE.md` é contrato interno do repo.
