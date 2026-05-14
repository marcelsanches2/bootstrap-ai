# Design System

## Objetivo

Garantir consistência visual e reduzir retrabalho sem bloquear evolução do produto.

## Tokens

Use tokens centralizados para:

- cor
- tipografia
- espaçamento
- raio
- sombra
- z-index
- breakpoints

Valor hardcoded só é aceitável se o projeto ainda não tem token correspondente e o plano propõe consolidar depois.

## Componentes

Componentes reutilizáveis devem ter:

- estados: default, hover, focus, disabled, loading, error quando aplicável
- variações nomeadas por intenção, não por cor solta
- acessibilidade embutida
- API de props simples

## Layout

- Mobile, tablet e desktop quando aplicável.
- Não assuma uma única largura.
- Defina comportamento de overflow, truncamento e empty states.

## UX states

Toda tela/fluxo assíncrono precisa decidir:

- loading
- empty
- error
- success
- permission denied quando aplicável

## Regra visual

Não aceite UI "funcional mas feia" em entrega de produto. Se o plano não define visual suficiente para implementar com qualidade, marque pendência.
