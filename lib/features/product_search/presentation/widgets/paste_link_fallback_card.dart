import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/cart/presentation/screens/add_to_cart.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Zinc only covers a subset of retailers/products — this keeps today's
/// manual paste-link flow one tap away instead of removing it.
class PasteLinkFallbackCard extends StatelessWidget {
  const PasteLinkFallbackCard({super.key});

  void _openManualAddToCart(BuildContext context) {
    Navigator.of(context).push(
      AdaptivePlatform.pageRoute(
        context: context,
        builder: (_) => const AddToCartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (AdaptivePlatform.isCupertino(context)) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        onPressed: () => _openManualAddToCart(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(CupertinoIcons.link, size: 17, color: kFeyamTint),
            const SizedBox(width: 8),
            Text(
              l10n.productSearchPasteLinkCta,
              style: const TextStyle(
                fontSize: 15,
                color: kFeyamTint,
                fontFamily: '.SF Pro Text',
              ),
            ),
          ],
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;
    return TextButton.icon(
      onPressed: () => _openManualAddToCart(context),
      icon: Icon(Icons.link_rounded, size: 18, color: colors.primary),
      label: Text(l10n.productSearchPasteLinkCta),
    );
  }
}
