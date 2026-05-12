# FEATURE_GUIDE.md

Este documento orienta como novas features devem ser criadas no {{PROJECT_NAME}}.

---

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
- map
- battle
- ranking
- profile
- run_session
- notifications
- social
- achievements
- anti_cheat

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
 -> Controller
   -> UseCase
     -> Repository interface
       -> Repository implementation
         -> Datasource
           -> Dio
```

---

## Exemplo de dependência errada

```txt
Page
 -> Dio
```

Errado.

```txt
Widget
 -> Datasource
```

Errado.

```txt
Controller
 -> DTO
```

Evitar.

```txt
Domain
 -> Flutter
```

Errado.

---

## Features previstas

### Auth

Responsável por:

- login
- logout
- sessão
- usuário autenticado
- integração futura com provedores externos

Não implementar autenticação real antes de tarefa explícita.

---

### Home

Responsável por:

- tela inicial
- resumo competitivo
- atalhos
- estado geral do usuário

Não transformar Home em lugar para regra de todas as features.

---

### Map

Responsável por:

- visualização de áreas
- polígonos
- locais próximos
- integração futura com mapa
- integração futura com localização

Não implementar mapa real sem tarefa explícita.

---

### Battle

Responsável por:

- áreas de batalha
- detalhes de competição
- regras de disputa
- status do usuário naquela área

---

### Ranking

Responsável por:

- leaderboard
- ranking por área
- ranking global
- ranking entre amigos
- histórico de posições

---

### Profile

Responsável por:

- perfil do corredor
- estatísticas
- conquistas
- histórico
- preferências públicas

---

### Run Session

Feature futura.

Responsável por:

- iniciar corrida
- pausar corrida
- finalizar corrida
- calcular distância
- calcular pace
- armazenar rota
- enviar resultado

Não implementar antes de map/GPS estarem definidos.

---

### Anti-cheat

Feature futura.

Responsável por:

- detectar corrida falsa
- validar velocidade plausível
- detectar mock location
- detectar GPS irregular
- validar rota
- validar tempo/distância

Não implementar cedo demais.

Mas decisões de arquitetura não devem impedir anti-cheat no futuro.

---

## Regra de escopo

Se a tarefa pedir “estrutura”, não implemente feature.

Se a tarefa pedir “feature”, implemente somente aquela feature.

Se a tarefa pedir “design”, não mexa em regra de negócio.

Se a tarefa pedir “refatoração”, não adicione comportamento novo.

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
