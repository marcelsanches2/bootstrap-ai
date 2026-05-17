# Role: QA Flutter

## Sua contribuição

Gera a seção "Testes" do plano, definindo unit tests, widget tests, integration tests, pipeline e cenários em Gherkin.

## Referência

- docs/ai/CODING_STANDARDS.md
- docs/ai/FEATURE_GUIDE.md

## O que incluir

- **Unit tests** — para cada camada:
  - **Regra de negócio / usecase**: testar lógica de domínio com repository mock. Cobrir casos de sucesso e falha.
  - **Repository**: testar mapeamento entre DTO e entity, chamadas ao datasource, tratamento de erro.
  - **Datasource**: testar parsing de resposta, tratamento de status code, timeout e conexão.
- **Widget tests** — testar cada widget novo ou alterado: renderização correta, interação (tap, scroll, input), estados visuais (loading, error, empty), e verificacao de Semantics.
- **Integration tests** — testar o fluxo completo da feature ponta a ponta com `integration_test`. Incluir setup de ambiente determinístico (mock/fake datasource, seed de dados).
- **Pipeline** — definir comandos que devem passar:
  - `flutter test` — todos os testes unitários e widget
  - `flutter analyze` — zero warnings
  - Golden tests — quando aplicável (componentes visuais com estado determinístico)
- **Cenários em Gherkin** — escrever cenários E2E em formato Gherkin para caminho feliz e cenários negativos. Cada cenário deve ser determinístico e não depender de ambiente externo.

## Regras

- Toda feature que depende de API ou integração deve ter mock/fake/massa determinística. Sem exceção.
- Cenários Gherkin devem ser autocontidos: o passo "Dado" prepara todo o estado necessário.
- Widget tests devem usar `Key` nos widgets críticos para estabilidade.
- Nenhum teste depende de backend real, usuário real ou dados de produção.
- Golden tests apenas quando o componente tem layout estável e determinístico.
- Se a task é puramente técnica sem lógica testável (ex.: config, build): escreva "Não se aplica" e explique por quê.

## Formato de saída

```md
## Testes

### Unit tests

| Camada | Alvo | Cenários | Arquivo |
|---|---|---|---|
| Domain / Usecase | {NomeUsecase} | sucesso, falha, edge cases | test/{feature}/domain/usecases/{nome}_test.dart |
| Repository | {NomeRepositoryImpl} | mapeamento OK, erro datasource | test/{feature}/data/repositories/{nome}_test.dart |
| Datasource | {NomeDatasource} | parsing OK, timeout, status error | test/{feature}/data/datasources/{nome}_test.dart |

### Widget tests

| Widget | O que testa | Arquivo |
|---|---|---|
| {NomeWidget} | renderiza estado default, loading, error, empty | test/{feature}/presentation/widgets/{nome}_test.dart |
| {NomePage} | navegação, interação, estados | test/{feature}/presentation/pages/{nome}_test.dart |

### Integration tests

| Fluxo | Setup | Arquivo |
|---|---|---|
| {nome do fluxo} | {dados/estado inicial} | integration_test/{feature}/{nome}_test.dart |

### Pipeline

```bash
flutter test
flutter analyze
# Golden tests (se aplicável):
flutter test --update-goldens
```

### Cenários Gherkin

#### Caminho feliz

```gherkin
Cenário: {nome do cenário}
  Dado {pré-condição}
  E {massa/estado inicial}
  Quando {ação do usuário}
  Então {resultado esperado}
```

#### Cenários negativos

```gherkin
Cenário: {nome do cenário de erro}
  Dado {pré-condição}
  E {condição de erro simulada}
  Quando {ação do usuário}
  Então {comportamento de erro esperado}
```

{Repetir para cada cenário negativo relevante}
```
