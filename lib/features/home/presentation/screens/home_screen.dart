import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoHomeContent();
    }

    return const _MaterialHomeContent();
  }
}

class _MaterialHomeContent extends StatelessWidget {
  const _MaterialHomeContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 688).clamp(0.54, 1.0);

        return Column(
          children: <Widget>[
            _MaterialHomeHeader(scale: scale),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  28 * scale,
                  34 * scale,
                  28 * scale,
                  30 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _MaterialImportOrderCard(scale: scale),
                    SizedBox(height: 44 * scale),
                    _MaterialStoresSection(scale: scale),
                    SizedBox(height: 48 * scale),
                    _MaterialRecentOrdersSection(scale: scale),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MaterialHomeHeader extends StatelessWidget {
  const _MaterialHomeHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFE),
        border: Border(bottom: BorderSide(color: Color(0xFFD8DBE3))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            28 * scale,
            22 * scale,
            28 * scale,
            18 * scale,
          ),
          child: Row(
            children: <Widget>[
              Text(
                'Feyam',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: const Color(0xFF111315),
                  fontSize: 38 * scale,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialImportOrderCard extends StatelessWidget {
  const _MaterialImportOrderCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFE),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFFDADDE7), width: 1.5 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          28 * scale,
          30 * scale,
          28 * scale,
          30 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.homeImportOrderTitle,
              style: textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF111315),
                fontSize: 29 * scale,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            SizedBox(height: 20 * scale),
            Container(
              height: 80 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E6),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.link,
                    color: const Color(0xFF62676E),
                    size: 29 * scale,
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Text(
                      l10n.homePasteProductLink,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF999CA5),
                        fontSize: 29 * scale,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16 * scale),
            SizedBox(
              height: 80 * scale,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0A63C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18 * scale),
                  ),
                  textStyle: textTheme.headlineSmall?.copyWith(
                    fontSize: 29 * scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(l10n.homeImportButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialStoresSection extends StatelessWidget {
  const _MaterialStoresSection({required this.scale});

  final double scale;

  static const _stores = <_MaterialStore>[
    _MaterialStore(name: 'Amazon', label: 'amazon', background: Colors.black),
    _MaterialStore(name: 'eBay', label: 'eBay', background: Colors.black),
    _MaterialStore(name: 'Zara', label: 'ZARA', background: Color(0xFF3E3E3E)),
    _MaterialStore(name: 'Apple', label: 'Apple', background: Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.homePopularStoresTitleMaterial,
                style: textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF111315),
                  fontSize: 31 * scale,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                minimumSize: Size(0, 40 * scale),
              ),
              child: Text(
                l10n.homeSeeAll,
                style: textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF0059C7),
                  fontSize: 27 * scale,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (final store in _stores)
              _MaterialStoreItem(scale: scale, store: store),
          ],
        ),
      ],
    );
  }
}

class _MaterialStoreItem extends StatelessWidget {
  const _MaterialStoreItem({required this.scale, required this.store});

  final double scale;
  final _MaterialStore store;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 88 * scale,
      child: Column(
        children: <Widget>[
          Container(
            width: 88 * scale,
            height: 88 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFE3E5EA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD9DCE3)),
            ),
            child: Center(
              child: Container(
                width: 54 * scale,
                height: 54 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: store.background,
                  borderRadius: BorderRadius.circular(2 * scale),
                ),
                child: Text(
                  store.label,
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: store.background == Colors.white
                        ? colors.onSurface
                        : Colors.white,
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            store.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF2D3340),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialStore {
  const _MaterialStore({
    required this.name,
    required this.label,
    required this.background,
  });

  final String name;
  final String label;
  final Color background;
}

class _MaterialRecentOrdersSection extends StatelessWidget {
  const _MaterialRecentOrdersSection({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final orders = <_RecentOrder>[
      _RecentOrder(
        product: 'Nike Air Max 270',
        store: 'Amazon',
        date: 'Oct 24, 2023',
        price: r'$150.00',
        status: l10n.homeStatusInTransit,
        statusColor: const Color(0xFF0B65C2),
        statusBackground: const Color(0xFFDCEBFF),
      ),
      _RecentOrder(
        product: 'Silver Watch',
        store: 'eBay',
        date: 'Oct 22, 2023',
        price: r'$89.99',
        status: l10n.homeStatusDelivered,
        statusColor: const Color(0xFF2F9A55),
        statusBackground: const Color(0xFFDDF8E7),
      ),
      _RecentOrder(
        product: 'Beats Studio Pro',
        store: 'Zara',
        date: 'Oct 20, 2023',
        price: r'$349.00',
        status: l10n.homeStatusDelivered,
        statusColor: const Color(0xFF2F9A55),
        statusBackground: const Color(0xFFDDF8E7),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.homeRecentOrdersTitleMaterial,
          style: textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF111315),
            fontSize: 31 * scale,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        SizedBox(height: 20 * scale),
        ClipRRect(
          borderRadius: BorderRadius.circular(18 * scale),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFE),
              border: Border.all(
                color: const Color(0xFFDADDE7),
                width: 1.5 * scale,
              ),
              borderRadius: BorderRadius.circular(18 * scale),
            ),
            child: Column(
              children: <Widget>[
                for (var index = 0; index < orders.length; index++) ...[
                  _MaterialRecentOrderItem(scale: scale, order: orders[index]),
                  if (index < orders.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1 * scale,
                      color: const Color(0xFFDADDE7),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MaterialRecentOrderItem extends StatelessWidget {
  const _MaterialRecentOrderItem({required this.scale, required this.order});

  final double scale;
  final _RecentOrder order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: 171 * scale,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            28 * scale,
            28 * scale,
            28 * scale,
            24 * scale,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            order.product,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF111315),
                              fontSize: 29 * scale,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                        ),
                        SizedBox(width: 10 * scale),
                        _MaterialOrderStatusBadge(scale: scale, order: order),
                      ],
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      '${order.store} • ${order.date}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF2D3340),
                        fontSize: 23 * scale,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      order.price,
                      style: textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF111315),
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20 * scale),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF5F646C),
                size: 34 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialOrderStatusBadge extends StatelessWidget {
  const _MaterialOrderStatusBadge({required this.scale, required this.order});

  final double scale;
  final _RecentOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15 * scale,
        vertical: 5 * scale,
      ),
      decoration: BoxDecoration(
        color: order.statusBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        order.status,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: order.statusColor,
          fontSize: 19 * scale,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
    );
  }
}

class _CupertinoHomeContent extends StatelessWidget {
  const _CupertinoHomeContent();

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(CupertinoIcons.line_horizontal_3, size: 22),
              const SizedBox(width: 14),
              Text(
                'Feyam',
                style: theme.textTheme.textStyle.copyWith(
                  color: const Color(0xFF002B45),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 42),
          AdaptiveAppCard(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            borderRadius: BorderRadius.circular(26),
            elevation: 0,
            backgroundColor: const Color(0xFFF3F2F7),
            borderColor: Colors.transparent,
            blur: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.homeImportProductTitle,
                  style: theme.textTheme.textStyle.copyWith(
                    color: CupertinoColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
                AdaptiveAppTextField(
                  label: l10n.homePasteProductLink,
                  placeholder: l10n.homePasteProductExample,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  backgroundColor: const Color(0xFFE1E3E8),
                  borderColor: const Color(0xFF6D737A),
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 14),
                AdaptiveAppButton(
                  text: l10n.homeAddToCartButton,
                  icon: const Icon(CupertinoIcons.arrow_down_to_line_alt),
                  height: 54,
                  backgroundColor: const Color(0xFF003E50),
                  foregroundColor: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const _CupertinoPopularStoresSection(),
          const SizedBox(height: 28),
          const _CupertinoRecentOrdersSection(),
        ],
      ),
    );
  }
}

class _CupertinoSectionHeader extends StatelessWidget {
  const _CupertinoSectionHeader({
    required this.title,
    required this.actionLabel,
  });

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.textStyle.copyWith(
              color: CupertinoColors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              actionLabel,
              style: theme.textTheme.actionTextStyle.copyWith(
                color: const Color(0xFF002B45),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CupertinoPopularStoresSection extends StatelessWidget {
  const _CupertinoPopularStoresSection();

  static const _stores = <_CupertinoStore>[
    _CupertinoStore(
      name: 'Amazon',
      icon: CupertinoIcons.lightbulb_fill,
      background: Color(0xFF131313),
      accent: Color(0xFFFF8A00),
    ),
    _CupertinoStore(
      name: 'eBay',
      icon: CupertinoIcons.rectangle_on_rectangle,
      background: Color(0xFF1B211A),
      accent: Color(0xFFFFE2A8),
    ),
    _CupertinoStore(
      name: 'Zara',
      icon: CupertinoIcons.person_fill,
      background: Color(0xFF9C6A54),
      accent: Color(0xFFFFE5D5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _CupertinoSectionHeader(
          title: l10n.homePopularStoresTitle,
          actionLabel: l10n.homeSeeAll,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (final store in _stores) _CupertinoStoreItem(store: store),
          ],
        ),
      ],
    );
  }
}

class _CupertinoStoreItem extends StatelessWidget {
  const _CupertinoStoreItem({required this.store});

  final _CupertinoStore store;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return SizedBox(
      width: 88,
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E4EA)),
            ),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: store.background,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: store.accent.withValues(alpha: 0.45),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Icon(store.icon, color: store.accent, size: 26),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            store.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.textStyle.copyWith(
              color: CupertinoColors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoRecentOrdersSection extends StatelessWidget {
  const _CupertinoRecentOrdersSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orders = <_CupertinoRecentOrder>[
      _CupertinoRecentOrder(
        product: l10n.homeCupertinoOrder1Product,
        origin: l10n.homeCupertinoOrder1Origin,
        price: r'$129.99',
      ),
      _CupertinoRecentOrder(
        product: l10n.homeCupertinoOrder2Product,
        origin: l10n.homeCupertinoOrder2Origin,
        price: r'$85.50',
      ),
      _CupertinoRecentOrder(
        product: l10n.homeCupertinoOrder3Product,
        origin: l10n.homeCupertinoOrder3Origin,
        price: r'$299.00',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _CupertinoSectionHeader(
          title: l10n.homeRecentOrdersTitle,
          actionLabel: l10n.homeSeeAll,
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < orders.length; index++) ...<Widget>[
          _CupertinoRecentOrderCard(order: orders[index]),
          if (index < orders.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _CupertinoRecentOrderCard extends StatelessWidget {
  const _CupertinoRecentOrderCard({required this.order});

  final _CupertinoRecentOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return AdaptiveAppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      backgroundColor: const Color(0xFFF7F6FB),
      borderColor: const Color(0xFFD9DDE5),
      blur: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            order.product,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.textStyle.copyWith(
              color: CupertinoColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.origin,
            style: theme.textTheme.textStyle.copyWith(
              color: const Color(0xFF2E343B),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.price,
            style: theme.textTheme.textStyle.copyWith(
              color: const Color(0xFF002B45),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoStore {
  const _CupertinoStore({
    required this.name,
    required this.icon,
    required this.background,
    required this.accent,
  });

  final String name;
  final IconData icon;
  final Color background;
  final Color accent;
}

class _CupertinoRecentOrder {
  const _CupertinoRecentOrder({
    required this.product,
    required this.origin,
    required this.price,
  });

  final String product;
  final String origin;
  final String price;
}

class _RecentOrder {
  const _RecentOrder({
    required this.product,
    required this.store,
    required this.date,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
  });

  final String product;
  final String store;
  final String date;
  final String price;
  final String status;
  final Color statusColor;
  final Color statusBackground;
}
