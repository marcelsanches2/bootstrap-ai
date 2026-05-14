# Acessibilidade

## Mínimo obrigatório

- HTML semântico antes de ARIA.
- Botões são botões; links são links.
- Toda ação via mouse deve ser possível por teclado.
- Foco visível e ordem de foco lógica.
- Inputs com label associado.
- Erros de formulário anunciáveis e próximos do campo.
- Contraste suficiente para texto e controles.

## ARIA

Use ARIA para complementar semântica, não para consertar HTML errado.

- `aria-label` quando texto visível não existe.
- `aria-describedby` para ajuda/erro.
- `aria-live` para feedback assíncrono importante.

## Modais/dropdowns

- Trap de foco em modal.
- Escape fecha quando seguro.
- Foco retorna ao gatilho.
- Clique fora não deve destruir dados sem confirmação.

## Testes manuais mínimos

- Navegar com Tab/Shift+Tab.
- Ativar ações com Enter/Espaço.
- Verificar foco após submit/erro/modal.
- Inspecionar labels e nomes acessíveis.
