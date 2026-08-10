import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/notifications/presentation/bloc/unread_count_bloc.dart';
import 'package:feyam/features/notifications/presentation/screens/notifications_screen.dart';
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
import 'package:google_fonts/google_fonts.dart';

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

// ── Shared view model & mappers ─────────────────────────────────────────────────

class _OrderVm {
  const _OrderVm({
    required this.id,
    required this.title,
    required this.price,
    required this.date,
    required this.status,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String price;
  final String date;
  final OrderDisplayStatus status;
  final String? imageUrl;
}

String _formatPrice(double amount) => '\$${amount.toStringAsFixed(2)}';

String _formatDate(DateTime d) {
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

_OrderVm _toOrderVm(RecentOrderEntity o) => _OrderVm(
      id: o.orderId,
      title: o.title,
      price: _formatPrice(o.chargedAmount),
      date: _formatDate(o.createdDate),
      status: o.displayStatus,
      imageUrl: o.imageUrl,
    );

String _statusLabel(AppLocalizations l10n, OrderDisplayStatus s) => switch (s) {
      OrderDisplayStatus.review => l10n.ordersStatusEnRevision,
      OrderDisplayStatus.payment => l10n.ordersStatusPorPagar,
      OrderDisplayStatus.shipping => l10n.ordersStatusEnCamino,
      OrderDisplayStatus.delivered => l10n.ordersStatusEntregado,
    };

/// Status pill colors — match the STATUS table in the Feyam MD3 Design System,
/// shared verbatim with [FeyamStatusBadge] so both platforms render identically.
({Color bg, Color fg}) _statusStyle(OrderDisplayStatus s) => switch (s) {
      OrderDisplayStatus.review => (bg: const Color(0xFFFDF1E0), fg: const Color(0xFFA8710F)),
      OrderDisplayStatus.payment => (bg: const Color(0xFFDEE8C3), fg: const Color(0xFF5C6600)),
      OrderDisplayStatus.shipping => (bg: const Color(0xFFDBE8FB), fg: kFeyamTeal),
      OrderDisplayStatus.delivered => (bg: const Color(0xFFD2EAD1), fg: const Color(0xFF1F6B26)),
    };

/// tabIndex: 0=todos, 1=en revisión, 2=en tránsito, 3=entregados.
List<_OrderVm> _filterOrders(List<_OrderVm> orders, int tabIndex) => switch (tabIndex) {
      1 => orders.where((o) => o.status == OrderDisplayStatus.review).toList(),
      2 => orders.where((o) => o.status == OrderDisplayStatus.shipping).toList(),
      3 => orders.where((o) => o.status == OrderDisplayStatus.delivered).toList(),
      _ => orders,
    };

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.scale, required this.label, required this.bg, required this.fg});

  final double scale;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 9 * scale, vertical: 4 * scale),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11 * scale),
        ),
      ),
    );
  }
}

// ── Material ─────────────────────────────────────────────────────────────────

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Md3OrdersHeroHeader(scale: scale),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16 * scale, 18 * scale, 16 * scale, 2 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.ordersHistoryTitle,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 24 * scale,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          l10n.ordersHistorySubtitle,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 13.5 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 0, 0),
                    child: _Md3FilterPills(
                      scale: scale,
                      selectedIndex: _tabIndex,
                      labels: [
                        l10n.ordersTabAll,
                        l10n.ordersTabReview,
                        l10n.ordersTabShipping,
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
        final orders = state.orders.map(_toOrderVm).toList();
        final filtered = _filterOrders(orders, _tabIndex);

        if (filtered.isEmpty) {
          return _Md3EmptyState(
            scale: scale,
            title: l10n.ordersEmptyTitle,
            subtitle: l10n.ordersEmptySubtitle,
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            16 * scale,
            16 * scale,
            16 * scale,
            32 * scale,
          ),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => SizedBox(height: 5 * scale),
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

class _Md3OrdersHeroHeader extends StatelessWidget {
  const _Md3OrdersHeroHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final unreadCount = context.watch<UnreadCountBloc>().state.count;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.primary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 8 * scale, 8 * scale),
          child: Row(
            children: <Widget>[
              Image.asset('assets/branding/logo_white.png', height: 22 * scale),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
                ),
                icon: Badge.count(
                  count: unreadCount,
                  isLabelVisible: unreadCount > 0,
                  child: Icon(
                    Icons.notifications_outlined,
                    color: colors.onPrimary,
                    size: 22 * scale,
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

class _Md3FilterPills extends StatelessWidget {
  const _Md3FilterPills({
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
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36 * scale,
      child: Semantics(
        label: l10n.ordersFilterSemanticLabel,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: labels.length,
          separatorBuilder: (_, _) => SizedBox(width: 8 * scale),
          itemBuilder: (context, i) {
            final selected = i == selectedIndex;
            return GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                decoration: BoxDecoration(
                  color: selected ? colors.primary : colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected ? colors.primary : colors.outlineVariant,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13 * scale,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Md3OrderThumbnail extends StatelessWidget {
  const _Md3OrderThumbnail({required this.scale, required this.imageUrl});

  final double scale;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = 56 * scale;
    final placeholder = Icon(Icons.inventory_2_rounded, size: 26 * scale, color: colors.onSurfaceVariant);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12 * scale),
      child: Container(
        width: size,
        height: size,
        color: colors.surfaceContainerHighest,
        child: imageUrl == null
            ? placeholder
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
              ),
      ),
    );
  }
}

class _Md3OrderCard extends StatelessWidget {
  const _Md3OrderCard({required this.scale, required this.order});

  final double scale;
  final _OrderVm order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final style = _statusStyle(order.status);

    return Card(
      elevation: 1,
      color: colors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
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
              status: orderDisplayStatusKey(order.status),
              date: order.date,
              imageUrl: order.imageUrl,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14 * scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _Md3OrderThumbnail(scale: scale, imageUrl: order.imageUrl),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerRight,
                      child: _StatusPill(
                        scale: scale,
                        label: _statusLabel(l10n, order.status),
                        bg: style.bg,
                        fg: style.fg,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      order.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                        fontSize: 12.5 * scale,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Row(
                      children: <Widget>[
                        Icon(Icons.calendar_today_rounded, size: 12 * scale, color: colors.primary),
                        SizedBox(width: 4 * scale),
                        Expanded(
                          child: Text(
                            order.date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.primary,
                              fontSize: 11.5 * scale,
                            ),
                          ),
                        ),
                        SizedBox(width: 6 * scale),
                        Text(
                          order.price,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5 * scale,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4 * scale),
              Icon(Icons.chevron_right_rounded, size: 20 * scale, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cupertino ────────────────────────────────────────────────────────────────

class _CupertinoOrdersContent extends StatefulWidget {
  const _CupertinoOrdersContent();

  @override
  State<_CupertinoOrdersContent> createState() => _CupertinoOrdersContentState();
}

class _CupertinoOrdersContentState extends State<_CupertinoOrdersContent> {
  // 0=todos, 1=en revisión, 2=en tránsito, 3=entregados.
  int _tabIndex = 0;

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
                  _CupertinoOrdersHeroHeader(scale: scale),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16 * scale, 18 * scale, 16 * scale, 2 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.ordersHistoryTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 24 * scale,
                            fontWeight: FontWeight.w800,
                            color: kFeyamTint,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          l10n.ordersHistorySubtitle,
                          style: TextStyle(color: kFeyamLabelSec, fontSize: 13.5 * scale),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 0, 0),
                    child: _CupertinoFilterPills(
                      scale: scale,
                      selectedIndex: _tabIndex,
                      labels: [
                        l10n.ordersTabAll,
                        l10n.ordersTabReview,
                        l10n.ordersTabShipping,
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
        final orders = state.orders.map(_toOrderVm).toList();
        final filtered = _filterOrders(orders, _tabIndex);

        if (filtered.isEmpty) {
          return FeyamEmptyState(
            icon: CupertinoIcons.cube_box_fill,
            title: l10n.ordersEmptyTitle,
            subtitle: l10n.ordersEmptySubtitle,
          );
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 32 * scale),
          itemCount: filtered.length,
          separatorBuilder: (_, _) => SizedBox(height: 5 * scale),
          itemBuilder: (context, index) =>
              _CupertinoOrderCard(scale: scale, order: filtered[index]),
        );
    }
  }
}

class _CupertinoOrdersHeroHeader extends StatelessWidget {
  const _CupertinoOrdersHeroHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<UnreadCountBloc>().state.count;

    return DecoratedBox(
      decoration: const BoxDecoration(color: kFeyamTint),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 8 * scale),
          child: Row(
            children: <Widget>[
              Image.asset('assets/branding/logo_white.png', height: 22 * scale),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(builder: (_) => const NotificationsScreen()),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Icon(CupertinoIcons.bell, size: 22 * scale, color: CupertinoColors.white),
                    if (unreadCount > 0)
                      Positioned(
                        top: -4 * scale,
                        right: -6 * scale,
                        child: Container(
                          width: 16 * scale,
                          height: 16 * scale,
                          decoration: const BoxDecoration(color: kFeyamRed, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '$unreadCount',
                              style: TextStyle(
                                fontSize: 10 * scale,
                                fontWeight: FontWeight.w700,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CupertinoFilterPills extends StatelessWidget {
  const _CupertinoFilterPills({
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
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 36 * scale,
      child: Semantics(
        label: l10n.ordersFilterSemanticLabel,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: labels.length,
          separatorBuilder: (_, _) => SizedBox(width: 8 * scale),
          itemBuilder: (context, i) {
            final selected = i == selectedIndex;
            return GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                decoration: BoxDecoration(
                  color: selected ? kFeyamTint : kFeyamCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: selected ? kFeyamTint : kFeyamSepLight),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: selected ? CupertinoColors.white : kFeyamLabelSec,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13 * scale,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CupertinoOrderThumbnail extends StatelessWidget {
  const _CupertinoOrderThumbnail({required this.scale, required this.imageUrl});

  final double scale;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final size = 56 * scale;
    final placeholder = Icon(CupertinoIcons.cube_box_fill, size: 26 * scale, color: kFeyamLabelSec);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12 * scale),
      child: Container(
        width: size,
        height: size,
        color: kFeyamBg,
        child: imageUrl == null
            ? placeholder
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
              ),
      ),
    );
  }
}

class _CupertinoOrderCard extends StatelessWidget {
  const _CupertinoOrderCard({required this.scale, required this.order});

  final double scale;
  final _OrderVm order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = _statusStyle(order.status);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => OrderDetailScreen(
            orderId: order.id,
            title: order.title,
            price: order.price,
            status: orderDisplayStatusKey(order.status),
            date: order.date,
            imageUrl: order.imageUrl,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: kFeyamCard,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(14 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _CupertinoOrderThumbnail(scale: scale, imageUrl: order.imageUrl),
            SizedBox(width: 14 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: _StatusPill(
                      scale: scale,
                      label: _statusLabel(l10n, order.status),
                      bg: style.bg,
                      fg: style.fg,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    order.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: kFeyamTint, fontSize: 12.5 * scale),
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: <Widget>[
                      Icon(CupertinoIcons.calendar, size: 12 * scale, color: kFeyamTint),
                      SizedBox(width: 4 * scale),
                      Expanded(
                        child: Text(
                          order.date,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: kFeyamTint, fontSize: 11.5 * scale),
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        order.price,
                        style: TextStyle(color: kFeyamLabel, fontWeight: FontWeight.w700, fontSize: 14.5 * scale),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 4 * scale),
            Icon(CupertinoIcons.chevron_right, size: 18 * scale, color: kFeyamLabelTer),
          ],
        ),
      ),
    );
  }
}
