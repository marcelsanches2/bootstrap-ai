# Design System

## Objetivo

Garantir consistência visual e reduzir retrabalho sem bloquear evolução do produto.

Este documento define as diretrizes de tema, tokens, componentes e padrões visuais do {{PROJECT_NAME}}.

---

## Tokens

Use tokens centralizados para:

- cor
- tipografia
- espaçamento
- raio
- sombra
- elevação

Valor hardcoded só é aceitável se o projeto ainda não tem token correspondente e o plano propõe consolidar depois.

### Cores

Centralize as cores em:

```txt
lib/app/theme/app_colors.dart
```

Não usar cores hardcoded diretamente em telas, widgets ou componentes.

Defina tokens semânticos:

```dart
// Fundos
static const Color background = Color(0xFF......);
static const Color surface = Color(0xFF......);

// Acentos
static const Color primary = Color(0xFF......);
static const Color secondary = Color(0xFF......);

// Texto
static const Color textPrimary = Color(0xFF......);
static const Color textSecondary = Color(0xFF......);
static const Color textMuted = Color(0xFF......);

// Estado
static const Color success = Color(0xFF......);
static const Color error = Color(0xFF......);
static const Color warning = Color(0xFF......);
```

Os valores hexadecimais devem ser definidos conforme a identidade visual do projeto.

### Tipografia

Centralize os estilos de texto em:

```txt
lib/app/theme/app_typography.dart
```

Recomenda-se usar o pacote `google_fonts` para fontes, ou fontes locais quando houver decisão explícita.

Defina categorias semânticas:

- **Display**: logo, títulos principais, números grandes
- **Headline**: cabeçalhos de seção, subtítulos
- **Body**: textos longos, descrições, inputs
- **Label**: labels, tabs, badges, textos curtos

Exemplo:

```dart
TextStyle get displayLarge => GoogleFonts.<font>(
  fontSize: 32,
  fontWeight: FontWeight.w700,
);
```

### Espaçamento e Raios

Centralize os tokens de espaçamento em:

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

---

## ThemeData

O tema base deve ficar em:

```txt
lib/app/theme/app_theme.dart
```

Regras:

- usar `ThemeData()` ou `ThemeData.dark()` conforme a identidade visual
- `scaffoldBackgroundColor` deve usar token centralizado
- configurar `colorScheme` com tokens do projeto
- configurar estilos globais de texto, botão e input apenas quando o design system for implementado
- não fazer styling final dentro de pages

Exemplo:

```dart
ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: AppColors.error,
    // ...
  ),
)
```

---

## Componentes

Componentes reutilizáveis devem ter:

- estados: default, hover, focus, disabled, loading, error quando aplicável
- variações nomeadas por intenção, não por cor solta
- acessibilidade embutida
- API de props simples

Componentes compartilhados ficam em:

```txt
lib/shared/widgets/
```

Ou, quando o design system crescer, em:

```txt
lib/app/design_system/
```

### Botão Primário

Uso: ações principais do fluxo (salvar, confirmar, enviar, criar).

- fundo com `AppColors.primary` ou variante
- texto claro
- raio consistente com `AppSpacing.radiusMd`
- altura mínima confortável para toque mobile
- estados: enabled, disabled, loading

### Botão Secundário

Uso: ações auxiliares (cancelar, ver detalhes, filtrar).

- fundo transparente ou `AppColors.surface`
- borda com `AppColors.border` ou `AppColors.borderStrong`
- texto com cor secundária

### Cards

Uso: containers de conteúdo (items, resumos, listas).

- fundo `AppColors.surface` ou `AppColors.surfaceAlt`
- borda fina
- raio consistente
- padding consistente

Exemplo:

```dart
BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
  border: Border.all(color: AppColors.border),
)
```

---

## Componentes Futuros

O design system deve estar preparado para componentes como:

```txt
AppButton
AppCard
AppScaffold
AppText
AppBadge
AppTextField
AppLoading
AppErrorView
AppEmptyState
AppBottomNavigation
```

Não criar todos esses componentes antes da necessidade real.

---

## UX States

Toda tela/fluxo assíncrono precisa decidir:

- loading
- empty
- error
- success
- permission denied quando aplicável

---

## AppBar

- fundo transparente ou com cor de `AppColors.surface`
- sem elevação padrão quando desnecessária
- usar tipografia centralizada
- evitar AppBar genérica com cor sólida sem conexão com o tema

---

## Listas e Scroll

- usar scroll fluido com `BouncingScrollPhysics()` ou `ClampingScrollPhysics()` conforme plataforma
- manter espaçamento generoso
- evitar densidade excessiva de informação

---

## Performance

- não usar blur excessivo em listas longas
- não aplicar sombras em excesso em muitos itens simultâneos
- preferir componentes simples em telas críticas
- manter UI responsiva durante operações pesadas

---

## Acessibilidade e Legibilidade

- preservar contraste alto
- não usar efeitos visuais fortes em textos longos
- manter tamanho mínimo confortável para leitura mobile
- garantir estados visuais claros para erro, sucesso, ativo e desabilitado

---

## Regras para implementação de UI

1. Ler este arquivo antes de codar.
2. Usar tokens centralizados.
3. Não criar estilos hardcoded espalhados.
4. Não implementar fonte customizada sem garantir dependência/configuração.
5. Não criar componente novo se já existir componente reutilizável adequado.
6. Separar componente visual de regra de negócio.
7. Preservar performance mobile.

---

## Critérios de Aceite para UI

Uma implementação visual só é aceitável se:

- respeita a paleta definida
- usa tokens centralizados
- preserva legibilidade
- não espalha estilos duplicados
- não compromete performance
- passa no `flutter analyze`
