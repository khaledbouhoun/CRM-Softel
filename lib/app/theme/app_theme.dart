import 'package:flutter/material.dart';

/// SOFTEL brand palette (the only hues the UI is built from).
class BrandColors {
  const BrandColors._();

  static const black = Color(0xFF000000);
  static const navy = Color(0xFF14213D);
  static const accent = Color.fromARGB(255, 13, 194, 240);
  static const grey = Color(0xFFE5E5E5);
  static const white = Color(0xFFFFFFFF);

  /// Accent shades for hover / pressed states.
  static const accentHover = Color(0xFFE8920A);
  static const accentPressed = Color(0xFFCC7F06);
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
  static const pill = 20.0;
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
    success: Color(0xFF15803D),
    successContainer: Color(0xFFDCFCE7),
    warning: Color(0xFFB45309),
    warningContainer: Color(0xFFFEF3C7),
    danger: Color(0xFFB91C1C),
    dangerContainer: Color(0xFFFEE2E2),
    info: Color(0xFF1D4ED8),
    infoContainer: Color(0xFFDBEAFE),
    sidebarBackground: BrandColors.navy,
    sidebarForeground: BrandColors.grey,
    sidebarMuted: Color(0xFF9AA3BC),
    sidebarSelected: Color(0xFF22335C),
    sidebarAccent: BrandColors.accent,
    canvas: Color(0xFFF4F5F7),
    accent: BrandColors.accent,
    onAccent: BrandColors.navy,
  );

  static const dark = CrmColors(
    success: Color(0xFF4ADE80),
    successContainer: Color(0xFF123524),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF3A2A0B),
    danger: Color(0xFFF87171),
    dangerContainer: Color(0xFF3B1818),
    info: Color(0xFF7DB2FF),
    infoContainer: Color(0xFF16294A),
    sidebarBackground: Color(0xFF0F1830),
    sidebarForeground: BrandColors.grey,
    sidebarMuted: Color(0xFF8590AE),
    sidebarSelected: Color(0xFF1C2C52),
    sidebarAccent: BrandColors.accent,
    canvas: Color(0xFF0B1220),
    accent: BrandColors.accent,
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

  /// Segoe UI covers Latin and Arabic on Windows; the fallbacks keep other
  /// machines readable.
  static const fontFamily = 'Segoe UI';
  static const fontFallback = ['Segoe UI', 'Tahoma', 'Arial', 'Noto Sans Arabic'];

  /// Button label style. It must name the font family itself: a button theme
  /// replaces (not merges) the default style, and Arabic needs the fallbacks.
  static const _buttonText = TextStyle(fontFamily: fontFamily, fontFamilyFallback: fontFallback, fontWeight: FontWeight.w600);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: BrandColors.navy,
    onPrimary: BrandColors.white,
    primaryContainer: Color(0xFFFFE6B8),
    onPrimaryContainer: BrandColors.navy,
    secondary: BrandColors.accent,
    onSecondary: BrandColors.navy,
    secondaryContainer: Color(0xFFFFEFCF),
    onSecondaryContainer: BrandColors.navy,
    tertiary: Color(0xFF3A4A72),
    onTertiary: BrandColors.white,
    error: Color(0xFFB91C1C),
    onError: BrandColors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: BrandColors.white,
    onSurface: BrandColors.black,
    onSurfaceVariant: Color(0xFF4A5068),
    surfaceContainerLowest: BrandColors.white,
    surfaceContainerLow: Color(0xFFFAFAFB),
    surfaceContainer: Color(0xFFF4F4F6),
    surfaceContainerHigh: Color(0xFFEDEDF0),
    surfaceContainerHighest: BrandColors.grey,
    outline: Color(0xFF9399AB),
    outlineVariant: BrandColors.grey,
    inverseSurface: BrandColors.navy,
    onInverseSurface: BrandColors.white,
    inversePrimary: BrandColors.accent,
    shadow: BrandColors.black,
    scrim: BrandColors.black,
    surfaceTint: Colors.transparent,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: BrandColors.accent,
    onPrimary: BrandColors.navy,
    primaryContainer: Color(0xFF4A3508),
    onPrimaryContainer: Color(0xFFFFE6B8),
    secondary: BrandColors.accent,
    onSecondary: BrandColors.navy,
    secondaryContainer: Color(0xFF3E2F10),
    onSecondaryContainer: Color(0xFFFFE6B8),
    tertiary: Color(0xFF9FB0DA),
    onTertiary: BrandColors.navy,
    error: Color(0xFFF87171),
    onError: Color(0xFF3B0A0A),
    errorContainer: Color(0xFF5B1A1A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF101A30),
    onSurface: Color(0xFFF5F5F7),
    onSurfaceVariant: Color(0xFFB7BDCE),
    surfaceContainerLowest: BrandColors.navy,
    surfaceContainerLow: Color(0xFF182646),
    surfaceContainer: Color(0xFF1B2A4D),
    surfaceContainerHigh: Color(0xFF22335C),
    surfaceContainerHighest: Color(0xFF2B3E6B),
    outline: Color(0xFF6E7A9C),
    outlineVariant: Color(0xFF2E3E66),
    inverseSurface: BrandColors.grey,
    onInverseSurface: BrandColors.navy,
    inversePrimary: BrandColors.navy,
    shadow: BrandColors.black,
    scrim: BrandColors.black,
    surfaceTint: Colors.transparent,
  );

  static ThemeData light() => _build(_lightScheme, CrmColors.light);

  static ThemeData dark() => _build(_darkScheme, CrmColors.dark);

  static ThemeData _build(ColorScheme scheme, CrmColors crm) {
    final isLight = scheme.brightness == Brightness.light;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.compact,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
    );

    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
    final focusColor = isLight ? BrandColors.navy : BrandColors.accent;

    // Interaction states shared by the button styles.
    Color accentFill(Set<WidgetState> s) {
      if (s.contains(WidgetState.disabled)) {
        return scheme.surfaceContainerHighest;
      }
      if (s.contains(WidgetState.pressed)) return BrandColors.accentPressed;
      if (s.contains(WidgetState.hovered)) return BrandColors.accentHover;
      return BrandColors.accent;
    }

    BorderSide? focusRing(Set<WidgetState> s) => s.contains(WidgetState.focused) ? BorderSide(color: focusColor, width: 2) : null;

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));

    return base.copyWith(
      scaffoldBackgroundColor: crm.canvas,
      extensions: [crm],
      focusColor: focusColor.withValues(alpha: 0.12),
      hoverColor: scheme.onSurface.withValues(alpha: 0.05),
      splashFactory: InkRipple.splashFactory,
      textTheme: base.textTheme
          .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
          .copyWith(
            headlineSmall: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 22),
            titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
            titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
            titleSmall: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
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
        border: border(scheme.outlineVariant),
        enabledBorder: border(isLight ? const Color(0xFFD2D2D8) : scheme.outlineVariant),
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
          borderRadius: BorderRadius.circular(AppRadius.xl),
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
            (s) => s.contains(WidgetState.disabled) ? scheme.onSurface.withValues(alpha: 0.4) : BrandColors.navy,
          ),
          side: WidgetStateProperty.resolveWith(focusRing),
          textStyle: const WidgetStatePropertyAll(_buttonText),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          shape: WidgetStatePropertyAll(buttonShape),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? scheme.onSurface.withValues(alpha: 0.38) : (isLight ? BrandColors.navy : scheme.onSurface),
          ),
          side: WidgetStateProperty.resolveWith(
            (s) =>
                focusRing(s) ??
                BorderSide(color: s.contains(WidgetState.hovered) ? scheme.outline : (isLight ? const Color(0xFFD2D2D8) : scheme.outlineVariant)),
          ),
          overlayColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.06)),
          textStyle: const WidgetStatePropertyAll(_buttonText),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(buttonShape),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? scheme.onSurface.withValues(alpha: 0.38) : (isLight ? BrandColors.navy : BrandColors.accent),
          ),
          side: WidgetStateProperty.resolveWith(focusRing),
          overlayColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.06)),
          textStyle: const WidgetStatePropertyAll(_buttonText),
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
          side: WidgetStatePropertyAll(BorderSide(color: isLight ? const Color(0xFFD2D2D8) : scheme.outlineVariant)),
          backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? scheme.primaryContainer : Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? BrandColors.navy : scheme.outline),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? BrandColors.accent : scheme.surfaceContainerHighest),
        trackOutlineColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? BrandColors.accent : scheme.outline),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? BrandColors.accent : Colors.transparent),
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
      textSelectionTheme: TextSelectionThemeData(cursorColor: focusColor, selectionColor: BrandColors.accent.withValues(alpha: 0.35)),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: const WidgetStatePropertyAll(true),
        thumbColor: WidgetStatePropertyAll(scheme.outline.withValues(alpha: 0.55)),
        radius: const Radius.circular(8),
      ),
      listTileTheme: ListTileThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
    );
  }
}
