# project-kits

Kits versionados de lifecycle para projetos com Claude Code e Hermes.

O objetivo não é só copiar arquivos. Cada kit instala um processo operacional no projeto alvo:

```txt
bootstrap → /plan → /jarvis-revisor → implementação → /test-flow → /ship
```

Os kits são arquivos de operação do projeto: `CLAUDE.md`, `.claude/commands/*`, `.claude/settings.json`, `docs/ai/*` e `plans/`.

---

## 1. O que este repositório entrega

Kits disponíveis:

- `flutter-app` — app Flutter; baseado no padrão real do `pacebattle_app@master`.
- `python-backend` — backend Python/FastAPI com API, DB, segurança, observabilidade e deploy.
- `react-web` — frontend React/TypeScript com UX, acessibilidade, performance e build/testes.
- `node-backend` — backend Node.js/TypeScript com API, DB, segurança, observabilidade e deploy.

Cada kit instala no projeto alvo:

```txt
CLAUDE.md
.claude/settings.json
.claude/commands/plan.md
.claude/commands/jarvis-revisor.md
.claude/commands/refactor.md
.claude/commands/test-flow.md
.claude/commands/ship.md
.claude/commands/carregar-contexto-projeto.md
.claude/commands/product_roles/*
docs/ai/*
plans/.gitkeep
.project-kit.lock
```

Política de escrita padrão:

- arquivo ausente → cria;
- arquivo igual → ignora;
- arquivo diferente → cria `<arquivo>.kit-new`;
- nada é sobrescrito silenciosamente;
- `--force` só deve ser usado depois de revisar diff.

---

## 2. Setup inicial do `project-kits`

Execute uma vez na sua máquina/agente:

```bash
git clone https://github.com/marcelsanches2/project-kits.git
cd project-kits
./bin/kit validate flutter-app
./bin/kit validate python-backend
./bin/kit validate react-web
./bin/kit validate node-backend
```

Se o repo já existir localmente:

```bash
cd /path/para/project-kits
git pull --ff-only
./bin/kit validate flutter-app
./bin/kit validate python-backend
./bin/kit validate react-web
./bin/kit validate node-backend
```

Onde executar os comandos:

- comandos `./bin/kit ...` devem ser executados **dentro do repositório `project-kits`**;
- comandos `/plan`, `/jarvis-revisor`, `/refactor`, `/test-flow`, `/ship` devem ser executados **dentro do projeto alvo**, depois do kit aplicado;
- o importer `/import-project-kit` também roda **dentro do projeto alvo** no Claude Code.

---

## 3. Caminho recomendado: importer de arquivo único

Use este fluxo quando você estiver dentro de um projeto novo ou existente e quiser importar o kit sem lembrar caminho do CLI.

### 3.1 Instalar o importer no projeto alvo

A partir do `project-kits`:

```bash
cd /path/para/project-kits
./bin/kit install-importer /path/do/projeto-alvo
```

Isso cria:

```txt
/path/do/projeto-alvo/.claude/commands/import-project-kit.md
```

Alternativa manual:

```bash
mkdir -p /path/do/projeto-alvo/.claude/commands
cp bootstrap/import-project-kit.md /path/do/projeto-alvo/.claude/commands/import-project-kit.md
```

### 3.2 Executar no Claude Code

Entre no projeto alvo e abra o Claude Code nesse diretório:

```bash
cd /path/do/projeto-alvo
claude
```

Dentro do Claude Code:

```txt
/import-project-kit
```

O importer faz:

1. acha a raiz do projeto alvo;
2. localiza ou clona `marcelsanches2/project-kits`;
3. atualiza o `project-kits` com `git pull --ff-only`;
4. roda `analyze` para detectar stack e bibliotecas estruturais;
5. roda `select --create-missing` para escolher ou criar kit específico;
6. mostra diff não destrutivo;
7. aplica o kit sem `--force`;
8. verifica arquivos principais gerados.

Use este caminho para a maioria dos casos.

---

## 4. Importar kit em projeto novo

Projeto novo aqui significa: repo recém-criado ou pasta ainda sem os arquivos de lifecycle (`CLAUDE.md`, `.claude/commands`, `docs/ai`).

### 4.1 Preparar o projeto alvo

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

O detector usa arquivos como `pubspec.yaml`, `pyproject.toml`, `requirements.txt`, `package.json`, `vite.config.*`, `next.config.*`, `tsconfig.json` e conteúdo desses arquivos para escolher o kit.

### 4.2 Ver o que seria aplicado

Execute dentro do `project-kits`:

```bash
cd /path/para/project-kits
./bin/kit detect /path/do/projeto-alvo
./bin/kit analyze /path/do/projeto-alvo
./bin/kit select /path/do/projeto-alvo --create-missing
./bin/kit diff auto /path/do/projeto-alvo
```

### 4.3 Aplicar o kit

```bash
./bin/kit apply auto /path/do/projeto-alvo --refresh
```

### 4.4 Verificar no projeto alvo

```bash
cd /path/do/projeto-alvo
git status --short
```

Confira se foram criados:

```txt
CLAUDE.md
.claude/settings.json
.claude/commands/plan.md
.claude/commands/jarvis-revisor.md
.claude/commands/refactor.md
.claude/commands/test-flow.md
.claude/commands/ship.md
docs/ai/ARCHITECTURE.md
docs/ai/CODING_STANDARDS.md
docs/ai/TESTING_GUIDE.md
plans/.gitkeep
.project-kit.lock
```

Se aparecer `*.kit-new`, existe conflito com arquivo já existente. Revise manualmente antes de substituir.

---

## 5. Importar kit em projeto existente

Projeto existente aqui significa: já tem código, histórico, talvez docs próprias, talvez `.claude/` parcial.

Regra: **nunca comece com `--force`**.

### 5.1 Criar uma branch

No projeto alvo:

```bash
cd /path/do/projeto-existente
git status --short
git switch -c chore/import-project-kit
```

Se houver mudanças locais, commit ou stash antes. O kit não foi feito para misturar bootstrap com trabalho solto.

### 5.2 Inspecionar detecção

No `project-kits`:

```bash
cd /path/para/project-kits
git pull --ff-only
./bin/kit analyze /path/do/projeto-existente
./bin/kit select /path/do/projeto-existente --create-missing
```

### 5.3 Ver diff sem aplicar

```bash
./bin/kit diff auto /path/do/projeto-existente
```

Leia o diff. Ele mostra o que será criado e onde pode haver conflito.

### 5.4 Aplicar sem sobrescrever

```bash
./bin/kit apply auto /path/do/projeto-existente --refresh
```

### 5.5 Resolver conflitos

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

### 5.6 Commitar o bootstrap

```bash
git add CLAUDE.md .claude docs/ai plans .project-kit.lock
git commit -m "chore: import project lifecycle kit"
```

---

## 6. Usar depois de importar

Depois que o kit estiver no projeto alvo, o fluxo normal é dentro do Claude Code, na raiz do projeto alvo:

```txt
/carregar-contexto-projeto
/plan
/jarvis-revisor
/test-flow
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
4. roda `/jarvis-revisor`;
5. saneia `BLOCKER` e `MAJOR` com o usuário;
6. executa por fases pequenas;
7. roda `/test-flow` por fase relevante;
8. gera `docs/refactor_report_<slug>.md`.

Regra: sem big-bang refactor, sem feature nova misturada, sem sobrescrever comportamento sem teste.

---

## 7. Lista de comandos do CLI

Execute estes comandos dentro do repo `project-kits`.

### `detect`

Detecta o kit provável para um projeto.

```bash
./bin/kit detect /path/do/projeto
```

Use antes de aplicar para saber o que o CLI enxergou.

### `analyze`

Detecta stack e bibliotecas estruturais.

```bash
./bin/kit analyze /path/do/projeto
./bin/kit analyze /path/do/projeto --json
```

Use quando o projeto tiver libs que mudam arquitetura: Prisma, Drizzle, SQLAlchemy, Alembic, Riverpod, TanStack Query, etc.

### `select`

Seleciona o kit adequado. Pode criar kit ausente.

```bash
./bin/kit select /path/do/projeto
./bin/kit select /path/do/projeto --print-kit
./bin/kit select /path/do/projeto --create-missing
```

Use `--create-missing` quando a tecnologia principal ainda não tiver kit.

### `diff`

Mostra o que seria aplicado sem escrever arquivos.

```bash
./bin/kit diff auto /path/do/projeto
./bin/kit diff python-backend /path/do/projeto
```

Use sempre antes de aplicar em projeto existente.

### `apply`

Aplica o kit no projeto alvo.

```bash
./bin/kit apply auto /path/do/projeto --refresh
./bin/kit apply react-web /path/do/projeto --refresh
```

Sem `--force`, conflitos viram `<arquivo>.kit-new`.

Com `--force`:

```bash
./bin/kit apply auto /path/do/projeto --refresh --force
```

Use somente se você quer substituir arquivos existentes. Isso pode apagar customizações locais.

### `refresh`

Atualiza material de um kit antes de aplicar.

```bash
./bin/kit refresh python-backend
```

Use quando for revisar se padrões de stack ainda fazem sentido.

### `validate`

Valida integridade de um kit.

```bash
./bin/kit validate flutter-app
./bin/kit validate python-backend
./bin/kit validate react-web
./bin/kit validate node-backend
```

Rode depois de editar qualquer kit.

### `create`

Cria kit para tecnologia nova.

```bash
./bin/kit create go-service --from "Go backend com chi, pgx, goose, PostgreSQL e deploy via systemd"
./bin/kit create rails-app --from "Rails 8 com PostgreSQL, Sidekiq, RSpec e deploy via systemd"
```

Isso cria `kits/<nome>/` com `CLAUDE.md`, comandos, roles, `docs/ai`, manifest e `test-flow` inicial.

### `install-importer`

Instala o importer de arquivo único em um projeto.

```bash
./bin/kit install-importer /path/do/projeto
./bin/kit install-importer /path/do/projeto --force
```

Use `--force` apenas para substituir um importer antigo.

---

## 8. Comandos disponíveis no projeto alvo

Depois de aplicar um kit, estes comandos passam a existir no Claude Code do projeto alvo.

### `/carregar-contexto-projeto`

Carrega `CLAUDE.md`, docs relevantes e estado do projeto antes de qualquer tarefa.

### `/plan`

Cria plano técnico em `plans/` antes de implementar.

### `/jarvis-revisor`

Revisa plano com papéis especializados em `.claude/commands/product_roles/*`.

### `/refactor`

Planeja e executa refatoração incremental em projeto existente.

### `/test-flow`

Executa validação de qualidade antes de encerrar ou commitar.

### `/ship`

Checklist final de entrega.

### `/import-project-kit`

Só existe se você instalou o importer. Serve para puxar o kit correto para dentro do projeto alvo.

---

## 9. Bibliotecas estruturais

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

Regra: biblioteca auxiliar comum não cria kit novo sozinha. Biblioteca estrutural não coberta pelo kit selecionado cria um kit específico antes da importação.

---

## 10. Fluxos prontos

### Novo backend Python

```bash
cd /path/para/project-kits
./bin/kit analyze /path/minha-api
./bin/kit diff auto /path/minha-api
./bin/kit apply auto /path/minha-api --refresh

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
git switch -c chore/import-project-kit

cd /path/para/project-kits
./bin/kit diff auto /path/app-react
./bin/kit apply auto /path/app-react --refresh

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
cd /path/para/project-kits
./bin/kit install-importer /path/projeto

cd /path/projeto
claude
```

Dentro do Claude Code:

```txt
/import-project-kit
```

---

## 11. Troubleshooting

### O kit errado foi detectado

Rode:

```bash
./bin/kit analyze /path/do/projeto --json
./bin/kit select /path/do/projeto --print-kit
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
./bin/kit apply auto /path/do/projeto --refresh --force
```

Isso sobrescreve arquivos existentes. Só use depois de commit/backup.

### O projeto usa tecnologia sem kit

```bash
./bin/kit select /path/do/projeto --create-missing
```

Depois valide o kit criado:

```bash
./bin/kit validate <kit-criado>
```

### O importer não achou o `project-kits`

Instale via caminho absoluto:

```bash
/path/para/project-kits/bootstrap/import-project-kit.sh /path/do/projeto
```

Ou clone manualmente:

```bash
git clone https://github.com/marcelsanches2/project-kits.git /path/para/project-kits
```

---

## 12. Regras para manter este repo

- `flutter-app` é referência; não reescreva casualmente.
- Todo kit precisa passar em `./bin/kit validate <kit>`.
- `docs/ai/*.md` devem ter conteúdo operacional real, não placeholder.
- `role-*.md` precisam apontar evidência, risco, correção e validação.
- Não commitar `.env`, `.project-kit.lock`, `.refresh-reports/` ou `*.kit-new`.
- README é documentação de uso para humanos; `CLAUDE.md` é contrato interno do repo.
