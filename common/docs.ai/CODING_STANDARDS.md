# Coding Standards

Documento comum dos project-kits. Cada stack pode ter regras mais específicas em `kits/<kit>/docs/ai/CODING_STANDARDS.md`.

## Regras universais

- Código explícito vence mágica.
- Nome deve explicar responsabilidade.
- Função/componente/módulo deve ter um motivo claro para mudar.
- Erro esperado deve ser tratado; erro inesperado deve ser visível.
- Dependência nova precisa resolver problema real.
- Secrets nunca entram no git.
- Teste deve ser determinístico.

## Estrutura

- Preserve boundaries definidos pelo kit.
- Não crie arquitetura paralela.
- Não espalhe acesso direto a infraestrutura em camada de apresentação/transporte.
- Não crie diretórios vazios ou arquivos sem uso imediato.

## Comentários

Comente o porquê, não o óbvio. Comentário é obrigatório quando:

- há trade-off operacional
- há workaround temporário
- há regra de negócio não evidente
- há decisão de performance/segurança

## Qualidade mínima

Antes de entregar, rode lint/typecheck/test/build aplicáveis e informe resultado. Se não puder rodar, diga exatamente por quê.
