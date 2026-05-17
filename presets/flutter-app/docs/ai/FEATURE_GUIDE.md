# Guia de Feature Flutter

## Estrutura padrão de uma feature

Uma feature pode seguir esta estrutura:

```txt
features/
  feature_name/
    presentation/
      pages/
      widgets/
      controllers/
    application/
      usecases/
    domain/
      entities/
      repositories/
    data/
      datasources/
      dtos/
      repositories/
```

Nem toda feature precisa começar com todas as camadas preenchidas.

Crie apenas o que for necessário para a tarefa atual.

---

## Quando criar uma feature

Crie uma feature quando ela representar uma área funcional clara do produto.

Exemplos:

- auth
- home
- profile
- settings
- notifications
- items (ou o domínio principal do app)
- search
- onboarding

---

## Quando não criar uma feature

Não crie feature nova para:

- widget compartilhado
- helper genérico
- tema
- configuração
- rede
- logging
- constantes globais

Esses itens devem ficar em `core`, `shared` ou `app`.

---

## Plano mínimo

Toda feature deve definir:

- objetivo do usuário
- rota/tela/componente afetado
- fluxo principal
- fluxos alternativos
- estados loading/empty/error/success
- dados consumidos/enviados
- testes
- impacto em performance/build

---

## Fatia vertical

Prefira entregar uma jornada pequena completa em vez de várias telas ocas.

```txt
route/page -> controller -> usecase -> repository -> datasource -> tests -> analyze
```

---

## Fluxo recomendado para implementar feature

Ao implementar uma feature real:

1. Criar entidade de domínio.
2. Criar contrato do repositório no domain.
3. Criar datasource no data.
4. Criar DTO no data, se houver API/mock estruturado.
5. Criar implementação do repository no data.
6. Criar usecase no application.
7. Criar controller/provider no presentation.
8. Criar page/widgets.
9. Registrar providers necessários.
10. Registrar rota, se necessário.
11. Rodar analyze/test.

---

## Exemplo de dependência correta

```txt
Page
  → Controller
    → UseCase
      → Repository interface
        → Repository implementation
          → Datasource
            → Dio
```

---

## Exemplos de dependência errada

```txt
Page → Dio
```

Errado.

```txt
Widget → Datasource
```

Errado.

```txt
Controller → DTO
```

Evitar.

```txt
Domain → Flutter
```

Errado.

---

## Critérios de aceite

Critérios devem ser verificáveis por teste ou inspeção objetiva:

- botão desabilita durante submit
- erro aparece no campo correto
- usuário sem permissão vê estado adequado
- loading é exibido durante operação assíncrona
- lista vazia mostra estado vazio

---

## Produto

Quando comportamento estiver ambíguo, pare e exponha decisão pendente. Não invente regra de negócio.

---

## Regra de escopo

Se a tarefa pedir "estrutura", não implemente feature.

Se a tarefa pedir "feature", implemente somente aquela feature.

Se a tarefa pedir "design", não mexa em regra de negócio.

Se a tarefa pedir "refatoração", não adicione comportamento novo.

---

## Checklist antes de finalizar feature

- A feature respeita as camadas?
- DTO ficou dentro de data?
- UI recebe entidades ou view models?
- Controller não acessa Dio?
- Datasource não vazou para presentation?
- Rota foi adicionada de forma centralizada?
- Providers estão no lugar certo?
- `flutter analyze` passa?
- Existem testes quando há regra relevante?

## Regras bloqueantes

Regras extraídas deste guide. O plano NÃO pode ser proposto se violar qualquer uma abaixo.

- **Não inventar regra de negócio**: comportamento ambíguo deve ser exposto como decisão pendente, nunca assumido
- **Tarefa pedir "estrutura" → não implementar feature**: respeitar o escopo da tarefa
- **Tarefa pedir "feature" → implementar somente aquela feature**: não expandir escopo sem pedido
- **Tarefa pedir "design" → não mexer em regra de negócio**: separar UI de lógica
- **Tarefa pedir "refatoração" → não adicionar comportamento novo**: refatorar é reestruturar, não criar
- **Page não pode acessar Dio diretamente**: dependência errada (Page → Dio)
- **Widget não pode acessar Datasource diretamente**: dependência errada (Widget → Datasource)
- **Domain não pode depender de Flutter**: dependência errada (Domain → Flutter)
- **DTO não pode chegar ao Controller**: evitar (Controller → DTO)
- **Toda feature deve definir fluxo principal, estados e testes**: plano mínimo obrigatório
