import 'package:feyam/core/di/injection_container.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/core/widgets/feyam_hero_header.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:feyam/features/product_search/presentation/screens/product_search_screen.dart';
import 'package:feyam/features/notifications/presentation/bloc/unread_count_bloc.dart';
import 'package:feyam/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:feyam/features/orders/domain/entities/order_display_status.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/presentation/bloc/recent_orders_bloc.dart';
import 'package:feyam/features/orders/presentation/bloc/recent_orders_event.dart';
import 'package:feyam/features/orders/presentation/bloc/recent_orders_state.dart';
import 'package:feyam/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:feyam/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:feyam/features/stores/presentation/screens/stores_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecentOrdersBloc>(
      create: (_) =>
          sl<RecentOrdersBloc>()..add(const RecentOrdersLoadRequested()),
      child: AdaptivePlatform.isCupertino(context)
          ? const _CupertinoHomeContent()
          : const _MaterialHomeContent(),
    );
  }
}

Future<void> _openStore(String host) async {
  final uri = Uri.parse('https://$host');
  try {
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  } on PlatformException {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── Shared mappers ─────────────────────────────────────────────────────────────

String _formatPrice(double amount) => '\$${amount.toStringAsFixed(2)}';

String _formatDate(DateTime d) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

_OrderStatus _toMaterialStatus(OrderDisplayStatus s) => switch (s) {
  OrderDisplayStatus.review => _OrderStatus.review,
  OrderDisplayStatus.payment => _OrderStatus.payment,
  OrderDisplayStatus.shipping => _OrderStatus.shipping,
  OrderDisplayStatus.delivered => _OrderStatus.delivered,
};

FeyamOrderStatus _toFeyamStatus(OrderDisplayStatus s) => switch (s) {
  OrderDisplayStatus.review => FeyamOrderStatus.enRevision,
  OrderDisplayStatus.payment => FeyamOrderStatus.porPagar,
  OrderDisplayStatus.shipping => FeyamOrderStatus.enCamino,
  OrderDisplayStatus.delivered => FeyamOrderStatus.entregado,
};

_OrderPreview _toPreview(RecentOrderEntity o) => _OrderPreview(
  id: o.orderId,
  title: o.title,
  status: _toMaterialStatus(o.displayStatus),
  price: _formatPrice(o.chargedAmount),
  date: _formatDate(o.createdDate),
);

// ── Material ──────────────────────────────────────────────────────────────────

class _MaterialHomeContent extends StatelessWidget {
  const _MaterialHomeContent();

  static const _stores = <_StoreData>[
    _StoreData(
      name: 'Amazon',
      host: 'amazon.com',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFFF9900),
    ),
    _StoreData(
      name: 'eBay',
      host: 'ebay.com',
      icon: Icons.gavel_rounded,
      color: Color(0xFFE53238),
    ),
    _StoreData(
      name: 'Walmart',
      host: 'walmart.com',
      icon: Icons.storefront_rounded,
      color: Color(0xFF0071DC),
    ),
    _StoreData(
      name: 'Best Buy',
      host: 'bestbuy.com',
      icon: Icons.devices_rounded,
      color: Color(0xFF0A4ABF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);
        final colors = Theme.of(context).colorScheme;

        return ColoredBox(
          color: colors.surface,
          child: Column(
            children: <Widget>[
              FeyamHeroHeader(
                scale: scale,
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  icon: Badge.count(
                    count: context.watch<UnreadCountBloc>().state.count,
                    isLabelVisible:
                        context.watch<UnreadCountBloc>().state.count > 0,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 22 * scale,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16 * scale,
                    16 * scale,
                    16 * scale,
                    28 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _MaterialGreeting(scale: scale),
                      SizedBox(height: 16 * scale),
                      _MaterialSearchBar(scale: scale),
                      SizedBox(height: 18 * scale),
                      _MaterialRecentOrders(scale: scale),
                      SizedBox(height: 18 * scale),
                      _MaterialStoresSection(scale: scale, stores: _stores),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Shared card recipe (matches checkout_screen.dart's _InfoCard/_InfoCardHeader) ──

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _InfoCardHeader extends StatelessWidget {
  const _InfoCardHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        ?action,
      ],
    );
  }
}

class _SectionViewAllLink extends StatelessWidget {
  const _SectionViewAllLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.primary, size: 16),
        ],
      ),
    );
  }
}

class _MaterialGreeting extends StatelessWidget {
  const _MaterialGreeting({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayName =
        context.watch<AuthBloc>().state.user?.displayName ?? l10n.profileName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.homeGreetingPrefix,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 13.5 * scale,
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          displayName.split(' ').first,
          style: textTheme.headlineSmall?.copyWith(
            color: colors.primary,
            fontSize: 24 * scale,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MaterialSearchBar extends StatelessWidget {
  const _MaterialSearchBar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const ProductSearchScreen()),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 14 * scale,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.search_rounded,
                color: colors.onSurfaceVariant,
                size: 22 * scale,
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  l10n.homeSearchHint,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 15 * scale,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors.onSurfaceVariant,
                size: 14 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialRecentOrders extends StatelessWidget {
  const _MaterialRecentOrders({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<RecentOrdersBloc, RecentOrdersState>(
      builder: (context, state) {
        return _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _InfoCardHeader(
                icon: Icons.inventory_2_outlined,
                iconColor: colors.primary,
                iconBg: colors.primaryContainer,
                title: l10n.homeRecentOrdersTitle,
                action: _SectionViewAllLink(
                  label: l10n.homeViewAll,
                  onTap: () {},
                ),
              ),
              SizedBox(height: 14 * scale),
              _buildBody(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RecentOrdersState state) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    switch (state.status) {
      case RecentOrdersStatus.initial:
      case RecentOrdersStatus.loading:
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12 * scale),
            child: SizedBox(
              width: 24 * scale,
              height: 24 * scale,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primary,
              ),
            ),
          ),
        );
      case RecentOrdersStatus.failure:
        return Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.ordersLoadError,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 13 * scale,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.read<RecentOrdersBloc>().add(
                const RecentOrdersLoadRequested(),
              ),
              child: Text(
                l10n.ordersRetry,
                style: textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13 * scale,
                ),
              ),
            ),
          ],
        );
      case RecentOrdersStatus.empty:
        return Text(
          l10n.homeNoOrdersYet,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 13 * scale,
          ),
        );
      case RecentOrdersStatus.loaded:
        final previews = state.orders.map(_toPreview).toList();
        return _LoadedRecentOrders(
          scale: scale,
          orders: previews,
          total: state.activeTotal,
          colors: colors,
          textTheme: textTheme,
        );
    }
  }
}

class _LoadedRecentOrders extends StatelessWidget {
  const _LoadedRecentOrders({
    required this.scale,
    required this.orders,
    required this.total,
    required this.colors,
    required this.textTheme,
  });

  final double scale;
  final List<_OrderPreview> orders;
  final double total;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.homeEstimatedPrice,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 12 * scale,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    _formatPrice(total),
                    style: textTheme.headlineMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 26 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scale),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Column(
            children: <Widget>[
              for (var i = 0; i < orders.length; i++) ...[
                _OrderPreviewRow(
                  scale: scale,
                  order: orders[i],
                  colors: colors,
                  textTheme: textTheme,
                ),
                if (i < orders.length - 1)
                  Divider(height: 1, color: colors.outlineVariant),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderPreviewRow extends StatelessWidget {
  const _OrderPreviewRow({
    required this.scale,
    required this.order,
    required this.colors,
    required this.textTheme,
  });

  final double scale;
  final _OrderPreview order;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (statusLabel, statusBg, statusFg) = switch (order.status) {
      _OrderStatus.review => (
        l10n.ordersStatusEnRevision,
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
      _OrderStatus.payment => (
        l10n.ordersStatusPorPagar,
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      _OrderStatus.shipping => (
        l10n.ordersStatusEnCamino,
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      _OrderStatus.delivered => (
        l10n.ordersStatusEntregado,
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
    };

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => OrderDetailScreen(
              orderId: order.id,
              title: order.title,
              price: order.price,
              status: order.status.name,
              date: order.date,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10 * scale),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 10 * scale,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    order.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13 * scale,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(4 * scale),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * scale,
                        vertical: 2 * scale,
                      ),
                      child: Text(
                        statusLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: statusFg,
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8 * scale),
            Text(
              order.price,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 13 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialStoresSection extends StatelessWidget {
  const _MaterialStoresSection({required this.scale, required this.stores});

  final double scale;
  final List<_StoreData> stores;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _InfoCardHeader(
            icon: Icons.storefront_outlined,
            iconColor: colors.secondary,
            iconBg: colors.secondaryContainer,
            title: l10n.homeSupportedStores,
            action: _SectionViewAllLink(
              label: l10n.homeViewAllStores,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<StoresBloc>(),
                      child: const StoresScreen(),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 14 * scale),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10 * scale,
            crossAxisSpacing: 10 * scale,
            childAspectRatio: 2.8,
            children: stores
                .map((s) => _StoreTile(scale: scale, store: s))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({required this.scale, required this.store});

  final double scale;
  final _StoreData store;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => _openStore(store.host),
      borderRadius: BorderRadius.circular(12 * scale),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * scale),
          color: colors.surfaceContainerLow,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 10 * scale,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36 * scale,
                height: 36 * scale,
                decoration: BoxDecoration(
                  color: store.color,
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Icon(store.icon, color: Colors.white, size: 20 * scale),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: colors.onSurface,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _OrderStatus { review, payment, shipping, delivered }

class _OrderPreview {
  const _OrderPreview({
    required this.id,
    required this.title,
    required this.status,
    required this.price,
    required this.date,
  });

  final String id;
  final String title;
  final _OrderStatus status;
  final String price;
  final String date;
}

class _StoreData {
  const _StoreData({
    required this.name,
    required this.host,
    required this.icon,
    required this.color,
  });

  final String name;
  final String host;
  final IconData icon;
  final Color color;
}

// ── Cupertino ─────────────────────────────────────────────────────────────────

class _CupertinoHomeContent extends StatelessWidget {
  const _CupertinoHomeContent();

  static const _stores = <_CupertinoHomeStore>[
    _CupertinoHomeStore(
      name: 'Amazon',
      host: 'amazon.com',
      icon: CupertinoIcons.bag_fill,
      color: Color(0xFFFF9900),
    ),
    _CupertinoHomeStore(
      name: 'eBay',
      host: 'ebay.com',
      icon: CupertinoIcons.hammer_fill,
      color: Color(0xFFE53238),
    ),
    _CupertinoHomeStore(
      name: 'Walmart',
      host: 'walmart.com',
      icon: CupertinoIcons.building_2_fill,
      color: Color(0xFF0071DC),
    ),
    _CupertinoHomeStore(
      name: 'Best Buy',
      host: 'bestbuy.com',
      icon: CupertinoIcons.desktopcomputer,
      color: Color(0xFF0A4ABF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);
        return ColoredBox(
          color: kFeyamBg,
          child: Column(
            children: <Widget>[
              _CupertinoHomeLargeNavBar(scale: scale),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      BlocBuilder<RecentOrdersBloc, RecentOrdersState>(
                        builder: (context, state) =>
                            _CupertinoRecentOrders(scale: scale, state: state),
                      ),
                      // Tiendas soportadas
                      FeyamListSection(
                        header: 'Tiendas soportadas',
                        children: <Widget>[
                          for (var i = 0; i < _stores.length; i++)
                            FeyamListTile(
                              title: Text(_stores[i].name),
                              detail: Text(_stores[i].host),
                              leading: FeyamIconTile(
                                icon: _stores[i].icon,
                                color: _stores[i].color,
                              ),
                              trailing: const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  CupertinoIcons.arrow_up_right_square,
                                  size: 18,
                                  color: kFeyamTint,
                                ),
                              ),
                              chevron: false,
                              isLast: false,
                              onTap: () => _openStore(_stores[i].host),
                            ),
                          FeyamListTile(
                            title: const Text('Ver todas las tiendas'),
                            isLast: true,
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute<void>(
                                builder: (_) => BlocProvider(
                                  create: (_) => sl<StoresBloc>(),
                                  child: const StoresScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CupertinoRecentOrders extends StatelessWidget {
  const _CupertinoRecentOrders({required this.scale, required this.state});

  final double scale;
  final RecentOrdersState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (state.status) {
      case RecentOrdersStatus.initial:
      case RecentOrdersStatus.loading:
        return Padding(
          padding: EdgeInsets.all(24 * scale),
          child: const Center(child: CupertinoActivityIndicator()),
        );
      case RecentOrdersStatus.failure:
        return Padding(
          padding: EdgeInsets.all(24 * scale),
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  l10n.ordersLoadError,
                  style: const TextStyle(color: kFeyamLabelSec, fontSize: 15),
                ),
                CupertinoButton(
                  onPressed: () => context.read<RecentOrdersBloc>().add(
                    const RecentOrdersLoadRequested(),
                  ),
                  child: Text(l10n.ordersRetry),
                ),
              ],
            ),
          ),
        );
      case RecentOrdersStatus.empty:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: FeyamEmptyState(
            icon: CupertinoIcons.cube_box_fill,
            title: l10n.ordersEmptyTitle,
            subtitle: l10n.ordersEmptySubtitle,
          ),
        );
      case RecentOrdersStatus.loaded:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                16 * scale,
                16 * scale,
                0,
              ),
              child: _CupertinoSummaryCard(
                scale: scale,
                total: state.activeTotal,
                activeCount: state.activeCount,
              ),
            ),
            SizedBox(height: 20 * scale),
            FeyamListSection(
              header: l10n.homeRecentOrdersTitle,
              children: <Widget>[
                for (var i = 0; i < state.orders.length; i++)
                  _cupertinoOrderTile(
                    context,
                    state.orders[i],
                    isLast: i == state.orders.length - 1,
                  ),
              ],
            ),
          ],
        );
    }
  }

  Widget _cupertinoOrderTile(
    BuildContext context,
    RecentOrderEntity order, {
    required bool isLast,
  }) {
    final status = _toFeyamStatus(order.displayStatus);
    return FeyamListTile(
      title: Text(order.title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: FeyamStatusBadge(status: status),
      ),
      detail: Text(_formatPrice(order.chargedAmount)),
      isLast: isLast,
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => OrderDetailScreen(
            orderId: order.orderId,
            title: order.title,
            price: _formatPrice(order.chargedAmount),
            status: order.displayStatus.name,
            date: _formatDate(order.createdDate),
          ),
        ),
      ),
    );
  }
}

class _CupertinoHomeLargeNavBar extends StatelessWidget {
  const _CupertinoHomeLargeNavBar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName =
        context.watch<AuthBloc>().state.user?.displayName ?? l10n.profileName;
    return Container(
      color: kFeyamCard,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 44 * scale,
              child: Padding(
                padding: EdgeInsets.only(right: 8 * scale),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      FeyamNotificationsButton(
                        count: context.watch<UnreadCountBloc>().state.count,
                        onTap: () => Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ColoredBox(
              color: kFeyamBg,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  2 * scale,
                  16 * scale,
                  0,
                ),
                child: Text(
                  '${l10n.homeGreetingPrefix} ${displayName.split(' ').first}',
                  style: GoogleFonts.poppins(
                    fontSize: 30 * scale,
                    fontWeight: FontWeight.w700,
                    color: kFeyamLabel,
                    height: 1.21,
                  ),
                ),
              ),
            ),
            ColoredBox(
              color: kFeyamBg,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  8 * scale,
                  16 * scale,
                  8 * scale,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) => const ProductSearchScreen(),
                    ),
                  ),
                  child: Container(
                    height: 36 * scale,
                    decoration: BoxDecoration(
                      color: kFeyamFillTer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          CupertinoIcons.search,
                          size: 16 * scale,
                          color: kFeyamLabelTer,
                        ),
                        SizedBox(width: 7 * scale),
                        Text(
                          l10n.homeSearchHint,
                          style: GoogleFonts.poppins(
                            fontSize: 15 * scale,
                            color: kFeyamLabelTer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoSummaryCard extends StatelessWidget {
  const _CupertinoSummaryCard({
    required this.scale,
    required this.total,
    required this.activeCount,
  });

  final double scale;
  final double total;
  final int activeCount;

  @override
  Widget build(BuildContext context) {
    if (activeCount == 0) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: kFeyamTint,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        18 * scale,
        20 * scale,
        16 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Precio estimado a pagar',
            style: GoogleFonts.poppins(
              fontSize: 13 * scale,
              color: const Color(0xC7FFFFFF),
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            _formatPrice(total),
            style: GoogleFonts.poppins(
              fontSize: 28 * scale,
              fontWeight: FontWeight.w800,
              color: CupertinoColors.white,
              height: 1,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            '$activeCount pedido${activeCount == 1 ? ' activo' : 's activos'}',
            style: GoogleFonts.poppins(
              fontSize: 13 * scale,
              color: const Color(0xC7FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _CupertinoHomeStore {
  const _CupertinoHomeStore({
    required this.name,
    required this.host,
    required this.icon,
    required this.color,
  });

  final String name;
  final String host;
  final IconData icon;
  final Color color;
}
