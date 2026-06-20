import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoOrdersContent();
    }

    return const _MaterialOrdersContent();
  }
}

class _MaterialOrdersContent extends StatefulWidget {
  const _MaterialOrdersContent();

  @override
  State<_MaterialOrdersContent> createState() => _MaterialOrdersContentState();
}

class _MaterialOrdersContentState extends State<_MaterialOrdersContent> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final allOrders = <_Md3Order>[
      _Md3Order(
        id: '24501',
        title: 'Sony WH-1000XM5',
        price: r'$278.00',
        date: '15 may 2026',
        delivery: '8–12 jun 2026',
        icon: Icons.headphones_rounded,
        status: _OrderStatus.enCamino,
      ),
      _Md3Order(
        id: '24489',
        title: 'Apple Watch SE 2nd Gen',
        price: r'$249.00',
        date: '12 may 2026',
        delivery: '10–15 jun 2026',
        icon: Icons.watch_rounded,
        status: _OrderStatus.porPagar,
      ),
      _Md3Order(
        id: '24412',
        title: 'Kindle Paperwhite 16GB',
        price: r'$139.99',
        date: '8 may 2026',
        icon: Icons.menu_book_rounded,
        status: _OrderStatus.enRevision,
      ),
      _Md3Order(
        id: '24350',
        title: 'Nike Air Max 90',
        price: r'$130.00',
        date: '22 abr 2026',
        icon: Icons.directions_run_rounded,
        status: _OrderStatus.entregado,
      ),
      _Md3Order(
        id: '24298',
        title: 'JBL Charge 5',
        price: r'$179.95',
        date: '10 abr 2026',
        icon: Icons.speaker_rounded,
        status: _OrderStatus.entregado,
      ),
    ];

    final filtered = switch (_tabIndex) {
      1 => allOrders
          .where((o) => o.status != _OrderStatus.entregado)
          .toList(),
      2 => allOrders
          .where((o) => o.status == _OrderStatus.entregado)
          .toList(),
      _ => allOrders,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return ColoredBox(
          color: colors.surface,
          child: Column(
            children: <Widget>[
              _Md3OrdersHeader(scale: scale),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  16 * scale,
                  20 * scale,
                  0,
                ),
                child: _Md3TabBar(
                  scale: scale,
                  selectedIndex: _tabIndex,
                  labels: [
                    l10n.ordersTabAll,
                    l10n.ordersTabActive,
                    l10n.ordersTabDelivered,
                  ],
                  onChanged: (i) => setState(() => _tabIndex = i),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    16 * scale,
                    20 * scale,
                    32 * scale,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12 * scale),
                  itemBuilder: (context, index) =>
                      _Md3OrderCard(scale: scale, order: filtered[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Md3OrdersHeader extends StatelessWidget {
  const _Md3OrdersHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.ordersHistoryTitle,
                style: textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Md3TabBar extends StatelessWidget {
  const _Md3TabBar({
    required this.scale,
    required this.selectedIndex,
    required this.labels,
    required this.onChanged,
  });

  final double scale;
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.all(3 * scale),
        child: Row(
          children: <Widget>[
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selectedIndex == i
                          ? colors.secondaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    alignment: Alignment.center,
                    child: Text(
                      labels[i],
                      style: textTheme.labelLarge?.copyWith(
                        color: selectedIndex == i
                            ? colors.onSecondaryContainer
                            : colors.onSurfaceVariant,
                        fontWeight: selectedIndex == i
                            ? FontWeight.w700
                            : FontWeight.w400,
                        fontSize: 13 * scale,
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

class _Md3OrderCard extends StatelessWidget {
  const _Md3OrderCard({required this.scale, required this.order});

  final double scale;
  final _Md3Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (statusLabel, statusFg, statusBg) = switch (order.status) {
      _OrderStatus.enRevision => (
          l10n.ordersStatusEnRevision,
          colors.onSurfaceVariant,
          colors.surfaceContainerHighest,
        ),
      _OrderStatus.porPagar => (
          l10n.ordersStatusPorPagar,
          colors.onTertiaryContainer,
          colors.tertiaryContainer,
        ),
      _OrderStatus.enCamino => (
          l10n.ordersStatusEnCamino,
          colors.onPrimaryContainer,
          colors.primaryContainer,
        ),
      _OrderStatus.entregado => (
          l10n.ordersStatusEntregado,
          colors.onSecondaryContainer,
          colors.secondaryContainer,
        ),
    };

    final statusKey = switch (order.status) {
      _OrderStatus.enRevision => 'review',
      _OrderStatus.porPagar => 'payment',
      _OrderStatus.enCamino => 'shipping',
      _OrderStatus.entregado => 'delivered',
    };

    return Card(
      elevation: 1,
      surfaceTintColor: colors.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16 * scale),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => OrderDetailScreen(
              orderId: order.id,
              title: order.title,
              price: order.price,
              status: statusKey,
              date: order.date,
              delivery: order.delivery,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14 * scale),
          child: Row(
            children: <Widget>[
              Container(
                width: 48 * scale,
                height: 48 * scale,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Icon(order.icon, size: 24 * scale, color: colors.onSurfaceVariant),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      order.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 15 * scale,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      '${l10n.ordersOrderLabel} #FY-${order.id} · ${order.price}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 12 * scale,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8 * scale,
                          vertical: 3 * scale,
                        ),
                        child: Text(
                          statusLabel,
                          style: textTheme.labelSmall?.copyWith(
                            color: statusFg,
                            fontWeight: FontWeight.w500,
                            fontSize: 12 * scale,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 22 * scale, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

enum _OrderStatus { enRevision, porPagar, enCamino, entregado }

class _Md3Order {
  const _Md3Order({
    required this.id,
    required this.title,
    required this.price,
    required this.date,
    required this.icon,
    required this.status,
    this.delivery,
  });

  final String id;
  final String title;
  final String price;
  final String date;
  final String? delivery;
  final IconData icon;
  final _OrderStatus status;
}

class _CupertinoOrdersContent extends StatefulWidget {
  const _CupertinoOrdersContent();

  @override
  State<_CupertinoOrdersContent> createState() => _CupertinoOrdersContentState();
}

class _CupertinoOrdersContentState extends State<_CupertinoOrdersContent> {
  static const _allOrders = <_CupertinoOrder>[
    _CupertinoOrder(id: '41',  title: 'Auriculares Sony WH-1000XM5', price: r'$ 1.450.000', status: FeyamOrderStatus.enCamino,   icon: CupertinoIcons.headphones),
    _CupertinoOrder(id: '98',  title: 'Apple Watch Series 9',        price: r'$ 1.890.000', status: FeyamOrderStatus.porPagar,   icon: CupertinoIcons.time),
    _CupertinoOrder(id: '55',  title: 'Kindle Paperwhite',           price: r'$ 640.000',   status: FeyamOrderStatus.enRevision, icon: CupertinoIcons.book_fill),
    _CupertinoOrder(id: '20',  title: 'Cámara Instax Mini 12',       price: r'$ 380.000',   status: FeyamOrderStatus.entregado,  icon: CupertinoIcons.camera_fill),
  ];

  int _filterIndex = 0; // 0=todos, 1=activos, 2=entregados

  List<_CupertinoOrder> get _filtered {
    switch (_filterIndex) {
      case 1: return _allOrders.where((o) => o.status != FeyamOrderStatus.entregado).toList();
      case 2: return _allOrders.where((o) => o.status == FeyamOrderStatus.entregado).toList();
      default: return _allOrders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filtered;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return ColoredBox(
          color: kFeyamBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Large title bar
              Container(
                color: kFeyamBg,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 0),
                      child: Text(
                        l10n.navOrders,
                        style: TextStyle(
                          fontSize: 34 * scale,
                          fontWeight: FontWeight.w700,
                          color: kFeyamLabel,
                          letterSpacing: 0.37,
                          fontFamily: '.SF Pro Display',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 12 * scale),
                      child: FeyamSegmented<int>(
                        options: [
                          (value: 0, label: l10n.ordersTabAll),
                          (value: 1, label: l10n.ordersTabActive),
                          (value: 2, label: l10n.ordersTabDelivered),
                        ],
                        value: _filterIndex,
                        onChanged: (v) => setState(() => _filterIndex = v),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? FeyamEmptyState(
                        icon: CupertinoIcons.cube_box_fill,
                        title: l10n.ordersEmptyTitle,
                        subtitle: l10n.ordersEmptySubtitle,
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 16 * scale),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 16 * scale),
                            FeyamListSection(
                              children: <Widget>[
                                for (var i = 0; i < filtered.length; i++)
                                  FeyamListTile(
                                    title: Text(
                                      filtered[i].title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            '${l10n.ordersOrderLabel} #${filtered[i].id} · ${filtered[i].price}',
                                            style: const TextStyle(fontSize: 13, color: kFeyamLabelSec),
                                          ),
                                        ),
                                        FeyamStatusBadge(status: filtered[i].status),
                                      ],
                                    ),
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(color: kFeyamBg, borderRadius: BorderRadius.circular(10)),
                                      child: Icon(filtered[i].icon, size: 22, color: kFeyamLabelSec),
                                    ),
                                    isLast: i == filtered.length - 1,
                                    onTap: () => Navigator.of(context).push(
                                      CupertinoPageRoute<void>(
                                        builder: (_) => OrderDetailScreen(
                                          orderId: filtered[i].id,
                                          title: filtered[i].title,
                                          price: filtered[i].price,
                                          status: _statusKey(filtered[i].status),
                                          date: '15 may 2026',
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

  static String _statusKey(FeyamOrderStatus s) {
    switch (s) {
      case FeyamOrderStatus.porPagar:   return 'payment';
      case FeyamOrderStatus.enCamino:   return 'shipping';
      case FeyamOrderStatus.entregado:  return 'delivered';
      default:                          return 'review';
    }
  }
}

class _CupertinoOrder {
  const _CupertinoOrder({
    required this.id,
    required this.title,
    required this.price,
    required this.status,
    required this.icon,
  });

  final String id;
  final String title;
  final String price;
  final FeyamOrderStatus status;
  final IconData icon;
}
