# Design System

## Objective

Define the visual foundation of the Flutter app. Ensure consistency, scalability and reuse across all screens.

---

## Tokens

### Colors

The app uses a color palette defined by semantic tokens.

```dart
class AppColors {
  // Primary
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryLight = Color(0xFFD0BCFF);
  static const Color primaryDark = Color(0xFF381E72);

  // Secondary
  static const Color secondary = Color(0xFF625B71);
  static const Color secondaryLight = Color(0xFFCCC2DC);

  // Tertiary
  static const Color tertiary = Color(0xFF7D5260);
  static const Color tertiaryLight = Color(0xFFEFB8C8);

  // Surface
  static const Color background = Color(0xFFFFFBFE);
  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceVariant = Color(0xFFE7E0EC);

  // Text
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textTertiary = Color(0xFF79747E);

  // Feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFB3261E);
  static const Color info = Color(0xFF2196F3);

  // Borders and dividers
  static const Color border = Color(0xFF79747E);
  static const Color divider = Color(0xFFCAC4D0);
}
```

### Typography

The app uses the system default font or a custom font defined in `pubspec.yaml`.

```dart
class AppTypography {
  static const String fontFamily = 'Roboto';

  // Headings
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.29,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.33,
    letterSpacing: 0,
  );

  // Titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.50,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.50,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.40,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0.5,
  );
}
```

### Spacing

Spacing follows a base-4 scale.

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}
```

### Border Radius

```dart
class AppRadius {
  static const double none = 0.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double full = 9999.0;
}
```

### Elevation

```dart
class AppElevation {
  static const double none = 0.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
}
```

---

## ThemeData

The app theme must be built from tokens. Do not hardcode colors, typography or spacing outside the theme.

```dart
class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primary,
    brightness: Brightness.light,
    fontFamily: AppTypography.fontFamily,
    textTheme: const TextTheme(
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,
      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,
      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    ),
    cardTheme: CardThemeData(
      elevation: AppElevation.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.base,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.base,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.base,
      ),
    ),
  );
}
```

---

## Base components

### AppButton

```dart
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Implementation using theme tokens
  }
}

enum AppButtonVariant { primary, secondary, outlined, ghost, danger }
```

### AppInput

```dart
class AppInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Implementation using theme tokens
  }
}
```

### AppCard

```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Implementation using theme tokens
  }
}
```

### AppLoading

```dart
class AppLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoading({
    super.key,
    this.size = 32.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color ?? AppColors.primary,
          strokeWidth: 3.0,
        ),
      ),
    );
  }
}
```

### AppErrorView

```dart
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Implementation using theme tokens
  }
}
```

---

## Screen states

Every screen that loads external data must handle at least these states:

| State | What to show |
|---|---|
| Loading | AppLoading or shimmer |
| Success | Actual content |
| Empty | Friendly message with illustration or clear CTA |
| Error | AppErrorView with message and retry option |

The state can be managed with Riverpod's AsyncValue or a dedicated state class.

---

## Iconography

- Use Material Icons as the default set.
- If a custom set is needed, define it in the assets and register it in the theme.
- Do not mix icon styles without justification.

---

## Accessibility

- Touch targets with a minimum of 48dp.
- Minimum contrast of 4.5:1 for normal text (WCAG AA).
- Use Semantics for interactive elements.
- Do not convey information through color alone.

---

## Anti-patterns

- Hardcoded color or spacing in widget.
- Theme ignored because "it's faster."
- Duplicated style without token.
- Visual state without error/empty handling.
- New visual component without checking the existing design system.

## Blocking rules

Rules extracted from this guide. The plan MUST NOT be proposed if it violates any of the rules below.

- **Use tokens, never hardcoded values**: colors, typography and spacing must come from the theme
- **Do not ignore the theme**: all visual definitions must use the theme tokens
- **Every screen with external data must have Loading, Success, Empty and Error states**: missing states are blocking
- **Touch targets with a minimum of 48dp**: no interactive element below this size
- **Minimum contrast of 4.5:1 for normal text (WCAG AA)**: no text below this contrast
- **Use Semantics for interactive elements**: accessibility labels are mandatory
- **Do not convey information through color alone**: always have an additional visual indicator
- **Do not duplicate style without token**: if it repeats, it becomes a token
- **Do not create new visual component without checking the existing design system**: reuse before creating
