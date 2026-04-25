import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveAppButton extends StatelessWidget {
  const AdaptiveAppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.height = 56,
    this.backgroundColor,
    this.foregroundColor,
    this.cupertinoGradient,
    this.borderRadius,
    this.padding,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool expand;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? cupertinoGradient;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (!kIsWeb && platform == TargetPlatform.iOS) {
      return _CupertinoAdaptiveButton(
        text: text,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        expand: expand,
        height: height,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        gradient: cupertinoGradient,
        borderRadius: borderRadius,
        padding: padding,
      );
    }

    return _MaterialAdaptiveButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      expand: expand,
      height: height,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderRadius: borderRadius,
      padding: padding,
    );
  }
}

class _MaterialAdaptiveButton extends StatelessWidget {
  const _MaterialAdaptiveButton({
    required this.text,
    required this.onPressed,
    required this.icon,
    required this.isLoading,
    required this.expand,
    required this.height,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderRadius,
    required this.padding,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool expand;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(14);
    final child = _ButtonContent(
      text: text,
      icon: icon,
      isLoading: isLoading,
      progressColor: foregroundColor ?? colors.onPrimary,
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colors.primary,
          foregroundColor: foregroundColor ?? colors.onPrimary,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.52),
          disabledForegroundColor: colors.onPrimary.withValues(alpha: 0.72),
          elevation: 8,
          shadowColor: colors.primary.withValues(alpha: 0.26),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        child: child,
      ),
    );
  }
}

class _CupertinoAdaptiveButton extends StatelessWidget {
  const _CupertinoAdaptiveButton({
    required this.text,
    required this.onPressed,
    required this.icon,
    required this.isLoading,
    required this.expand,
    required this.height,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.gradient,
    required this.borderRadius,
    required this.padding,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool expand;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(14);
    final enabled = !isLoading && onPressed != null;
    final resolvedForeground = foregroundColor ?? theme.scaffoldBackgroundColor;
    final resolvedGradient =
        gradient ??
        LinearGradient(
          colors: <Color>[
            backgroundColor ?? theme.primaryColor,
            theme.primaryContrastingColor,
          ],
        );

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onPressed : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.primaryColor,
            gradient: backgroundColor == null ? resolvedGradient : null,
            borderRadius: radius,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: CupertinoColors.systemGrey
                    .resolveFrom(context)
                    .withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            width: expand ? double.infinity : null,
            height: height,
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: DefaultTextStyle(
                  style: theme.textTheme.actionTextStyle.copyWith(
                    color: resolvedForeground,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  child: _ButtonContent(
                    text: text,
                    icon: icon,
                    isLoading: isLoading,
                    progressColor: resolvedForeground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.text,
    required this.icon,
    required this.isLoading,
    required this.progressColor,
  });

  final String text;
  final Widget? icon;
  final bool isLoading;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (icon != null) ...<Widget>[
          const SizedBox(width: 12),
          IconTheme.merge(
            data: IconThemeData(color: progressColor, size: 24),
            child: icon!,
          ),
        ],
      ],
    );
  }
}
