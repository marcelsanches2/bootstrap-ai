# Guia de Feature React Web

## Plano mínimo

Toda feature deve definir:

- objetivo do usuário
- rota/tela/componente afetado
- fluxo principal
- fluxos alternativos
- estados loading/empty/error/success
- dados consumidos/enviados
- acessibilidade
- responsividade
- testes
- impacto em performance/build

## Fatia vertical

Prefira entregar uma jornada pequena completa em vez de várias telas ocas.

```txt
route/page -> data hook -> component state -> UI states -> tests -> build
```

## Critérios de aceite

Critérios devem ser verificáveis por teste ou inspeção objetiva:

- botão desabilita durante submit
- erro X aparece no campo Y
- usuário sem permissão vê estado Z
- navegação por teclado alcança ações principais

## Produto

Quando comportamento estiver ambíguo, pare e exponha decisão pendente. Não invente regra de negócio no frontend.
