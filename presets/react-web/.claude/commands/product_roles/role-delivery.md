# Role: Delivery Web

## Sua contribuição
Gera a seção "Deploy e entrega" do plano, cobrindo variáveis de ambiente, CI/CD, build de produção, cache e estratégia de rollback.

## Referência
- docs/ai/DEPLOYMENT_GUIDE.md

## O que incluir

- **Variáveis de ambiente**: liste todas as env vars necessárias (apenas públicas para frontend). Documente nome, tipo, valor padrão e onde são usadas. Nunca inclua segredos.
- **CI/CD**: pipeline de integração e entrega contínua — quais comandos rodam (lint, typecheck, test, build), em qual ordem, e o que dispara o deploy.
- **Build de produção**: comando de build, diretório de saída, comando de start (se SSR). Confirme que o build passa antes de deploy.
- **Cache/CDN**: estratégia de cache para assets estáticos (hash no nome) e HTML/entrypoint. Garanta que atualização não serve versão incompatível.
- **Rollback**: como reverter para build anterior. Verifique compatibilidade com API e cache ao voltar versão.
- **Hosting**: fallback SPA (todas rotas → index.html), headers relevantes (CSP, CORS), TLS quando aplicável.

## Regras

- Nunca proponha commit de `.env` real — apenas `.env.example` com valores de exemplo.
- Todo segredo (API key, token) deve vir de env var injetada em runtime, nunca hardcoded no bundle.
- Build de produção deve ser validado como passo explícito do pipeline.
- Sempre defina estratégia de rollback — não assuma que deploy nunca falha.
- Se não se aplica à task: escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Deploy e entrega

### Variáveis de ambiente
| Nome | Tipo | Padrão | Uso |
|------|------|--------|-----|
| VITE_{NAME} | string | {valor} | {onde é usada} |

### CI/CD
{Pipeline: comandos, ordem, triggers}

### Build de produção
- **Build**: `{comando}`
- **Output**: `{diretório}`
- **Start** (se SSR): `{comando}`

### Cache / CDN
| Recurso | Estratégia | Headers |
|---------|-----------|---------|
| Assets (hash) | {longa duração} | Cache-Control: ... |
| HTML/entrypoint | {curta duração / no-cache} | Cache-Control: ... |

### Rollback
{Como reverter + considerações de compatibilidade API/cache}

### Hosting
{Fallback SPA, headers, TLS — se aplicável}
```
