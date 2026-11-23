import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SOFTEL brand palette: Softel Blue + the Slate neutral scales, shared with
/// the website. Every color in the UI is derived from these tokens.
class BrandColors {
  const BrandColors._();

  // Primary Softel brand.
  static const primary = Color(0xFF009EE0); // Softel cyan blue
  static const primaryHover = Color(0xFF0082BA);
  static const primaryPressed = Color(0xFF006894);
  static const primarySubtle = Color(0xFFE0F2FE); // light background tints

  // Neutral scales (Slate). Light mode canvas:
  static const lightBg = Color(0xFFF8FAFC); // Slate 50
  static const lightSurface = Color(0xFFFFFFFF); // card
  static const lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextMuted = Color(0xFF64748B);

  // Dark mode canvas:
  static const darkBg = Color(0xFF0F172A); // Slate 900
  static const darkSurface = Color(0xFF1E293B); // Slate 800 card
  static const darkBorder = Color(0xFF334155); // Slate 700
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextMuted = Color(0xFF94A3B8);

  // Semantic.
  static const success = Color(0xFF10B981); // emerald
  static const warning = Color(0xFFF59E0B); // amber
  static const danger = Color(0xFFEF4444); // rose red
  static const info = primary;

  // Legacy names kept so existing widgets and tests keep compiling. `navy` is
  // now the Slate 900 ink used for text on Softel Blue (6:1 contrast; white
  // on #009EE0 is only 3:1), `accent*` map to the primary scale.
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFFE2E8F0);
  static const navy = Color(0xFF0F172A);
  static const accent = primary;
  static const accentHover = primaryHover;
  static const accentPressed = primaryPressed;
}

/// Spacing scale shared by every screen.
class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Horizontal gutter of a page.
  static const page = 28.0;
}

/// Corner radii.
class AppRadius {
  const AppRadius._();

  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;

  /// Badges and pills.
  static const pill = 999.0;
}

/// Elevation shadows (soft, Fluent-like).
class AppShadows {
  const AppShadows._();

  static List<BoxShadow> card(Brightness b) => [
    BoxShadow(
      color: BrandColors.navy.withValues(alpha: b == Brightness.light ? 0.06 : 0.35),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> dialog(Brightness b) => [
    BoxShadow(
      color: BrandColors.black.withValues(alpha: b == Brightness.light ? 0.18 : 0.5),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];
}

/// Semantic colors not covered by [ColorScheme].
@immutable
class CrmColors extends ThemeExtension<CrmColors> {
  const CrmColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.info,
    required this.infoContainer,
    required this.sidebarBackground,
    required this.sidebarForeground,
    required this.sidebarMuted,
    required this.sidebarSelected,
    required this.sidebarAccent,
    required this.canvas,
    required this.accent,
    required this.onAccent,
  });

  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color info;
  final Color infoContainer;
  final Color sidebarBackground;
  final Color sidebarForeground;
  final Color sidebarMuted;
  final Color sidebarSelected;
  final Color sidebarAccent;

  /// Page background behind cards.
  final Color canvas;

  /// Brand accent (primary actions, selection) and the text color on it.
  final Color accent;
  final Color onAccent;

  static const light = CrmColors(
    success: Color(0xFF047857),
    successContainer: Color(0xFFD1FAE5),
    warning: Color(0xFFB45309),
    warningContainer: Color(0xFFFEF3C7),
    danger: Color(0xFFB91C1C),
    dangerContainer: Color(0xFFFEE2E2),
    info: Color(0xFF0369A1),
    infoContainer: BrandColors.primarySubtle,
    sidebarBackground: BrandColors.lightSurface,
    sidebarForeground: BrandColors.lightTextPrimary,
    sidebarMuted: BrandColors.lightTextMuted,
    sidebarSelected: BrandColors.primarySubtle,
    sidebarAccent: BrandColors.primaryHover,
    canvas: BrandColors.lightBg,
    accent: BrandColors.primary,
    onAccent: BrandColors.navy,
  );

  static const dark = CrmColors(
    success: Color(0xFF34D399),
    successContainer: Color(0xFF0B3B2E),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF3A2A0B),
    danger: Color(0xFFF87171),
    dangerContainer: Color(0xFF3B1818),
    info: Color(0xFF38BDF8),
    infoContainer: Color(0xFF0C2D48),
    sidebarBackground: Color(0xFF0B1220),
    sidebarForeground: BrandColors.darkTextPrimary,
    sidebarMuted: BrandColors.darkTextMuted,
    sidebarSelected: BrandColors.darkSurface,
    sidebarAccent: BrandColors.primary,
    canvas: BrandColors.darkBg,
    accent: BrandColors.primary,
    onAccent: BrandColors.navy,
  );

  @override
  CrmColors copyWith() => this;

  @override
  CrmColors lerp(ThemeExtension<CrmColors>? other, double t) => t < 0.5 ? this : (other as CrmColors? ?? this);
}

extension CrmThemeX on BuildContext {
  CrmColors get crm => Theme.of(this).extension<CrmColors>() ?? CrmColors.light;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

class AppTheme {
  const AppTheme._();

  /// Alexandria for Arabic, Quicksand for French / English, loaded through
  /// `google_fonts` (downloaded once, then cached). While a font is loading or
  /// unavailable offline, the system fonts below keep the UI readable.
  static const arabicFont = 'Alexandria';
  static const latinFont = 'Quicksand';

  /// Tests switch this off so no font is fetched from the network.
  static bool useGoogleFonts = true;

  static TextTheme _themed(String languageCode, TextTheme base) {
    if (!useGoogleFonts) return base;
    return languageCode == 'ar' ? GoogleFonts.alexandriaTextTheme(base) : GoogleFonts.quicksandTextTheme(base);
  }

  static TextStyle _buttonFont(String languageCode, String fontFamily, List<String> fallback) {
    const weight = FontWeight.w600;
    if (!useGoogleFonts) {
      return TextStyle(fontFamily: fontFamily, fontFamilyFallback: fallback, fontWeight: weight);
    }
    final style = languageCode == 'ar'
        ? GoogleFonts.alexandria(fontWeight: weight)
        : GoogleFonts.quicksand(fontWeight: weight);
    return style.copyWith(fontFamilyFallback: fallback);
  }

  static const _systemFonts = ['Segoe UI', 'Cairo', 'Inter', 'Tahoma', 'Arial', 'Noto Sans Arabic'];

  static String fontFamilyFor(String languageCode) => languageCode == 'ar' ? arabicFont : latinFont;

  static List<String> fontFallbackFor(String languageCode) => [
    languageCode == 'ar' ? latinFont : arabicFont,
    ..._systemFonts,
  ];

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: BrandColors.primary,
    onPrimary: BrandColors.white,
    primaryContainer: BrandColors.primarySubtle,
    onPrimaryContainer: Color(0xFF075985),
    secondary: BrandColors.primary,
    onSecondary: BrandColors.white,
    secondaryContainer: BrandColors.primarySubtle,
    onSecondaryContainer: Color(0xFF075985),
    tertiary: Color(0xFF475569),
    onTertiary: BrandColors.white,
    error: Color(0xFFB91C1C),
    onError: BrandColors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: BrandColors.lightSurface,
    onSurface: BrandColors.lightTextPrimary,
    onSurfaceVariant: BrandColors.lightTextMuted,
    surfaceContainerLowest: BrandColors.lightSurface,
    surfaceContainerLow: BrandColors.lightBg,
    surfaceContainer: Color(0xFFF1F5F9),
    surfaceContainerHigh: Color(0xFFE9EEF5),
    surfaceContainerHighest: BrandColors.lightBorder,
    outline: Color(0xFF94A3B8),
    outlineVariant: BrandColors.lightBorder,
    inverseSurface: BrandColors.darkBg,
    onInverseSurface: BrandColors.darkTextPrimary,
    inversePrimary: BrandColors.primary,
    shadow: BrandColors.black,
    scrim: BrandColors.black,
    surfaceTint: Colors.transparent,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: BrandColors.primary,
    onPrimary: BrandColors.white,
    primaryContainer: Color(0xFF0C3A57),
    onPrimaryContainer: Color(0xFFBAE6FD),
    secondary: BrandColors.primary,
    onSecondary: BrandColors.white,
    secondaryContainer: Color(0xFF0C3A57),
    onSecondaryContainer: Color(0xFFBAE6FD),
    tertiary: Color(0xFFCBD5E1),
    onTertiary: BrandColors.navy,
    error: Color(0xFFF87171),
    onError: Color(0xFF3B0A0A),
    errorContainer: Color(0xFF5B1A1A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: BrandColors.darkBg,
    onSurface: BrandColors.darkTextPrimary,
    onSurfaceVariant: BrandColors.darkTextMuted,
    surfaceContainerLowest: BrandColors.darkSurface,
    surfaceContainerLow: Color(0xFF223047),
    surfaceContainer: Color(0xFF273449),
    surfaceContainerHigh: Color(0xFF2F3D54),
    surfaceContainerHighest: BrandColors.darkBorder,
    outline: Color(0xFF64748B),
    outlineVariant: BrandColors.darkBorder,
    inverseSurface: BrandColors.lightBorder,
    onInverseSurface: BrandColors.lightTextPrimary,
    inversePrimary: BrandColors.primaryPressed,
    shadow: BrandColors.black,
    scrim: BrandColors.black,
    surfaceTint: Colors.transparent,
  );

  /// Theme for [locale]: Alexandria for Arabic, Readex Pro for French and
  /// English.
  static ThemeData theme(Locale locale, {Brightness brightness = Brightness.light}) => brightness == Brightness.dark
      ? dark(languageCode: locale.languageCode)
      : light(languageCode: locale.languageCode);

  static ThemeData light({String languageCode = 'fr'}) => _build(_lightScheme, CrmColors.light, languageCode);

  static ThemeData dark({String languageCode = 'fr'}) => _build(_darkScheme, CrmColors.dark, languageCode);

  static ThemeData _build(ColorScheme scheme, CrmColors crm, String languageCode) {
    final isLight = scheme.brightness == Brightness.light;
    final fontFamily = fontFamilyFor(languageCode);
    final fontFallback = fontFallbackFor(languageCode);
    // A button theme replaces (not merges) the default style, so it names the
    // font family itself.
    final buttonText = _buttonFont(languageCode, fontFamily, fontFallback);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.compact,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
    );

    final fontTheme = _themed(languageCode, base.textTheme);

    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
    final focusColor = BrandColors.primary;

    // Interaction states shared by the button styles.
    Color accentFill(Set<WidgetState> s) {
      if (s.contains(WidgetState.disabled)) {
        return scheme.surfaceContainerHighest;
      }
      if (s.contains(WidgetState.pressed)) return BrandColors.accentPressed;
      if (s.contains(WidgetState.hovered)) return BrandColors.accentHover;
      return BrandColors.accent;
    }

    BorderSide? focusRing(Set<WidgetState> s) =>
        s.contains(WidgetState.focused) ? BorderSide(color: focusColor, width: 2) : null;

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));

    return base.copyWith(
      scaffoldBackgroundColor: crm.canvas,
      extensions: [crm],
      focusColor: focusColor.withValues(alpha: 0.12),
      hoverColor: scheme.onSurface.withValues(alpha: 0.05),
      splashFactory: InkRipple.splashFactory,
      textTheme: fontTheme
          .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
          .copyWith(
            headlineMedium: fontTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 28),
            headlineSmall: fontTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 22),
            titleLarge: fontTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
            titleMedium: fontTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
            titleSmall: fontTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            labelLarge: fontTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            bodyMedium: fontTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLowest,
        shadowColor: BrandColors.navy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        hoverColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        // Natural icon proportions: 18px glyphs centred in a 40px slot.
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        border: border(scheme.outlineVariant),
        enabledBorder: border(scheme.outlineVariant),
        disabledBorder: border(scheme.outlineVariant.withValues(alpha: 0.6)),
        focusedBorder: border(focusColor, 2),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 2),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        elevation: 0,
        shadowColor: BrandColors.black,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
          shape: WidgetStatePropertyAll(buttonShape),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith(accentFill),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? scheme.onSurface.withValues(alpha: 0.4) : BrandColors.white,
          ),
          side: WidgetStateProperty.resolveWith(focusRing),
          textStyle: WidgetStatePropertyAll(buttonText),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          shape: WidgetStatePropertyAll(buttonShape),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? scheme.onSurface.withValues(alpha: 0.38)
                : (isLight ? BrandColors.navy : scheme.onSurface),
          ),
          side: WidgetStateProperty.resolveWith(
            (s) =>
                focusRing(s) ??
                BorderSide(color: s.contains(WidgetState.hovered) ? scheme.outline : scheme.outlineVariant),
          ),
          overlayColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.06)),
          textStyle: WidgetStatePropertyAll(buttonText),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(buttonShape),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? scheme.onSurface.withValues(alpha: 0.38)
                : (isLight ? BrandColors.primaryPressed : BrandColors.primary),
          ),
          side: WidgetStateProperty.resolveWith(focusRing),
          overlayColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.06)),
          textStyle: WidgetStatePropertyAll(buttonText),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
          side: WidgetStateProperty.resolveWith(focusRing),
          overlayColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.08)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(buttonShape),
          side: WidgetStatePropertyAll(BorderSide(color: scheme.outlineVariant)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.primaryContainer : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? BrandColors.navy : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? BrandColors.accent : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? BrandColors.accent : scheme.outline,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? BrandColors.accent : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(BrandColors.navy),
        side: BorderSide(color: scheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: isLight ? BrandColors.navy : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: TextStyle(color: isLight ? BrandColors.white : scheme.onSurface, fontSize: 12.5),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: BrandColors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerLowest),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primaryContainer,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: BrandColors.accent),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: focusColor,
        selectionColor: BrandColors.accent.withValues(alpha: 0.35),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(true),
        thumbColor: WidgetStatePropertyAll(scheme.outline.withValues(alpha: 0.55)),
        radius: const Radius.circular(8),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }
}
