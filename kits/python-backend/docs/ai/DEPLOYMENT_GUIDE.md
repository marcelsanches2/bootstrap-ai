# Guia de Deploy

## Preferência operacional

Self-host simples: systemd + nginx + env file fora do git. Docker só se o projeto já exigir.

## Artefato

- Build/release deve ser reproduzível.
- Dependências instaladas via lockfile.
- Comando de start documentado.
- Versão/commit deve aparecer em log ou healthcheck quando possível.

## Configuração

- `.env` real fora do git.
- Exemplo seguro em `.env.example`.
- Secrets via arquivo protegido ou secret manager do ambiente.
- Falha de config obrigatória deve derrubar startup.

## systemd

Serviço deve definir:

- `WorkingDirectory`
- usuário não-root
- env file
- restart policy controlada
- logs via journald
- comando de start claro

## nginx

Quando exposto via HTTP:

- TLS configurado
- proxy headers corretos
- limite de body quando aplicável
- timeout coerente com API

## Migrations no deploy

- Migration roda antes da versão que depende dela ou em estratégia expand/contract.
- Deploy com migration destrutiva precisa janela/backup.
- Rollback de app não pode quebrar schema novo.

## Rollback

Todo plano de entrega precisa dizer:

- como voltar binário/código
- como tratar migration
- como validar saúde após rollback
- qual métrica/log confirma recuperação

## Checklist mínimo

- Build/testes passaram.
- Env vars documentadas.
- Backup feito se toca dados.
- Healthcheck responde.
- Logs visíveis em `journalctl`/observabilidade definida.
