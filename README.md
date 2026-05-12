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

## Claude Code

Dentro do projeto alvo:

```bash
/path/para/project-kits/bin/kit apply auto . --refresh
```

Depois use:

```txt
/plan
/jarvis-revisor
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
