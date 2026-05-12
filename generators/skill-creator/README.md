# skill-creator

Gerador de novos kits por tecnologia.

Uso:

```bash
../../bin/kit create go-service --from "Go backend com chi, pgx, goose, PostgreSQL e systemd"
```

Ele cria `kits/<nome>/` com lifecycle completo: `CLAUDE.md`, comandos, roles, docs `docs/ai`, manifest e `test-flow` inicial.
