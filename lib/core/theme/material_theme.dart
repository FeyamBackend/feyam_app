import 'package:feyam/core/theme/app_theme_palette.dart';
import 'package:feyam/core/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const AppThemeTokens materialThemeTokens = AppThemeTokens(
  surfaceDim: ConciergeProPalette.surfaceDim,
  surfaceBright: ConciergeProPalette.surfaceBright,
  surfaceContainerLowest: ConciergeProPalette.surfaceContainerLowest,
  surfaceContainerLow: ConciergeProPalette.surfaceContainerLow,
  surfaceContainer: ConciergeProPalette.surfaceContainer,
  surfaceContainerHigh: ConciergeProPalette.surfaceContainerHigh,
  surfaceContainerHighest: ConciergeProPalette.surfaceContainerHighest,
  onSurfaceVariant: ConciergeProPalette.onSurfaceVariant,
  inverseSurface: ConciergeProPalette.inverseSurface,
  inverseOnSurface: ConciergeProPalette.inverseOnSurface,
  outlineVariant: ConciergeProPalette.outlineVariant,
  surfaceVariant: ConciergeProPalette.surfaceVariant,
  radiusSm: 4,
  radiusDefault: 8,
  radiusMd: 12,
  radiusLg: 16,
  radiusXl: 24,
  radiusFull: 9999,
  spaceXs: 4,
  spaceSm: 8,
  spaceMd: 16,
  spaceLg: 24,
  spaceXl: 32,
  marginMobile: 16,
  gutter: 12,
  glassBackgroundOpacity: 0.6,
  glassBorderOpacity: 0.4,
  glassBorderWidth: 0.5,
  glassBlur: 30,
  activeShadowOpacity: 0.1,
  activeShadowBlur: 20,
  activeShadowYOffset: 4,
  cardStackOffset: 2,
);

ThemeData buildMaterialTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: ConciergeProPalette.primary,
    onPrimary: ConciergeProPalette.onPrimary,
    primaryContainer: ConciergeProPalette.primaryContainer,
    onPrimaryContainer: ConciergeProPalette.onPrimaryContainer,
    secondary: ConciergeProPalette.secondary,
    onSecondary: ConciergeProPalette.onSecondary,
    secondaryContainer: ConciergeProPalette.secondaryContainer,
    onSecondaryContainer: ConciergeProPalette.onSecondaryContainer,
    tertiary: ConciergeProPalette.tertiary,
    onTertiary: ConciergeProPalette.onTertiary,
    tertiaryContainer: ConciergeProPalette.tertiaryContainer,
    onTertiaryContainer: ConciergeProPalette.onTertiaryContainer,
    error: ConciergeProPalette.error,
    onError: ConciergeProPalette.onError,
    errorContainer: ConciergeProPalette.errorContainer,
    onErrorContainer: ConciergeProPalette.onErrorContainer,
    surface: ConciergeProPalette.surface,
    onSurface: ConciergeProPalette.onSurface,
    onSurfaceVariant: ConciergeProPalette.onSurfaceVariant,
    outline: ConciergeProPalette.outline,
    outlineVariant: ConciergeProPalette.outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: ConciergeProPalette.inverseSurface,
    onInverseSurface: ConciergeProPalette.inverseOnSurface,
    inversePrimary: ConciergeProPalette.inversePrimary,
    surfaceTint: ConciergeProPalette.surfaceTint,
    surfaceContainerLowest: ConciergeProPalette.surfaceContainerLowest,
    surfaceContainerLow: ConciergeProPalette.surfaceContainerLow,
    surfaceContainer: ConciergeProPalette.surfaceContainer,
    surfaceContainerHigh: ConciergeProPalette.surfaceContainerHigh,
    surfaceContainerHighest: ConciergeProPalette.surfaceContainerHighest,
  );

  final baseTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: ConciergeProPalette.background,
  );

  final baseTextTheme = _isRunningWidgetTest()
      ? baseTheme.textTheme.apply(fontFamily: 'Lato')
      : GoogleFonts.latoTextTheme(baseTheme.textTheme);

  final textTheme = baseTextTheme.copyWith(
    displayLarge: baseTextTheme.displayLarge?.copyWith(
      fontSize: 57,
      height: 64 / 57,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    headlineMedium: baseTextTheme.headlineMedium?.copyWith(
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      fontSize: 22,
      height: 28 / 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
    labelSmall: baseTextTheme.labelSmall?.copyWith(
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      fontFeatures: const [FontFeature.tabularFigures()],
    ),
  );

  return baseTheme.copyWith(
    textTheme: textTheme,
    extensions: <ThemeExtension<dynamic>>[
      materialThemeTokens,
    ],
  );
}

bool _isRunningWidgetTest() {
  WidgetsBinding binding;
  try {
    binding = WidgetsBinding.instance;
  } catch (_) {
    return false;
  }

  final bindingType = binding.runtimeType.toString();
  return bindingType.contains('TestWidgetsFlutterBinding') ||
      bindingType.contains('AutomatedTestWidgetsFlutterBinding') ||
      bindingType.contains('LiveTestWidgetsFlutterBinding');
}
