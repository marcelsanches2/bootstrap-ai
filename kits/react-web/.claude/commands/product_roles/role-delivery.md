# Role: Delivery Web

## Objetivo

Revisar build, env, cache, deploy e rollback do frontend.

## Fonte de referência

Use as referências carregadas por `product_roles/carregar-referencias.md`. Se uma referência necessária estiver ausente, marque pendência em vez de assumir padrão.

## Entrada esperada

- plano localizado
- referências carregadas
- conteúdo do plano
- contexto do projeto quando citado pelo plano

## Checklist obrigatório

### 1. Env/config

Verifique env vars públicas e ausência de segredo.

Resultado:

- `OK` se config está documentada e segura.
- `OK — não aplicável` se não há config nova.
- `PENDÊNCIA` se env var/segredo está ambíguo.

### 2. Build production

Verifique build e comando de saída/start.

Resultado:

- `OK` se build production está previsto.
- `OK — não aplicável` se mudança sem impacto de build.
- `PENDÊNCIA` se não há validação de build.

### 3. Rollback

Verifique retorno para build anterior e compatibilidade API/cache.

Resultado:

- `OK` se rollback é claro.
- `OK — não aplicável` se mudança não afeta deploy.
- `PENDÊNCIA` se rollback não foi considerado.

### 4. Cache/CDN

Verifique cache de assets e HTML/entrypoint.

Resultado:

- `OK` se cache não quebra atualização.
- `OK — não aplicável` se sem cache/CDN no escopo.
- `PENDÊNCIA` se cache pode servir versão incompatível.

### 5. Nginx/hosting

Verifique fallback SPA, TLS e headers quando self-host.

Resultado:

- `OK` se hosting está coberto.
- `OK — não aplicável` se não se aplica.
- `PENDÊNCIA` se assume deploy sem detalhes operacionais.

## Saída esperada

```md
## Parecer Role: Delivery Web

- [OK/PENDÊNCIA] Env/config — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Build production — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Rollback — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Cache/CDN — evidência objetiva e correção sugerida quando pendente.
- [OK/PENDÊNCIA] Nginx/hosting — evidência objetiva e correção sugerida quando pendente.

### Pendências

| Severidade | Item | Evidência | Correção exigida |
|---|---|---|---|
| BLOCKER/MAJOR/MINOR | item revisado | evidência do plano | ação concreta |
```

## Regra dura

Não aprove plano que não explicita o item crítico. Ausência de informação relevante é pendência, não aprovação.
