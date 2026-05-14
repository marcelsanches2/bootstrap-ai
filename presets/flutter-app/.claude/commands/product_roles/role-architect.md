# Skill filha: validar-arquitetura

## Objetivo

Validar se o plano respeita a arquitetura, padrões de código e organização técnica do projeto.

## Fonte de referência

Use exclusivamente as referências carregadas por:
`product_roles/carregar-referencias.md`


## Entrada esperada

- plano localizado
- inventário de referências carregadas
- inventário de referências ausentes
- conteúdo das referências disponíveis

## Checklist obrigatório

### 1. Camadas

Verifique se o plano organiza corretamente:

- entidades no domínio
- interfaces de repositório no domínio
- implementações na camada de dados
- usecases na camada de aplicação
- controllers/providers/pages/widgets na camada de apresentação

Resultado:

- `OK` se a separação estiver explícita e correta.
- `PENDÊNCIA` se estiver ausente, misturada ou ambígua.

### 2. Dependência

Verifique se o plano evita dependências proibidas entre camadas.

Resultado:

- `OK` se as dependências respeitam a direção esperada pelas referências carregadas.
- `PENDÊNCIA` se houver acoplamento indevido.

### 3. DTOs

Verifique se:

- DTOs ficam restritos à camada de dados.
- DTOs não vazam para apresentação.
- DTOs não são usados como entidade de domínio.
- Conversão DTO -> Entity está prevista quando aplicável.

Resultado:

- `OK` se DTOs estão isolados.
- `PENDÊNCIA` se DTOs vazam para fora da camada correta.

### 4. Nomenclatura

Verifique se os nomes são específicos, expressivos e alinhados ao padrão carregado pelas referências.

Resultado:

- `OK` se os nomes indicam responsabilidade clara.
- `PENDÊNCIA` se houver nomes genéricos ou ambíguos.

### 5. Arquivos vazios

Verifique se o plano propõe criar:

- placeholders
- arquivos vazios
- estruturas sem uso imediato

Resultado:

- `OK` se não houver criação inútil.
- `PENDÊNCIA` se houver arquivos sem propósito funcional.

### 6. Rota

Se houver nova tela, verifique se o plano menciona registro centralizado conforme as referências carregadas.

Resultado:

- `OK` se a rota foi mencionada corretamente.
- `OK — não aplicável` se não houver tela.
- `PENDÊNCIA` se houver tela nova sem rota centralizada.

### 7. Providers

Verifique se:

- providers de feature ficam no escopo da própria feature quando possível.
- providers globais são usados apenas para dependências realmente globais.
- o plano não joga tudo em providers globais.

Resultado:

- `OK` se o escopo dos providers está correto.
- `PENDÊNCIA` se providers de feature forem globais sem justificativa.

### 8. Mock/Fake

Se houver API ou integração, verifique se o plano prevê:

- datasource mock/fake
- forma de alternar mock/real
- suporte a testes E2E ou desenvolvimento local

Resultado:

- `OK` se mock/fake está previsto.
- `OK — não aplicável` se não houver API ou integração.
- `PENDÊNCIA` se houver API sem datasource mock/fake.

### 9. Testes

Verifique se o plano menciona testes quando houver:

- regra de negócio
- usecase
- repository
- datasource
- fluxo crítico
- integração com API
- conversão DTO/entity

Resultado:

- `OK` se testes estão previstos.
- `OK — não aplicável` se não houver lógica relevante.
- `PENDÊNCIA` se há regra relevante sem teste.

## Saída esperada

```md
## Parecer Arquitetura

- [OK/PENDÊNCIA] Camadas — ...
- [OK/PENDÊNCIA] Dependência — ...
- [OK/PENDÊNCIA] DTOs — ...
- [OK/PENDÊNCIA] Nomenclatura — ...
- [OK/PENDÊNCIA] Arquivos vazios — ...
- [OK/PENDÊNCIA] Rota — ...
- [OK/PENDÊNCIA] Providers — ...
- [OK/PENDÊNCIA] Mock — ...
- [OK/PENDÊNCIA] Testes — ...

### Pendências Arquitetura

1. ...
```

## Regra dura

Se as referências carregadas forem insuficientes para validar arquitetura, reporte a limitação e marque como pendência crítica. Não preencha lacuna com opinião.
