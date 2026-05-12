# project-kits

Kits versionados de lifecycle para projetos com Claude Code e Hermes.

O objetivo não é só copiar arquivos. Cada kit instala um processo operacional:

```txt
bootstrap → plan → jarvis-revisor → implementação → test-flow → ship
```

## Kits iniciais

- `flutter-app` — baseado no padrão real do `pacebattle_app@master`.
- `python-backend` — FastAPI/Python backend pragmático com API, DB, segurança, observabilidade e deploy.
- `react-web` — React web com UX, acessibilidade, performance e validação de build/testes.

## Uso rápido

```bash
./bin/kit detect /path/do/projeto
./bin/kit diff auto /path/do/projeto
./bin/kit apply auto /path/do/projeto --refresh
./bin/kit validate flutter-app
./bin/kit create go-service --from "Go backend com chi, pgx, goose, PostgreSQL e systemd"
```

## Política de escrita

Por padrão, nada é sobrescrito silenciosamente:

- arquivo ausente → cria
- arquivo igual → ignora
- arquivo diferente → cria `<arquivo>.kit-new`

Use `--force` apenas se quiser substituir arquivos existentes.





## Importer de arquivo único

Se você não quiser lembrar o caminho do `project-kits`, copie apenas este arquivo para qualquer projeto:

```txt
bootstrap/import-project-kit.md
```

Destino no projeto alvo:

```txt
.claude/commands/import-project-kit.md
```

Ou instale automaticamente:

```bash
/path/para/project-kits/bin/kit install-importer /path/do/projeto
```

Depois, dentro do Claude Code no projeto alvo:

```txt
/import-project-kit
```

Ele localiza/clona `project-kits`, roda `analyze`, valida se a stack é coberta por um kit existente, cria um kit novo quando faltar tecnologia central, mostra `diff`, aplica sem `--force` e verifica os arquivos principais.

Alternativa terminal, também de arquivo único:

```bash
/path/para/project-kits/bootstrap/import-project-kit.sh /path/do/projeto
```

## Bibliotecas estruturais

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


## Cobertura de stack antes de importar

O importer não aplica cegamente o kit mais parecido. Antes ele roda:

```bash
./bin/kit analyze /path/do/projeto
./bin/kit select /path/do/projeto --create-missing
```

Se o projeto usar tecnologia não coberta pelos kits atuais — por exemplo Rails, Go, Rust, Java, ou monorepo React+Node/Python — o `select --create-missing` cria um kit específico em `kits/<stack>-kit/` usando o `skill-creator`/`kit create`, adiciona `tech_tags` no manifest e só então importa.


## Importar em projeto novo

```bash
git clone https://github.com/marcelsanches2/project-kits.git
cd project-kits
./bin/kit detect /path/do/projeto
./bin/kit diff auto /path/do/projeto
./bin/kit apply auto /path/do/projeto --refresh
```

Depois, no projeto alvo:

```bash
git status
```

Revise arquivos `.kit-new` se existirem. Eles indicam conflito não sobrescrito.

## Importar em projeto existente

Use sempre em modo não destrutivo:

```bash
/path/para/project-kits/bin/kit diff auto .
/path/para/project-kits/bin/kit apply auto . --refresh
```

O kit cria:

```txt
CLAUDE.md
.claude/commands/plan.md
.claude/commands/jarvis-revisor.md
.claude/commands/refactor.md
.claude/commands/test-flow.md
.claude/commands/ship.md
.claude/commands/product_roles/*
docs/ai/*
plans/.gitkeep
.project-kit.lock
```

Política de conflitos:

- arquivo ausente → cria
- arquivo igual → ignora
- arquivo diferente → cria `<arquivo>.kit-new`

Não use `--force` em projeto existente sem revisar diff.

## Refatorar projeto existente

Depois de aplicar o kit em um projeto em andamento, use:

```txt
/refactor
```

O `/refactor` não sai mexendo no código. Ele primeiro:

1. carrega `CLAUDE.md` e `docs/ai/`
2. inventaria arquitetura, testes, configs e dívidas
3. cria `plans/YYYY-MM-DD-refactor-<slug>.md`
4. roda `/jarvis-revisor`
5. saneia BLOCKER/MAJOR com o usuário
6. executa por fases pequenas
7. roda `/test-flow` por fase relevante
8. gera `docs/refactor_report_<slug>.md`

Regra: sem big-bang refactor, sem feature nova misturada, sem sobrescrever comportamento sem teste.

## Claude Code

Dentro do projeto alvo:

```bash
/path/para/project-kits/bin/kit apply auto . --refresh
```

Depois use:

```txt
/plan
/jarvis-revisor
/refactor
/test-flow
/ship
```

## Hermes

Peça em linguagem natural:

```txt
Aplica o kit correto nesse projeto.
```

O comando real esperado é:

```bash
/path/para/project-kits/bin/kit apply auto /path/do/projeto --refresh
```

## Criar tecnologia nova

```bash
./bin/kit create go-service --from "Go backend com chi, pgx, goose, PostgreSQL e deploy via systemd"
```

Isso cria `kits/go-service/` com `CLAUDE.md`, comandos, roles, `docs/ai`, manifest e `test-flow` inicial.
