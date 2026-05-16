# Plano: Preset `fullstack-web`

## Objetivo

Criar preset `fullstack-web` para projetos frontend+backend no mesmo repositório (Next.js, Nuxt, Remix, etc.). Não é colagem de `react-web` + `node-backend` — é um preset coeso que entende ambas as faces.

## Princípios

1. **Não duplicar por duplicar** — se não muda entre frontend e backend, não divide em subseções
2. **Docs mesclados são docs únicos** — ARCHITECTURE.md é UMA arquitetura fullstack, não duas coladas
3. **Roles sem overlap** — cada role cobre um domínio, nunca dois roles cobrem o mesmo domínio
4. **Mesmo quality bar dos outros presets** — validate tem que passar
5. **Responsabilidade única por doc** — naming é CODING_STANDARDS, security headers são SECURITY_GUIDE, deploy é DEPLOYMENT_GUIDE. Se o tema pertence a outro doc, referencie, não repita.

---

## Inventário de Arquivos

### docs/ai/ — 15 arquivos

| # | Arquivo | Origem | Ação |
|---|---|---|---|
| 1 | ARCHITECTURE.md | **MERGE** | Fullstack: App Router / pages, Server Components, API routes, `src/` layout com frontend e backend |
| 2 | CODING_STANDARDS.md | **MERGE** | TS/React + TS/Node: naming, imports, error handling, components vs services |
| 3 | TESTING_GUIDE.md | **MERGE** | Pirâmide completa: unit → component → integration → API → E2E |
| 4 | DEPLOYMENT_GUIDE.md | **MERGE** | Fullstack deploy: build, env, CDN assets + server, healthcheck, rollback |
| 5 | FEATURE_GUIDE.md | **MERGE** | Feature flow: UI + endpoint + schema + migration + test em um fluxo |
| 6 | DESIGN_SYSTEM.md | react-web | Copiar como-is |
| 7 | ACCESSIBILITY_GUIDE.md | react-web | Copiar como-is |
| 8 | PERFORMANCE_GUIDE.md | react-web | Copiar como-is |
| 9 | API_GUIDE.md | node-backend | Copiar como-is |
| 10 | DATABASE_GUIDE.md | node-backend | Copiar como-is |
| 11 | SECURITY_GUIDE.md | node-backend | Copiar como-is |
| 12 | OBSERVABILITY_GUIDE.md | node-backend | Copiar como-is |
| 13 | SCALABILITY_GUIDE.md | node-backend | Copiar como-is |

### product_roles/ — 19 arquivos

| # | Arquivo | Origem | Ação |
|---|---|---|---|
| 1 | role-architect.md | shared | Copiar de qualquer preset |
| 2 | role-pm.md | **MERGE** | react-web (90 linhas, formato completo) como base + absorver itens únicos do node-backend (error states backend, test data/mass). NOT identical — node-backend é stub (39 linhas) |
| 3 | role-delivery.md | **MERGE** | Unificar: frontend build + backend deploy |
| 4 | role-designer.md | react-web | Copiar como-is |
| 5 | role-frontend-architect.md | react-web | Copiar como-is |
| 6 | role-web-qa.md | react-web | Copiar como-is |
| 7 | role-node-architect.md | node-backend | Copiar como-is |
| 8 | role-api-qa.md | node-backend | Copiar como-is |
| 9 | review-accessibility.md | react-web | Copiar como-is |
| 10 | review-performance.md | react-web | Copiar como-is |
| 11 | review-api.md | node-backend | Copiar como-is |
| 12 | review-database.md | node-backend | Copiar como-is |
| 13 | review-security.md | node-backend | Copiar como-is |
| 14 | review-observability.md | node-backend | Copiar como-is |
| 15 | review-scalability.md | node-backend | Copiar como-is |
| 16 | carregar-referencias.md | shared | Copiar como-is |
| 17 | consolidar-parecer.md | shared | Copiar como-is |
| 18 | gerar-relatorio.md | shared | Copiar como-is |
| 19 | localizar-plano.md | shared | Copiar como-is |

### Commands — 9 arquivos

| # | Arquivo | Origem | Ação |
|---|---|---|---|
| 1 | CLAUDE.md | **MERGE** | Contrato fullstack: ambas stacks, ambas rule sets, prioridade 1 = API estável + UX consistente |
| 2 | jarvis-plan-revisor.md | **MERGE** | Union dos roles, docs, blocking rules. Report template com seções frontend + backend |
| 3 | jarvis-test-flow.md | **MERGE** | Pipeline completo: lint → typecheck → unit → API → e2e → migration → build → healthcheck → axe |
| 4 | plan.md | shared | Copiar como-is |
| 5 | ship.md | shared | Copiar como-is |
| 6 | refactor.md | shared | Copiar como-is |
| 7 | kickoff.md | shared | Copiar como-is |
| 8 | design-phase.md | shared | Copiar como-is |
| 9 | manifest.yaml | **NOVO** | Detecção: Next.js, Remix, Nuxt, SvelteKit |

### Outros

| # | Arquivo | Ação |
|---|---|---|
| 1 | .claude/settings.json | **MERGE** — Stop hook watches `src/ public/ test/ prisma/ migrations/ package.json tsconfig.json` |
| 2 | patterns/approval-gate.md | Copiar como-is |
| 3 | patterns/loop-corretivo.md | Copiar como-is |
| 4 | plans/.gitkeep | Criar |

---

## 5 Mesclas Principais (ordem de execução)

### M1. CLAUDE.md (~90 linhas)
- Stack: React + TS + Next.js/Remix + Prisma/Drizzle + PostgreSQL
- Prioridades: (1) API estável, (2) UX consistente, (3) componentes testáveis, (4) migrations seguras, (5) observabilidade mínima, (6) deploy recuperável
- Leitura sob demanda: tabela com TODOS os 13 docs
- Regras: union das duas rule sets, sem repetição
- "Depois de alterar": typecheck + lint + test + build + migration check

### M2. jarvis-plan-revisor.md (~350 linhas)
- Section 2 (docs): todos os 13 docs
- Section 3 (roles): union da tabela — front e back
- Section 5 (blocking rules): union das duas listas
- Section 6 (report template): incluir seções de ambas as faces

### M3. jarvis-test-flow.md (~400 linhas)
- Step 0: watches `src/ public/ test/ prisma/ migrations/ package.json tsconfig.json *.config.*`
- Step 1: flow_id mapeia features/pastas
- Step 4 pipeline: install → lint → typecheck → unit/component tests → API tests → e2e → migration validate → build → healthcheck
- Step 4a diagnosis: union das categorias

### M4. docs/ai (5 mesclas)
Cada um é um documento ÚNICO, não dois colados. Regra: se o tópico é o mesmo pra front e back (ex: naming), escreve uma vez. Se difere (ex: deploy de assets estáticos vs server), usa subseções claras.

- **ARCHITECTURE.md** (~120 linhas): Fullstack `src/` layout — components, hooks, pages, lib, server (routes, services, repositories), prisma. Server Components boundary. Data flow: DB → Server → Client. **SEM naming conventions** (isso é CODING_STANDARDS).
- **CODING_STANDARDS.md** (~150 linhas): Convenções TS que valem pra ambos. Naming table completa. React-specific em subseção. Node-specific em subseção. Shared no topo.
- **TESTING_GUIDE.md** (~120 linhas): Pirâmide com 5 camadas. Quando cada uma aplica. Ferramentas por camada.
- **DEPLOYMENT_GUIDE.md** (~200 linhas): Fullstack build (next build / remix build). Env. CDN pra assets. Server pra API/SSR. Healthcheck. Rollback. **Security headers de middleware/servidor → referenciar SECURITY_GUIDE.md**. Manter só headers de nginx/hosting.
- **FEATURE_GUIDE.md** (~180 linhas): Feature flow integrado — schema → migration → service → API route → UI component → test all layers.

### M5. settings.json
- PostToolUse: `npx tsc --noEmit` com guard `if ! find src/ -name '*.ts' -o -name '*.tsx' 2>/dev/null | head -1 | grep -q .; then exit 0; fi;`
- ExitPlanMode: jarvis-plan-revisor trigger (idêntico aos outros)
- Stop: `git diff --stat src/ public/ test/ prisma/ migrations/ package.json tsconfig.json *.config.*` com mesmo guard

---

## Manifest — Detecção

```yaml
name: fullstack-web
version: 1
description: "Fullstack web lifecycle preset (Next.js, Remix, Nuxt, SvelteKit)"

detects:
  any:
    - next.config.js
    - next.config.mjs
    - next.config.ts
    - remix.config.js
    - nuxt.config.ts
    - svelte.config.js
  contains:
    - file: package.json
      any: ["next", "remix", "@remix-run/node", "nuxt", "@sveltejs/kit"]
  prefer_if:
    - condition: "has 'api/' or 'server/' or 'src/server/' or 'app/api/'"
      beats: react-web

tech_tags:
  - node
  - typescript
  - react
  - next
  - remix
  - vite
  - tailwind
  - prisma
  - drizzle
  - postgres

library_tags:
  - axios
  - tanstack-query
  - react-query
  - zustand
  - redux
  - react-router
  - zod
  - react-hook-form
  - jest
  - vitest
  - playwright
  - cypress
  - prisma
  - drizzle-orm
  - trpc
  - next-auth
  - lucia
```

---

## Tarefas de Execução

### Fase 1 — Scaffold
1. `mkdir -p presets/fullstack-web/{.claude/commands/{product_roles,patterns},docs/ai,plans}`
2. Copiar arquivos "como-is" (8 docs + 12 roles + 4 helpers + 4 commands + 2 patterns + .gitkeep)
3. Criar manifest.yaml
4. Criar settings.json (merged hooks)

### Fase 2 — Mesclas (ordem importa)
5. M1: CLAUDE.md
6. M2: jarvis-plan-revisor.md
7. M3: jarvis-test-flow.md
8. M4a: ARCHITECTURE.md
9. M4b: CODING_STANDARDS.md
10. M4c: TESTING_GUIDE.md
11. M4d: DEPLOYMENT_GUIDE.md
12. M4e: FEATURE_GUIDE.md
13. M5: role-delivery.md (merged)
14. M6: role-pm.md (react-web como base + itens do node-backend)

### Fase 3 — Validação
14. `./bin/bootstrap-ai validate fullstack-web`
15. `./bin/bootstrap-ai validate flutter-app` (certificar que não quebrou nada)
16. Teste de detecção: criar pasta fake com next.config.mjs, rodar `detect`
17. Commit + push

### Fase 4 — Kickoff update
18. Atualizar tabela de mapeamento no kickoff.md (Fase 3) — adicionar linha fullstack-web
19. Atualizar CLAUDE.md do bootstrap-ai (repo) pra listar o novo preset

---

## Não faz parte deste plano
- Atualizar importer/import-project-preset (funciona automático via detect)
- Criar derive prompts específicos (usa os genéricos por enquanto)
- Atualizar README (follow-up separado)

---

## Achados da Revisão (resolved no plano)

### 🔴 Correções aplicadas

1. **role-pm.md NÃO é idêntico** — react-web (90 linhas, formato completo) vs node-backend (39 linhas, stub). Mudei de "copy from either" pra MERGE usando react-web como base. Somar: error states backend, test data/massa do node-backend.

2. **Security headers overlap** — DEPLOYMENT_GUIDE (react-web) tem headers nginx/Next.js que colidem com SECURITY_GUIDE.md (node-backend carry-over). Resolução: DEPLOYMENT_GUIDE fica com headers de nginx/hosting (infra). SECURITY_GUIDE fica com headers de middleware/servidor (helmet). Cross-reference explícito.

3. **Naming conventions duplicado** — node-backend ARCHITECTURE.md tem tabela de naming que também existe em CODING_STANDARDS.md. Resolução: merged ARCHITECTURE.md NÃO inclui naming. Fica em CODING_STANDARDS (responsabilidade única).

### ✅ Verificado sem problemas

4. **PERFORMANCE_GUIDE vs SCALABILITY_GUIDE** — escopos completamente diferentes (client rendering vs server capacity). Coexistem sem conflito.

5. **role-architect.md** — byte-identical entre presets. Pode copiar de qualquer um.

6. **role-delivery.md** — react-web (90 linhas, completo) vs node-backend (39 linhas, minimal). Merge usa react-web como template, absorve itens únicos do node-backend (scope, migration, breaking changes, risks).

7. **Zod referenciado em 5+ arquivos** — não é duplicação real (cada doc referencia no nível correto). Apenas não re-explicar o pattern em cada doc.

8. **"Never commit .env"** aparece em DEPLOYMENT + SECURITY + CLAUDE.md — reforço aceitável, mas DEPLOYMENT_GUIDE deve ser a fonte autoritativa.
