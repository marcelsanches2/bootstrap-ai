## Objetivo

Carregar todos os documentos de referência disponíveis em `docs/ai/` para revisar o plano técnico contra os padrões reais do projeto.

Esta skill é a fonte de autoridade para todos os outros filhos.

Nenhum filho deve inventar regra fora das referências carregadas. Quando uma validação usar uma recomendação não documentada, ela deve ser explicitamente marcada como recomendação, não como regra oficial do projeto.

## Referências principais

Carregue obrigatoriamente, se existirem:

- `docs/ai/ARCHITECTURE.md`
- `docs/ai/CODING_STANDARDS.md`
- `docs/ai/FEATURE_GUIDE.md`
- `docs/ai/DESIGN_SYSTEM.md`
- `docs/ai/TESTING_GUIDE.md`


## Procedimento obrigatório

1. Verifique se o diretório `docs/ai/` existe.
2. Liste todos os arquivos `.md` dentro de `docs/ai/`.
6. Para cada arquivo esperado:
   - Se existir, marque como `OK`.
   - Se não existir, marque como `PENDÊNCIA`.
7. Se algum arquivo estiver ausente:
   - Reporte no relatório.
   - Continue com os arquivos disponíveis.
9. Se nenhum documento de referência existir:
   - Pare a revisão.
   - Reporte: `Nenhuma referência encontrada em docs/ai/. Não há base suficiente para revisar o plano.`

## Saída esperada

```md
## Referências carregadas

### Principais

- [OK] `docs/ai/ARCHITECTURE.md`
- [OK] `docs/ai/CODING_STANDARDS.md`
- [OK] `docs/ai/FEATURE_GUIDE.md`
- [OK] `docs/ai/DESIGN_SYSTEM.md`

## Regras

- Não invente regras ausentes nos documentos.
- Trate ausência das referências principais como pendência importante.
- Se `ARCHITECTURE.md` estiver ausente, marque como pendência crítica.
- Se `CODING_STANDARDS.md` estiver ausente, marque como pendência crítica.
- Se houver UI no plano e `DESIGN_SYSTEM.md` estiver ausente, marque como pendência relevante para o Designer.