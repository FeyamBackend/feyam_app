import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurfaceVariant,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.outlineVariant,
    required this.surfaceVariant,
    required this.radiusSm,
    required this.radiusDefault,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusFull,
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.marginMobile,
    required this.gutter,
    required this.glassBackgroundOpacity,
    required this.glassBorderOpacity,
    required this.glassBorderWidth,
    required this.glassBlur,
    required this.activeShadowOpacity,
    required this.activeShadowBlur,
    required this.activeShadowYOffset,
    required this.cardStackOffset,
  });

  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color onSurfaceVariant;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color outlineVariant;
  final Color surfaceVariant;

  final double radiusSm;
  final double radiusDefault;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radiusFull;

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double marginMobile;
  final double gutter;

  final double glassBackgroundOpacity;
  final double glassBorderOpacity;
  final double glassBorderWidth;
  final double glassBlur;
  final double activeShadowOpacity;
  final double activeShadowBlur;
  final double activeShadowYOffset;
  final double cardStackOffset;

  @override
  AppThemeTokens copyWith({
    Color? surfaceDim,
    Color? surfaceBright,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? onSurfaceVariant,
    Color? inverseSurface,
    Color? inverseOnSurface,
    Color? outlineVariant,
    Color? surfaceVariant,
    double? radiusSm,
    double? radiusDefault,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? radiusFull,
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? marginMobile,
    double? gutter,
    double? glassBackgroundOpacity,
    double? glassBorderOpacity,
    double? glassBorderWidth,
    double? glassBlur,
    double? activeShadowOpacity,
    double? activeShadowBlur,
    double? activeShadowYOffset,
    double? cardStackOffset,
  }) {
    return AppThemeTokens(
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      inverseOnSurface: inverseOnSurface ?? this.inverseOnSurface,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusDefault: radiusDefault ?? this.radiusDefault,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusFull: radiusFull ?? this.radiusFull,
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      marginMobile: marginMobile ?? this.marginMobile,
      gutter: gutter ?? this.gutter,
      glassBackgroundOpacity:
          glassBackgroundOpacity ?? this.glassBackgroundOpacity,
      glassBorderOpacity: glassBorderOpacity ?? this.glassBorderOpacity,
      glassBorderWidth: glassBorderWidth ?? this.glassBorderWidth,
      glassBlur: glassBlur ?? this.glassBlur,
      activeShadowOpacity: activeShadowOpacity ?? this.activeShadowOpacity,
      activeShadowBlur: activeShadowBlur ?? this.activeShadowBlur,
      activeShadowYOffset: activeShadowYOffset ?? this.activeShadowYOffset,
      cardStackOffset: cardStackOffset ?? this.cardStackOffset,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) {
      return this;
    }

    return AppThemeTokens(
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t) ?? surfaceDim,
      surfaceBright:
          Color.lerp(surfaceBright, other.surfaceBright, t) ?? surfaceBright,
      surfaceContainerLowest:
          Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t) ??
              surfaceContainerLowest,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t) ??
              surfaceContainerLow,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t) ??
              surfaceContainer,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t) ??
              surfaceContainerHigh,
      surfaceContainerHighest:
          Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t) ??
              surfaceContainerHighest,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t) ??
              onSurfaceVariant,
      inverseSurface:
          Color.lerp(inverseSurface, other.inverseSurface, t) ?? inverseSurface,
      inverseOnSurface:
          Color.lerp(inverseOnSurface, other.inverseOnSurface, t) ??
              inverseOnSurface,
      outlineVariant:
          Color.lerp(outlineVariant, other.outlineVariant, t) ?? outlineVariant,
      surfaceVariant:
          Color.lerp(surfaceVariant, other.surfaceVariant, t) ?? surfaceVariant,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t),
      radiusDefault: lerpDouble(radiusDefault, other.radiusDefault, t),
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t),
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t),
      radiusFull: lerpDouble(radiusFull, other.radiusFull, t),
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t),
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t),
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t),
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t),
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t),
      marginMobile: lerpDouble(marginMobile, other.marginMobile, t),
      gutter: lerpDouble(gutter, other.gutter, t),
      glassBackgroundOpacity:
          lerpDouble(glassBackgroundOpacity, other.glassBackgroundOpacity, t),
      glassBorderOpacity:
          lerpDouble(glassBorderOpacity, other.glassBorderOpacity, t),
      glassBorderWidth: lerpDouble(glassBorderWidth, other.glassBorderWidth, t),
      glassBlur: lerpDouble(glassBlur, other.glassBlur, t),
      activeShadowOpacity:
          lerpDouble(activeShadowOpacity, other.activeShadowOpacity, t),
      activeShadowBlur: lerpDouble(activeShadowBlur, other.activeShadowBlur, t),
      activeShadowYOffset:
          lerpDouble(activeShadowYOffset, other.activeShadowYOffset, t),
      cardStackOffset: lerpDouble(cardStackOffset, other.cardStackOffset, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
