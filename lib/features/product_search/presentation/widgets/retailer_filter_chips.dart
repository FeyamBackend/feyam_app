import 'package:feyam/core/utils/zinc_retailer_slug.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/stores/domain/entities/store_entity.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Builds the retailer filter options from Feyam's own store catalog (the
/// same one behind GET /api/stores and the "Tiendas soportadas" screen),
/// so the chips always match what's actually offered — no separate
/// hardcoded list to fall out of sync when a store is added/removed or
/// its per-country availability changes. Only stores Zinc can actually
/// search (kZincSearchableRetailerSlugs) get a chip; e.g. SHEIN is in the
/// catalog but not in that set, since Zinc doesn't cover it at all.
List<(String? value, String label)> productSearchRetailerOptions(
  AppLocalizations l10n,
  List<StoreEntity> stores,
) {
  final options = <(String? value, String label)>[(null, l10n.productSearchChipAll)];
  final seenSlugs = <String>{};

  for (final store in stores) {
    final slug = zincRetailerSlugFromHost(store.host);
    if (slug == null || !kZincSearchableRetailerSlugs.contains(slug)) continue;
    if (!seenSlugs.add(slug)) continue; // two stores mapping to the same slug — keep the first
    options.add((slug, store.name));
  }

  return options;
}

class RetailerFilterChips extends StatelessWidget {
  const RetailerFilterChips({
    super.key,
    required this.selectedRetailer,
    required this.stores,
    required this.onChanged,
  });

  final String? selectedRetailer;
  final List<StoreEntity> stores;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = productSearchRetailerOptions(AppLocalizations.of(context)!, stores);

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label) = options[index];
          final selected = value == selectedRetailer;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onChanged(value),
          );
        },
      ),
    );
  }
}

/// Cupertino equivalent — a horizontally scrollable pill row rather than
/// FeyamSegmented, since that widget splits its width evenly across all
/// options and can't scroll, which breaks down once there are more than 2-3.
class CupertinoRetailerChips extends StatelessWidget {
  const CupertinoRetailerChips({
    super.key,
    required this.selectedRetailer,
    required this.stores,
    required this.onChanged,
  });

  final String? selectedRetailer;
  final List<StoreEntity> stores;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = productSearchRetailerOptions(AppLocalizations.of(context)!, stores);

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label) = options[index];
          final selected = value == selectedRetailer;
          return GestureDetector(
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? kFeyamTint : kFeyamFillTer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? CupertinoColors.white : kFeyamLabelSec,
                  fontFamily: '.SF Pro Text',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
