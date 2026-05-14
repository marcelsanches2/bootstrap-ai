# Deploy React Web

## Build

- Build production deve passar antes de entrega relevante.
- Env vars públicas precisam de prefixo correto do framework e não podem conter segredo.
- Output e comando de start/serve devem estar documentados.

## Configuração

- `.env` real fora do git.
- `.env.example` com chaves sem valores sensíveis.
- Feature flags e URLs de API documentadas.

## Cache/CDN

- Assets versionados podem ter cache longo.
- HTML/entrypoint precisa permitir atualização rápida.
- Mudança de contrato frontend/backend deve considerar cache antigo.

## Nginx/self-host

Quando servido em VPS:

- TLS configurado.
- Fallback SPA configurado apenas para app SPA.
- Headers básicos de segurança quando aplicável.
- Compressão gzip/brotli quando disponível.

## Rollback

Plano deve dizer como voltar para build anterior e como lidar com env/contrato API.
