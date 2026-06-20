import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/orders/domain/entities/order_display_status.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/presentation/bloc/recent_orders_bloc.dart';
import 'package:feyam/features/orders/presentation/bloc/recent_orders_event.dart';
import 'package:feyam/features/orders/presentation/bloc/recent_orders_state.dart';
import 'package:feyam/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Number of orders requested for the full history screen.
const int _ordersTake = 20;

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecentOrdersBloc>(
      create: (_) =>
          sl<RecentOrdersBloc>()..add(const RecentOrdersLoadRequested(take: _ordersTake)),
      child: AdaptivePlatform.isCupertino(context)
          ? const _CupertinoOrdersContent()
          : const _MaterialOrdersContent(),
    );
  }
}

// ── Shared mappers ─────────────────────────────────────────────────────────────

String _formatPrice(double amount) => '\$${amount.toStringAsFixed(2)}';

String _formatDate(DateTime d) {
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

_OrderStatus _toMaterialStatus(OrderDisplayStatus s) => switch (s) {
      OrderDisplayStatus.review => _OrderStatus.enRevision,
      OrderDisplayStatus.payment => _OrderStatus.porPagar,
      OrderDisplayStatus.shipping => _OrderStatus.enCamino,
      OrderDisplayStatus.delivered => _OrderStatus.entregado,
    };

FeyamOrderStatus _toFeyamStatus(OrderDisplayStatus s) => switch (s) {
      OrderDisplayStatus.review => FeyamOrderStatus.enRevision,
      OrderDisplayStatus.payment => FeyamOrderStatus.porPagar,
      OrderDisplayStatus.shipping => FeyamOrderStatus.enCamino,
      OrderDisplayStatus.delivered => FeyamOrderStatus.entregado,
    };

_Md3Order _toMaterialOrder(RecentOrderEntity o) => _Md3Order(
      id: o.orderId,
      title: o.title,
      price: _formatPrice(o.chargedAmount),
      date: _formatDate(o.createdDate),
      icon: Icons.inventory_2_rounded,
      status: _toMaterialStatus(o.displayStatus),
    );

_CupertinoOrder _toCupertinoOrder(RecentOrderEntity o) => _CupertinoOrder(
      id: o.orderId,
      title: o.title,
      price: _formatPrice(o.chargedAmount),
      date: _formatDate(o.createdDate),
      status: _toFeyamStatus(o.displayStatus),
      icon: CupertinoIcons.cube_box_fill,
    );

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

    return BlocBuilder<RecentOrdersBloc, RecentOrdersState>(
      builder: (context, state) {
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
                  Expanded(child: _buildBody(context, state, scale)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RecentOrdersState state, double scale) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    switch (state.status) {
      case RecentOrdersStatus.initial:
      case RecentOrdersStatus.loading:
        return Center(
          child: SizedBox(
            width: 28 * scale,
            height: 28 * scale,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.primary,
            ),
          ),
        );
      case RecentOrdersStatus.failure:
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.ordersLoadError,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 14 * scale,
                  ),
                ),
                SizedBox(height: 12 * scale),
                FilledButton.tonal(
                  onPressed: () => context
                      .read<RecentOrdersBloc>()
                      .add(const RecentOrdersLoadRequested(take: _ordersTake)),
                  child: Text(l10n.ordersRetry),
                ),
              ],
            ),
          ),
        );
      case RecentOrdersStatus.empty:
        return _Md3EmptyState(
          scale: scale,
          title: l10n.ordersEmptyTitle,
          subtitle: l10n.ordersEmptySubtitle,
        );
      case RecentOrdersStatus.loaded:
        final orders = state.orders.map(_toMaterialOrder).toList();
        final filtered = switch (_tabIndex) {
          1 => orders.where((o) => o.status != _OrderStatus.entregado).toList(),
          2 => orders.where((o) => o.status == _OrderStatus.entregado).toList(),
          _ => orders,
        };

        if (filtered.isEmpty) {
          return _Md3EmptyState(
            scale: scale,
            title: l10n.ordersEmptyTitle,
            subtitle: l10n.ordersEmptySubtitle,
          );
        }

        return ListView.separated(
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
        );
    }
  }
}

class _Md3EmptyState extends StatelessWidget {
  const _Md3EmptyState({
    required this.scale,
    required this.title,
    required this.subtitle,
  });

  final double scale;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.inventory_2_outlined,
              size: 56 * scale,
              color: colors.onSurfaceVariant,
            ),
            SizedBox(height: 16 * scale),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 16 * scale,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 13 * scale,
              ),
            ),
          ],
        ),
      ),
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
  });

  final String id;
  final String title;
  final String price;
  final String date;
  final IconData icon;
  final _OrderStatus status;
}

class _CupertinoOrdersContent extends StatefulWidget {
  const _CupertinoOrdersContent();

  @override
  State<_CupertinoOrdersContent> createState() => _CupertinoOrdersContentState();
}

class _CupertinoOrdersContentState extends State<_CupertinoOrdersContent> {
  int _filterIndex = 0; // 0=todos, 1=activos, 2=entregados

  List<_CupertinoOrder> _filtered(List<_CupertinoOrder> orders) {
    switch (_filterIndex) {
      case 1: return orders.where((o) => o.status != FeyamOrderStatus.entregado).toList();
      case 2: return orders.where((o) => o.status == FeyamOrderStatus.entregado).toList();
      default: return orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<RecentOrdersBloc, RecentOrdersState>(
      builder: (context, state) {
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
                  Expanded(child: _buildBody(context, state, scale)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RecentOrdersState state, double scale) {
    final l10n = AppLocalizations.of(context)!;

    switch (state.status) {
      case RecentOrdersStatus.initial:
      case RecentOrdersStatus.loading:
        return const Center(child: CupertinoActivityIndicator());
      case RecentOrdersStatus.failure:
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.ordersLoadError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: kFeyamLabelSec),
                ),
                SizedBox(height: 12 * scale),
                CupertinoButton(
                  onPressed: () => context
                      .read<RecentOrdersBloc>()
                      .add(const RecentOrdersLoadRequested(take: _ordersTake)),
                  child: Text(l10n.ordersRetry),
                ),
              ],
            ),
          ),
        );
      case RecentOrdersStatus.empty:
        return FeyamEmptyState(
          icon: CupertinoIcons.cube_box_fill,
          title: l10n.ordersEmptyTitle,
          subtitle: l10n.ordersEmptySubtitle,
        );
      case RecentOrdersStatus.loaded:
        final filtered = _filtered(state.orders.map(_toCupertinoOrder).toList());

        if (filtered.isEmpty) {
          return FeyamEmptyState(
            icon: CupertinoIcons.cube_box_fill,
            title: l10n.ordersEmptyTitle,
            subtitle: l10n.ordersEmptySubtitle,
          );
        }

        return SingleChildScrollView(
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
                            status: orderDisplayStatusKey(
                              _displayStatusFromFeyam(filtered[i].status),
                            ),
                            date: filtered[i].date,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
    }
  }
}

OrderDisplayStatus _displayStatusFromFeyam(FeyamOrderStatus s) => switch (s) {
      FeyamOrderStatus.enRevision => OrderDisplayStatus.review,
      FeyamOrderStatus.porPagar => OrderDisplayStatus.payment,
      FeyamOrderStatus.enCamino => OrderDisplayStatus.shipping,
      FeyamOrderStatus.entregado => OrderDisplayStatus.delivered,
    };

class _CupertinoOrder {
  const _CupertinoOrder({
    required this.id,
    required this.title,
    required this.price,
    required this.date,
    required this.status,
    required this.icon,
  });

  final String id;
  final String title;
  final String price;
  final String date;
  final FeyamOrderStatus status;
  final IconData icon;
}
