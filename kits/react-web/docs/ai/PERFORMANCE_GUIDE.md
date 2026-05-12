# Performance Web

## Princípio

Otimize o que afeta experiência ou custo. Não transforme código simples em labirinto por micro-otimização.

## Bundle

- Dependência nova precisa considerar tamanho.
- Use lazy loading para rotas/áreas pesadas.
- Evite importar biblioteca inteira para uma função pequena.

## Renderização

- Evite estado duplicado que força renders desnecessários.
- Virtualize listas grandes.
- Debounce para busca/input que dispara rede.
- Memoização precisa de motivo claro.

## Imagens/assets

- Dimensões definidas quando possível.
- Formato moderno quando o pipeline suporta.
- Lazy load para imagens fora da dobra.
- Não suba asset gigante sem compressão.

## Web Vitals

Mudança que afeta primeira tela deve considerar:

- LCP
- CLS
- INP

## Medição

Quando performance é objetivo da tarefa, o plano deve indicar métrica antes/depois ou ferramenta de validação.

## Aplicações grandes

Quando a aplicação cresce, revise também:

- divisão por rotas/features para reduzir bundle inicial
- cache de server state com invalidação clara
- listas grandes com paginação, infinite loading controlado ou virtualização
- formulários grandes sem renderização global a cada tecla
- provider/context em escopo pequeno para evitar rerender em árvore inteira
- assets e dependências compartilhadas sem duplicação
- observabilidade frontend: erro, rota, versão e Web Vitals quando aplicável

Plano de frontend grande que só fala em componente visual e ignora dados/cache/renderização deve virar pendência em `role-performance`.
