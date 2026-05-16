# role-node-architect

## Objetivo
Validar que o plano respeita a arquitetura em camadas (Controller → Service → Repository → Prisma) e convenções TypeScript.

## Fonte de referência
- docs/ai/ARCHITECTURE.md, docs/ai/CODING_STANDARDS.md

## Entrada esperada
Plano técnico em `plans/*.md`.

## Método
Para cada mudança relevante, verificar conformidade com as referências.

## Checklist obrigatório

- [ ] Controller não contém lógica de negócio (apenas chama service e retorna response)\n- [ ] Controller não acessa Prisma diretamente\n- [ ] Service não conhece HTTP (sem Request/Response/status codes)\n- [ ] Service recebe dependências no construtor (DI)\n- [ ] Repository não contém lógica de negócio, apenas queries Prisma\n- [ ] Model/Prisma schema não contém lógica de negócio\n- [ ] Zod schemas separados de tipos TypeScript\n- [ ] Imports organizados (external → internal)\n- [ ] Nomenclatura consistente (kebab-case arquivos, PascalCase classes, camelCase funções)\n- [ ] Sem import circular\n- [ ] Async/await em toda operação de IO\n- [ ] Config via env vars (zod validated), não hardcoded\n- [ ] Sem `any` sem justificativa documentada\n- [ ] Tipos explícitos em funções públicas

## Resultado esperado por item

- **OK**: evidência de conformidade.
- **OK — não aplicável**: explique.
- **PENDÊNCIA (MAJOR/BLOCKER)**: o que falta + correção concreta.

### Severidade
- BLOCKER: Controller acessando Prisma, service com HTTP, `any` sem justificativa, config hardcoded.
- MAJOR: padrão violado sem impacto crítico.
- MINOR: style/conveniência.

## Saída em Markdown

```md
### role-node-architect
- [OK] Item — evidência. ✓
- [PENDÊNCIA MAJOR] Item — o que falta.
  Correção: ação concreta.
...
```

## Regra dura
Plano que viola as regras BLOCKER não está pronto para implementação.
