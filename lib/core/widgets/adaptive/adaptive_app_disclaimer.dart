import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveAppDisclaimer extends StatelessWidget {
  const AdaptiveAppDisclaimer({
    super.key,
    required this.message,
    this.icon,
    this.action,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.borderRadius,
  });

  final String message;
  final Widget? icon;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? iconColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (!kIsWeb && platform == TargetPlatform.iOS) {
      return _CupertinoAdaptiveDisclaimer(
        message: message,
        icon: icon,
        action: action,
        padding: padding,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        iconColor: iconColor,
        borderRadius: borderRadius,
      );
    }

    return _MaterialAdaptiveDisclaimer(
      message: message,
      icon: icon,
      action: action,
      padding: padding,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconColor: iconColor,
      borderRadius: borderRadius,
    );
  }
}

class _MaterialAdaptiveDisclaimer extends StatelessWidget {
  const _MaterialAdaptiveDisclaimer({
    required this.message,
    required this.icon,
    required this.action,
    required this.padding,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconColor,
    required this.borderRadius,
  });

  final String message;
  final Widget? icon;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? iconColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final resolvedIconColor = iconColor ?? colors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surfaceContainerLow,
        borderRadius: borderRadius ?? BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: _DisclaimerContent(
          message: message,
          icon: icon ?? const Icon(Icons.shield),
          action: action,
          foregroundColor: foregroundColor ?? colors.onSurfaceVariant,
          iconColor: resolvedIconColor,
          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.55,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CupertinoAdaptiveDisclaimer extends StatelessWidget {
  const _CupertinoAdaptiveDisclaimer({
    required this.message,
    required this.icon,
    required this.action,
    required this.padding,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.iconColor,
    required this.borderRadius,
  });

  final String message;
  final Widget? icon;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? iconColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final resolvedIconColor = iconColor ?? cupertinoTheme.primaryColor;
    final radius = borderRadius ?? BorderRadius.circular(24);
    final surfaceColor = cupertinoTheme.barBackgroundColor;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ?? surfaceColor.withValues(alpha: 0.62),
            borderRadius: radius,
            border: Border.all(
              color: cupertinoTheme.primaryContrastingColor.withValues(
                alpha: 0.36,
              ),
            ),
          ),
          child: Padding(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: _DisclaimerContent(
              message: message,
              icon: icon ?? const Icon(CupertinoIcons.lock_fill),
              action: action,
              foregroundColor:
                  foregroundColor ??
                  cupertinoTheme.textTheme.textStyle.color?.withValues(
                    alpha: 0.70,
                  ) ??
                  cupertinoTheme.primaryColor.withValues(alpha: 0.70),
              iconColor: resolvedIconColor,
              textStyle: cupertinoTheme.textTheme.textStyle.copyWith(
                height: 1.42,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DisclaimerContent extends StatelessWidget {
  const _DisclaimerContent({
    required this.message,
    required this.icon,
    required this.action,
    required this.foregroundColor,
    required this.iconColor,
    required this.textStyle,
  });

  final String message;
  final Widget icon;
  final Widget? action;
  final Color foregroundColor;
  final Color iconColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconTheme.merge(
          data: IconThemeData(color: iconColor, size: 26),
          child: icon,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(message, style: textStyle?.copyWith(color: foregroundColor)),
              if (action != null) ...<Widget>[
                const SizedBox(height: 14),
                action!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
