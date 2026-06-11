import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoSuccessContent();
    }

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return Scaffold(
          backgroundColor: colors.surface,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32 * scale),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      builder: (_, v, child) => Transform.scale(scale: v, child: child),
                      child: Container(
                        width: 96 * scale,
                        height: 96 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.secondaryContainer,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 56 * scale,
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                    Text(
                      l10n.successTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w400,
                        fontSize: 28 * scale,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Text(
                      l10n.successBody,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 15 * scale,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32 * scale),
                    SizedBox(
                      width: 280 * scale,
                      height: 52 * scale,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(l10n.successViewOrders),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Cupertino Success ─────────────────────────────────────────────────────────

class _CupertinoSuccessContent extends StatelessWidget {
  const _CupertinoSuccessContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kFeyamGreen.withValues(alpha: 0.12),
                    ),
                    child: const Icon(CupertinoIcons.checkmark_circle_fill, size: 60, color: kFeyamGreen),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.successTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: kFeyamLabel,
                    letterSpacing: 0.36,
                    fontFamily: '.SF Pro Display',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.successBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: kFeyamLabelSec,
                    height: 1.47,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 300,
                  child: FeyamButton(
                    label: l10n.successViewOrders,
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
