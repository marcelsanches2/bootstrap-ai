# Skill filha: carregar-referencias

Carregue somente as referências necessárias para revisar o plano localizado.

## Obrigatórias quando existirem

- `CLAUDE.md`
- `docs/ai/ARCHITECTURE.md`
- `docs/ai/CODING_STANDARDS.md`
- `docs/ai/TESTING_GUIDE.md`
- `docs/ai/SCALABILITY_GUIDE.md` quando existir e houver volume/concorrência/produção

## Específicas por impacto

- API/contrato HTTP: `docs/ai/API_GUIDE.md`
- Banco/migrations/queries: `docs/ai/DATABASE_GUIDE.md`
- Segurança/Auth/secrets/PII: `docs/ai/SECURITY_GUIDE.md`
- Logs/métricas/healthcheck/incidente: `docs/ai/OBSERVABILITY_GUIDE.md`
- Deploy/env/rollback: `docs/ai/DEPLOYMENT_GUIDE.md`
- UI/design: `docs/ai/DESIGN_SYSTEM.md`
- Acessibilidade: `docs/ai/ACCESSIBILITY_GUIDE.md`
- Performance frontend: `docs/ai/PERFORMANCE_GUIDE.md`
- Feature/comportamento: `docs/ai/FEATURE_GUIDE.md`

## Saída obrigatória

```md
## Referências carregadas
- `arquivo` — por que foi carregado

## Referências ausentes relevantes
- `arquivo` — impacto da ausência
```

## Regra dura

Não invente padrão quando a referência deveria existir e não existe. Marque limitação como pendência para o papel afetado.
