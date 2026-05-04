import 'package:feyam/core/theme/app_theme_palette.dart';
import 'package:feyam/core/theme/app_theme_tokens.dart';
import 'package:flutter/cupertino.dart';

const List<String> _appleSystemFallback = <String>[
  'SF Pro Text',
  'SF Pro Display',
  '.SF UI Text',
  '.SF UI Display',
  'Segoe UI',
  'Roboto',
  'sans-serif',
];

TextStyle _cupertinoTextStyle({
  required TextStyle baseStyle,
  required double fontSize,
  required FontWeight fontWeight,
  required double lineHeight,
  required double letterSpacing,
}) {
  return TextStyle(
    inherit: baseStyle.inherit,
    color: baseStyle.color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: lineHeight / fontSize,
    letterSpacing: letterSpacing,
    fontFamilyFallback: _appleSystemFallback,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );
}

CupertinoThemeData buildCupertinoTheme() {
  final baseTheme = const CupertinoThemeData().copyWith(
    brightness: Brightness.light,
    primaryColor: CupertinoGlassVisionPalette.primary,
    primaryContrastingColor: CupertinoGlassVisionPalette.secondary,
    scaffoldBackgroundColor: CupertinoGlassVisionPalette.background,
    barBackgroundColor: CupertinoGlassVisionPalette.surface.withValues(
      alpha: 0.85,
    ),
  );
  final baseTextTheme = baseTheme.textTheme;

  return baseTheme.copyWith(
    textTheme: CupertinoTextThemeData(
      textStyle: _cupertinoTextStyle(
        baseStyle: baseTextTheme.textStyle,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        lineHeight: 22,
        letterSpacing: -0.01,
      ),
      navLargeTitleTextStyle: _cupertinoTextStyle(
        baseStyle: baseTextTheme.navLargeTitleTextStyle,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        lineHeight: 41,
        letterSpacing: -0.02,
      ),
      navTitleTextStyle: _cupertinoTextStyle(
        baseStyle: baseTextTheme.navTitleTextStyle,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        lineHeight: 28,
        letterSpacing: -0.01,
      ),
      navActionTextStyle: _cupertinoTextStyle(
        baseStyle: baseTextTheme.navActionTextStyle,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        lineHeight: 22,
        letterSpacing: -0.01,
      ),
      actionTextStyle: _cupertinoTextStyle(
        baseStyle: baseTextTheme.actionTextStyle,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        lineHeight: 20,
        letterSpacing: 0,
      ),
      tabLabelTextStyle: _cupertinoTextStyle(
        baseStyle: baseTextTheme.tabLabelTextStyle,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        lineHeight: 16,
        letterSpacing: 0.05,
      ),
      dateTimePickerTextStyle: _cupertinoTextStyle(
        baseStyle: baseTextTheme.dateTimePickerTextStyle,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        lineHeight: 34,
        letterSpacing: -0.01,
      ),
      pickerTextStyle: _cupertinoTextStyle(
        baseStyle: baseTextTheme.pickerTextStyle,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        lineHeight: 22,
        letterSpacing: -0.01,
      ),
    ),
  );
}

const AppThemeTokens cupertinoThemeTokens = AppThemeTokens(
  surfaceDim: CupertinoGlassVisionPalette.surfaceDim,
  surfaceBright: CupertinoGlassVisionPalette.surfaceBright,
  surfaceContainerLowest: CupertinoGlassVisionPalette.surfaceContainerLowest,
  surfaceContainerLow: CupertinoGlassVisionPalette.surfaceContainerLow,
  surfaceContainer: CupertinoGlassVisionPalette.surfaceContainer,
  surfaceContainerHigh: CupertinoGlassVisionPalette.surfaceContainerHigh,
  surfaceContainerHighest: CupertinoGlassVisionPalette.surfaceContainerHighest,
  onSurfaceVariant: CupertinoGlassVisionPalette.onSurfaceVariant,
  inverseSurface: CupertinoGlassVisionPalette.inverseSurface,
  inverseOnSurface: CupertinoGlassVisionPalette.inverseOnSurface,
  outlineVariant: CupertinoGlassVisionPalette.outlineVariant,
  surfaceVariant: CupertinoGlassVisionPalette.surfaceVariant,
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
  marginMobile: 20,
  gutter: 16,
  glassBackgroundOpacity: 0.6,
  glassBorderOpacity: 0.4,
  glassBorderWidth: 0.5,
  glassBlur: 30,
  activeShadowOpacity: 0.1,
  activeShadowBlur: 20,
  activeShadowYOffset: 4,
  cardStackOffset: 2,
);
