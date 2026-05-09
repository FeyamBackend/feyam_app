import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoHomeContent();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AdaptiveAppCard(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            elevation: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.homeImportOrderTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                AdaptiveAppTextField(
                  placeholder: l10n.homePasteProductLink,
                  prefixIcon: const Icon(Icons.link),
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  backgroundColor: const Color(0xFFE5E7EB),
                  borderColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                const SizedBox(height: 12),
                AdaptiveAppButton(
                  text: l10n.homeImportButton,
                  height: 52,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _PopularStoresSection(),
          const SizedBox(height: 24),
          const _RecentOrdersSection(),
        ],
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

class _PopularStoresSection extends StatelessWidget {
  const _PopularStoresSection();

  static const _stores = <_PopularStore>[
    _PopularStore(name: 'Amazon', iconLabel: 'amazon', background: Colors.black),
    _PopularStore(name: 'eBay', iconLabel: 'eBay', background: Colors.black),
    _PopularStore(name: 'Zara', iconLabel: 'ZARA', background: Color(0xFF3E3E3E)),
    _PopularStore(name: 'Apple', iconLabel: 'Apple', background: Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.homePopularStoresTitleMaterial,
                style: textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  l10n.homeSeeAll,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            for (final store in _stores)
              Expanded(child: _PopularStoreItem(store: store)),
          ],
        ),
      ],
    );
  }
}

class _PopularStoreItem extends StatelessWidget {
  const _PopularStoreItem({required this.store});

  final _PopularStore store;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      child: Column(
        children: <Widget>[
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFFE3E5EA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD9DCE3)),
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: store.background,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  store.iconLabel,
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: store.background == Colors.white
                        ? colors.onSurface
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            store.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularStore {
  const _PopularStore({
    required this.name,
    required this.iconLabel,
    required this.background,
  });

  final String name;
  final String iconLabel;
  final Color background;
}

class _RecentOrdersSection extends StatelessWidget {
  const _RecentOrdersSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
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
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        AdaptiveAppCard(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(14),
          elevation: 8,
          child: Column(
            children: <Widget>[
              for (var index = 0; index < orders.length; index++) ...<Widget>[
                _RecentOrderItem(order: orders[index]),
                if (index < orders.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.6),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentOrderItem extends StatelessWidget {
  const _RecentOrderItem({required this.order});

  final _RecentOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          style: textTheme.titleSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _OrderStatusBadge(order: order),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.store} • ${order.date}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.price,
                    style: textTheme.titleSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right, color: colors.onSurfaceVariant, size: 22),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.order});

  final _RecentOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: order.statusBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        order.status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: order.statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
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
