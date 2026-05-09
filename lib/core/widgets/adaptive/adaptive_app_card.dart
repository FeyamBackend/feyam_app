import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveAppCard extends StatelessWidget {
  const AdaptiveAppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.blur,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final double? elevation;
  final double? blur;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (!kIsWeb && platform == TargetPlatform.iOS) {
      return _CupertinoAdaptiveCard(
        padding: padding,
        margin: margin,
        width: width,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderRadius: borderRadius,
        elevation: elevation,
        blur: blur,
        child: child,
      );
    }

    return _MaterialAdaptiveCard(
      padding: padding,
      margin: margin,
      width: width,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      elevation: elevation,
      child: child,
    );
  }
}

class _MaterialAdaptiveCard extends StatelessWidget {
  const _MaterialAdaptiveCard({
    required this.child,
    required this.padding,
    required this.margin,
    required this.width,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.elevation,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(24);

    return Container(
      width: width,
      margin: margin,
      decoration: ShapeDecoration(
        color: backgroundColor ?? colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: borderColor ?? colors.outlineVariant.withValues(alpha: 0.72),
          ),
        ),
        shadows: <BoxShadow>[
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: elevation ?? 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32),
        child: child,
      ),
    );
  }
}

class _CupertinoAdaptiveCard extends StatelessWidget {
  const _CupertinoAdaptiveCard({
    required this.child,
    required this.padding,
    required this.margin,
    required this.width,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.elevation,
    required this.blur,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final double? elevation;
  final double? blur;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(34);
    final surface =
        backgroundColor ??
        theme.scaffoldBackgroundColor.withValues(alpha: 0.76);
    final resolvedElevation = elevation ?? 34;
    final shadows = resolvedElevation <= 0
        ? const <BoxShadow>[]
        : <BoxShadow>[
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.10),
              blurRadius: resolvedElevation,
              offset: const Offset(0, 18),
            ),
          ];

    return Container(
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur ?? 20, sigmaY: blur ?? 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: radius,
              border: Border.all(
                color:
                    borderColor ??
                    theme.primaryContrastingColor.withValues(alpha: 0.70),
              ),
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(36),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
