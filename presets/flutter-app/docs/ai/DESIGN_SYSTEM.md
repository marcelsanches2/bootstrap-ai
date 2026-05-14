# DESIGN_SYSTEM.md

Este documento define as diretrizes visuais e técnicas do Design System Flutter do {{PROJECT_NAME}}.

O objetivo é orientar a implementação futura de tema, tokens, componentes e padrões visuais do app.

Importante: este documento é uma referência obrigatória para qualquer tarefa de UI.  
Não implementar o Design System completo sem tarefa explícita.

---

# 1. Conceito Visual

{{PROJECT_NAME}} é um app competitivo de corrida baseado em disputas territoriais.

A estética deve seguir a direção:

- Cyber Arena
- Dark Mode First
- urbano
- noturno
- agressivo
- tech
- premium
- gamificado
- competitivo

O app deve parecer mais próximo de um HUD competitivo/jogo urbano do que de um app tradicional de saúde.

---

# 2. Restrições Absolutas

## 2.1 Não parecer app genérico de fitness

A interface não deve lembrar:

- app genérico de academia
- app médico
- app de saúde corporativo
- app wellness minimalista
- clone visual do Strava
- dashboard branco/limpo demais

A experiência deve comunicar disputa, território, ranking, domínio e performance.

## 2.2 Proibição total da cor laranja

É totalmente proibido usar laranja no app.

Não usar:

```dart
Colors.orange
Colors.deepOrange
Color(0xFFFFA500)
Color(0xFFFF8C00)
Color(0xFFFF4500)
```

Também evitar tons intermediários que visualmente pareçam laranja.

Se uma cor de alerta for necessária, usar vermelho/rosa neon.

---

# 3. Paleta de Cores

As cores devem ser centralizadas em:

```txt
lib/app/theme/app_colors.dart
```

Não usar cores hardcoded diretamente em telas, widgets ou componentes.

---

## 3.1 Fundos

```dart
static const Color background = Color(0xFF050505);
static const Color backgroundAlt = Color(0xFF0A0A0A);

static const Color surface = Color(0xFF121212);
static const Color surfaceAlt = Color(0xFF171717);

static const Color border = Color(0xFF262626);
static const Color borderStrong = Color(0xFF404040);
```

Uso esperado:

- `background`: fundo principal do app
- `backgroundAlt`: variação para gradientes sutis
- `surface`: cards e containers
- `surfaceAlt`: superfícies elevadas
- `border`: bordas finas e divisórias
- `borderStrong`: bordas de maior contraste

---

## 3.2 Neon / Acentos

```dart
static const Color neonGreen = Color(0xFF00FF66);
static const Color neonPurple = Color(0xFFB026FF);
static const Color neonPurpleAlt = Color(0xFF8A2BE2);
static const Color neonCyan = Color(0xFF00F0FF);
static const Color neonYellow = Color(0xFFFFEA00);
static const Color neonPink = Color(0xFFFF0055);
static const Color neonRed = Color(0xFFFF2A2A);
```

Uso semântico:

| Token | Uso |
|---|---|
| `neonGreen` | identidade primária, vitórias, stats positivos, territórios dominados |
| `neonPurple` | ações principais, CTA primário, destaque competitivo |
| `neonPurpleAlt` | variação de roxo para gradientes e estados |
| `neonCyan` | mapa, navegação, zonas neutras, grids e overlays |
| `neonYellow` | liderança, coroa, top 1, badges de conquista |
| `neonPink` | derrotas, zonas inimigas, alertas e risco competitivo |
| `neonRed` | erros críticos, perda de território, ameaça direta |

---

## 3.3 Texto

```dart
static const Color textPrimary = Color(0xFFF5FFF8);
static const Color textSecondary = Color(0xFFB5B5B5);
static const Color textMuted = Color(0xFF737373);
static const Color textDisabled = Color(0xFF525252);
```

Uso esperado:

- `textPrimary`: textos principais
- `textSecondary`: labels e descrições
- `textMuted`: metadados e textos auxiliares
- `textDisabled`: estados desabilitados

---

# 4. Tipografia

As fontes oficiais são:

```txt
Display / Logo / Métricas grandes: Tourney
Subtítulos / Labels / Seções: Saira Condensed
Body / Interface: Inter
```

As fontes devem ser aplicadas via pacote:

```yaml
google_fonts
```

Não adicionar fontes locais sem decisão explícita.

---

## 4.1 Display

Usar `GoogleFonts.tourney` para:

- logo textual {{PROJECT_NAME}}
- títulos principais
- números grandes
- posição no ranking
- pace em destaque
- contagens competitivas

Exemplo:

```dart
GoogleFonts.tourney(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.2,
)
```

---

## 4.2 Accent

Usar `GoogleFonts.sairaCondensed` para:

- labels
- cabeçalhos de seção
- subtítulos
- tabs
- pequenas métricas
- botões em uppercase

Exemplo:

```dart
GoogleFonts.sairaCondensed(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.8,
)
```

---

## 4.3 Body

Usar `GoogleFonts.inter` para:

- textos longos
- descrições
- inputs
- mensagens de erro
- UI padrão
- textos que exigem máxima legibilidade

Exemplo:

```dart
GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
)
```

---

# 5. ThemeData

O tema base deve ficar em:

```txt
lib/app/theme/app_theme.dart
```

Regras:

- usar `ThemeData.dark()`
- `scaffoldBackgroundColor` deve usar `AppColors.background`
- evitar cores padrão do Material que puxem para azul/laranja sem intenção
- configurar `colorScheme`
- configurar estilos globais de botão apenas quando o design system for implementado
- não fazer styling final dentro de pages

Exemplo de direção:

```dart
ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.neonPurple,
    secondary: AppColors.neonCyan,
    surface: AppColors.surface,
    error: AppColors.neonPink,
  ),
)
```

---

# 6. Espaçamento e Raios

Os tokens devem ficar em:

```txt
lib/app/theme/app_spacing.dart
```

Valores base recomendados:

```dart
static const double xs = 4;
static const double sm = 8;
static const double md = 12;
static const double lg = 16;
static const double xl = 24;
static const double xxl = 32;
```

Raios recomendados:

```dart
static const double radiusSm = 6;
static const double radiusMd = 8;
static const double radiusLg = 12;
static const double radiusXl = 16;
```

Regra visual:

- usar cantos levemente arredondados
- evitar visual pill/stadium exagerado
- preferir aparência tática, rígida e tecnológica

Evitar:

```dart
StadiumBorder()
BorderRadius.circular(999)
```

Exceto se houver justificativa explícita.

---

# 7. Componentes

Os componentes compartilhados devem ficar em:

```txt
lib/shared/widgets/
```

Ou, quando o design system crescer, em:

```txt
lib/app/design_system/
```

A decisão final de pasta deve ser feita quando a implementação real começar.

---

## 7.1 Botão Primário

O botão primário deve comunicar ação competitiva.

Uso esperado:

- iniciar corrida
- entrar em batalha
- desafiar líder
- dominar área
- salvar resultado

Direção visual:

- fundo roxo neon ou fundo escuro com borda roxa neon
- texto uppercase
- fonte `Saira Condensed` ou `Tourney`
- raio entre `8` e `12`
- glow roxo moderado
- altura mínima confortável para mobile

Evitar:

- botão laranja
- botão arredondado em formato pílula
- botão com visual genérico de formulário
- CTA sem contraste

---

## 7.2 Botão Secundário

Uso esperado:

- ações auxiliares
- cancelar
- ver detalhes
- abrir filtros
- trocar ranking

Direção visual:

- fundo transparente ou quase preto
- borda `AppColors.borderStrong`
- pode usar borda ciano quando houver contexto de mapa/navegação
- texto claro ou ciano

---

## 7.3 Cards

Cards devem parecer chassis/HUD, não cards de app corporativo.

Direção visual:

- fundo `AppColors.surfaceAlt` com opacidade
- borda fina `AppColors.border`
- raio entre `8` e `16`
- sombras duras ou glow contextual
- padding consistente
- textura visual sutil quando necessário

Exemplo de decoração:

```dart
BoxDecoration(
  color: AppColors.surfaceAlt.withOpacity(0.82),
  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
  border: Border.all(color: AppColors.border),
)
```

---

## 7.4 Glassmorphism

Usar apenas em elementos flutuantes ou sobrepostos, como:

- bottom navigation
- overlays de mapa
- cards sobre mapa
- HUD de corrida

Implementação Flutter:

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.72),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    ),
  ),
)
```

Não aplicar blur em excesso porque pode custar performance.

---

# 8. Backgrounds

O fundo geral deve sugerir:

- asfalto molhado
- HUD digital
- arena urbana
- noite
- mapa tático

Direção técnica:

- usar fundo ultra-escuro
- aplicar gradientes radiais sutis
- evitar fundos claros
- evitar textura pesada que prejudique leitura

Exemplo:

```dart
BoxDecoration(
  gradient: RadialGradient(
    center: Alignment.topLeft,
    radius: 1.2,
    colors: [
      AppColors.neonPurple.withOpacity(0.16),
      AppColors.background,
    ],
  ),
)
```

Também é aceitável combinar roxo/ciano/verde em baixa opacidade, desde que não comprometa leitura.

---

# 9. AppBar

Direção visual:

- fundo transparente
- sem elevação padrão
- foco no logo textual `{{PROJECT_NAME}}`
- usar `Tourney` para o logo
- evitar AppBar genérica Material com cor sólida

Exemplo conceitual:

```dart
AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  title: Text(
    '{{PROJECT_NAME}}',
    style: GoogleFonts.tourney(...),
  ),
)
```

---

# 10. Bottom Navigation

A navegação inferior deve parecer HUD flutuante.

Direção visual:

- usar `BackdropFilter`
- fundo escuro com opacidade
- borda fina
- ícones geométricos
- item ativo em ciano ou roxo neon
- glow leve no item ativo
- evitar navbar branca, azul padrão ou Material genérica demais

Uso esperado:

```txt
Home
Mapa
Batalhas
Ranking
Perfil
```

---

# 11. Listas e Scroll

Regras:

- ocultar scrollbar visual quando fizer sentido
- usar scroll fluido
- manter espaçamento generoso
- priorizar leitura em movimento
- evitar densidade excessiva de informação

Para ocultar barras:

```dart
ScrollConfiguration(
  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
  child: child,
)
```

Physics recomendado:

```dart
const BouncingScrollPhysics()
```

---

# 12. Efeitos Visuais

Efeitos devem ser usados com intenção. Neon demais vira brinquedo barato.

## 12.1 Glow em texto

```dart
TextStyle(
  shadows: [
    Shadow(
      color: AppColors.neonGreen.withOpacity(0.8),
      blurRadius: 8,
    ),
  ],
)
```

## 12.2 Glow em container

```dart
BoxDecoration(
  boxShadow: [
    BoxShadow(
      color: AppColors.neonPurple.withOpacity(0.4),
      blurRadius: 15,
      spreadRadius: 2,
    ),
  ],
)
```

## 12.3 Glow por semântica

| Situação | Cor |
|---|---|
| Vitória / domínio | Verde neon |
| CTA / ação principal | Roxo neon |
| Mapa / navegação | Ciano neon |
| Liderança / top 1 | Amarelo neon |
| Perda / ameaça | Rosa/vermelho neon |

---

# 13. Linguagem Visual de Produto

A UI deve reforçar termos competitivos.

Preferir:

```txt
Engage Battle
Dominar área
Bater o líder
Zona em disputa
Território conquistado
Ranking local
Top runner
Área inimiga
Seu domínio
```

Evitar linguagem muito genérica:

```txt
Exercício
Saúde
Bem-estar
Atividade física
Treino leve
Caminhada saudável
```

Isso não significa nunca usar termos de corrida. Significa que o enquadramento principal é competição territorial.

---

# 14. Acessibilidade e Legibilidade

Apesar da estética agressiva, o app precisa ser legível.

Regras:

- não usar neon em textos longos
- preservar contraste alto
- não usar glow forte em parágrafos
- manter tamanho mínimo confortável
- usar `Inter` para textos longos
- garantir estados visuais claros para erro, sucesso, ativo e desabilitado

---

# 15. Performance

Cuidados:

- não usar blur excessivo em listas longas
- não aplicar sombras/glow em excesso em muitos itens simultâneos
- evitar animações pesadas em tela de tracking/corrida
- manter UI responsiva durante GPS/mapa
- preferir componentes simples em telas críticas

---

# 16. Componentes Futuros

O design system deve estar preparado para componentes como:

```txt
AppButton
AppCard
AppScaffold
AppText
AppBadge
NeonBadge
RankingPositionBadge
BattleAreaCard
PaceStatCard
RunActionButton
BattleMapMarker
HudBottomNavigation
BattleStatusChip
TerritoryCard
LeaderboardCard
```

Não criar todos esses componentes antes da necessidade real.

---

# 17. Regras para Claude Code

Ao implementar UI, Claude deve:

1. Ler este arquivo antes de codar.
2. Usar tokens centralizados.
3. Não usar laranja.
4. Não criar estilos hardcoded espalhados.
5. Não usar `Colors.orange`, `Colors.deepOrange` ou equivalentes.
6. Não transformar o app em visual fitness genérico.
7. Não implementar fonte customizada sem garantir dependência/configuração.
8. Não criar componente novo se já existir componente reutilizável adequado.
9. Não exagerar em glow, blur ou animações.
10. Preservar performance mobile.
11. Separar componente visual de regra de negócio.

---

# 18. Critérios de Aceite para UI

Uma implementação visual só é aceitável se:

- respeita a paleta
- não usa laranja
- usa tokens centralizados
- preserva legibilidade
- mantém estética dark/cyber/competitiva
- não parece app genérico de fitness
- não espalha estilos duplicados
- não compromete performance
- passa no `flutter analyze`
