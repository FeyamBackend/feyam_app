import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shown once a cart is submitted (no payment involved). The customer must
/// wait for a price_confirmator to confirm the final price before paying —
/// they'll get a push notification when that happens.
class OrderSubmittedScreen extends StatelessWidget {
  const OrderSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoOrderSubmittedContent();
    }

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return Scaffold(
          backgroundColor: colors.surface,
          body: DefaultTextStyle(
            style: const TextStyle(decoration: TextDecoration.none),
            child: SafeArea(
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
                        builder: (_, v, child) =>
                            Transform.scale(scale: v, child: child),
                        child: Container(
                          width: 96 * scale,
                          height: 96 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.secondaryContainer,
                          ),
                          child: Icon(
                            Icons.hourglass_top_rounded,
                            size: 56 * scale,
                            color: colors.onSecondaryContainer,
                          ),
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      Text(
                        l10n.orderSubmittedTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 26 * scale,
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Text(
                        l10n.orderSubmittedBody,
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
                            backgroundColor: colors.secondary,
                            foregroundColor: colors.onSecondary,
                            shape: const StadiumBorder(),
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
          ),
        );
      },
    );
  }
}

class _CupertinoOrderSubmittedContent extends StatelessWidget {
  const _CupertinoOrderSubmittedContent();

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
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kFeyamTint.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      CupertinoIcons.hourglass,
                      size: 52,
                      color: kFeyamTint,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.orderSubmittedTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: kFeyamLabel,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.orderSubmittedBody,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: kFeyamLabelSec,
                    height: 1.47,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 300,
                  child: FeyamButton(
                    label: l10n.successViewOrders,
                    variant: FeyamButtonVariant.secondary,
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
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
