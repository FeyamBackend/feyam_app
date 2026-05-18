import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
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

class _MaterialOrdersContent extends StatelessWidget {
  const _MaterialOrdersContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orders = <_OrderHistoryItem>[
      _OrderHistoryItem(
        id: '#FY-90234',
        dateLine: l10n.ordersOrder1Date,
        timeLine: l10n.ordersOrder1Time,
        itemCount: l10n.ordersOrder1Items,
        total: r'$1,240.50',
        status: l10n.ordersStatusAwaitingApproval,
        statusIcon: Icons.schedule,
        statusForeground: const Color(0xFF111315),
        statusBackground: const Color(0xFFE1E2E7),
      ),
      _OrderHistoryItem(
        id: '#FY-90211',
        dateLine: l10n.ordersOrder2Date,
        timeLine: l10n.ordersOrder2Time,
        itemCount: l10n.ordersOrder2Items,
        total: r'$450.00',
        status: l10n.ordersStatusPendingVerification,
        statusIcon: Icons.verified_user_outlined,
        statusForeground: const Color(0xFF4E6168),
        statusBackground: const Color(0xFFCBEAF3),
      ),
      _OrderHistoryItem(
        id: '#FY-89942',
        dateLine: l10n.ordersOrder3Date,
        itemCount: l10n.ordersOrder3Items,
        total: r'$3,120.75',
        status: l10n.ordersStatusCompleted,
        statusIcon: Icons.check_circle_outline,
        statusForeground: const Color(0xFFBAC2DD),
        statusBackground: const Color(0xFF3D496E),
      ),
      _OrderHistoryItem(
        id: '#FY-89710',
        dateLine: l10n.ordersOrder4Date,
        itemCount: l10n.ordersOrder4Items,
        total: r'$890.00',
        status: l10n.ordersStatusCompleted,
        statusIcon: Icons.check_circle_outline,
        statusForeground: const Color(0xFFBAC2DD),
        statusBackground: const Color(0xFF3D496E),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 648).clamp(0.56, 1.0);

        return ColoredBox(
          color: const Color(0xFFFAF9FE),
          child: Column(
            children: <Widget>[
              _MaterialOrdersHeader(scale: scale),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    28 * scale,
                    28 * scale,
                    28 * scale,
                    28 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (final order in orders) ...[
                        _MaterialOrderCard(scale: scale, order: order),
                        SizedBox(height: 24 * scale),
                      ],
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

class _MaterialOrdersHeader extends StatelessWidget {
  const _MaterialOrdersHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF9FE),
        border: Border(bottom: BorderSide(color: Color(0xFFD8DBE3))),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 100 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 29 * scale),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.ordersHistoryTitle,
                    style: textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF111315),
                      fontSize: 31 * scale,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  tooltip: l10n.ordersFilterSemanticLabel,
                  icon: Icon(
                    Icons.filter_list,
                    color: const Color(0xFF263238),
                    size: 28 * scale,
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

class _MaterialOrderCard extends StatelessWidget {
  const _MaterialOrderCard({required this.scale, required this.order});

  final double scale;
  final _OrderHistoryItem order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0xFFDADDE7), width: scale),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(32 * scale),
        child: Column(
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
                        order.id,
                        style: textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF111315),
                          fontSize: 22 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                      Text(
                        order.timeLine == null
                            ? order.dateLine
                            : '${order.dateLine}\n${order.timeLine}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF778090),
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16 * scale),
                _MaterialOrderStatusBadge(scale: scale, order: order),
              ],
            ),
            SizedBox(height: 24 * scale),
            Divider(
              height: 1,
              thickness: scale,
              color: const Color(0xFFE4E6EC),
            ),
            SizedBox(height: 24 * scale),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    order.itemCount,
                    style: textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF1E252B),
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  order.total,
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF002B45),
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialOrderStatusBadge extends StatelessWidget {
  const _MaterialOrderStatusBadge({required this.scale, required this.order});

  final double scale;
  final _OrderHistoryItem order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: order.statusBackground,
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          10 * scale,
          6 * scale,
          10 * scale,
          6 * scale,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              order.statusIcon,
              color: order.statusForeground,
              size: 16 * scale,
            ),
            SizedBox(width: 6 * scale),
            Text(
              order.status,
              style: textTheme.labelSmall?.copyWith(
                color: order.statusForeground,
                fontSize: 17 * scale,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoOrdersContent extends StatelessWidget {
  const _CupertinoOrdersContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orders = <_CupertinoOrderItem>[
      _CupertinoOrderItem(
        id: '#FY-90234',
        dateTime: l10n.ordersCupertinoOrder1DateTime,
        itemCount: l10n.ordersCupertinoOrder1Items,
        total: r'$128.50',
        status: l10n.ordersStatusEstimated,
        statusForeground: const Color(0xFF8E8E93),
        statusBackground: const Color(0xFFEEEEEF),
      ),
      _CupertinoOrderItem(
        id: '#FY-89912',
        dateTime: l10n.ordersCupertinoOrder2DateTime,
        itemCount: l10n.ordersCupertinoOrder2Items,
        total: r'$45.00',
        status: l10n.ordersStatusPendingVerification,
        statusForeground: const Color(0xFF5E56CE),
        statusBackground: const Color(0xFFECEAFF),
      ),
      _CupertinoOrderItem(
        id: '#FY-88743',
        dateTime: l10n.ordersCupertinoOrder3DateTime,
        itemCount: l10n.ordersCupertinoOrder3Items,
        total: r'$312.20',
        status: l10n.ordersStatusConfirmed,
        statusForeground: const Color(0xFF1A56E0),
        statusBackground: const Color(0xFFE5EDFE),
      ),
      _CupertinoOrderItem(
        id: '#FY-88601',
        dateTime: l10n.ordersCupertinoOrder4DateTime,
        itemCount: l10n.ordersCupertinoOrder4Items,
        total: r'$89.99',
        status: l10n.ordersStatusNeedsAdjustment,
        statusForeground: const Color(0xFFCF3030),
        statusBackground: null,
      ),
      _CupertinoOrderItem(
        id: '#FY-87229',
        dateTime: l10n.ordersCupertinoOrder5DateTime,
        itemCount: l10n.ordersCupertinoOrder5Items,
        total: r'$210.00',
        status: l10n.ordersStatusAwaitingCustomerApproval,
        statusForeground: const Color(0xFF5A5A5E),
        statusBackground: const Color(0xFFE8E8E9),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 648).clamp(0.56, 1.0);

        return ColoredBox(
          color: const Color(0xFFF2F2F7),
          child: Column(
            children: <Widget>[
              _CupertinoOrdersHeader(scale: scale),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    24 * scale,
                    20 * scale,
                    28 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _CupertinoOrdersLargeTitle(scale: scale),
                      SizedBox(height: 18 * scale),
                      _CupertinoOrdersSearchBar(scale: scale),
                      SizedBox(height: 22 * scale),
                      for (final order in orders) ...[
                        _CupertinoOrderCard(scale: scale, order: order),
                        SizedBox(height: 14 * scale),
                      ],
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

class _CupertinoOrdersHeader extends StatelessWidget {
  const _CupertinoOrdersHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CupertinoTheme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F7),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA))),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 88 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale),
            child: Row(
              children: <Widget>[
                CupertinoButton(
                  minimumSize: Size.square(44 * scale),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: Semantics(
                    label: l10n.profileMenuSemanticLabel,
                    child: Icon(
                      CupertinoIcons.line_horizontal_3,
                      color: const Color(0xFF1C1C1E),
                      size: 24 * scale,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.navOrders,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.textStyle.copyWith(
                      color: const Color(0xFF1C1C1E),
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
                SizedBox.square(dimension: 44 * scale),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CupertinoOrdersLargeTitle extends StatelessWidget {
  const _CupertinoOrdersLargeTitle({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CupertinoTheme.of(context);

    return Text(
      l10n.navOrders,
      style: theme.textTheme.textStyle.copyWith(
        color: const Color(0xFF1C1C1E),
        fontSize: 36 * scale,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}

class _CupertinoOrdersSearchBar extends StatelessWidget {
  const _CupertinoOrdersSearchBar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 52 * scale,
      child: CupertinoSearchTextField(
        placeholder: l10n.ordersSearchPlaceholder,
        style: TextStyle(fontSize: 17 * scale),
        backgroundColor: const Color(0xFFE8E8ED),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
    );
  }
}

class _CupertinoOrderCard extends StatelessWidget {
  const _CupertinoOrderCard({required this.scale, required this.order});

  final double scale;
  final _CupertinoOrderItem order;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: const Color(0xFFE5E5EA), width: scale),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          18 * scale,
          20 * scale,
          18 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        order.id,
                        style: theme.textTheme.textStyle.copyWith(
                          color: const Color(0xFF1C1C1E),
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        order.dateTime,
                        style: theme.textTheme.textStyle.copyWith(
                          color: const Color(0xFF8E8E93),
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12 * scale),
                _CupertinoOrderStatusBadge(scale: scale, order: order),
              ],
            ),
            SizedBox(height: 16 * scale),
            Divider(
              height: 1,
              thickness: scale,
              color: const Color(0xFFE5E5EA),
            ),
            SizedBox(height: 16 * scale),
            Row(
              children: <Widget>[
                Icon(
                  CupertinoIcons.archivebox,
                  color: const Color(0xFF8E8E93),
                  size: 16 * scale,
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: Text(
                    order.itemCount,
                    style: theme.textTheme.textStyle.copyWith(
                      color: const Color(0xFF8E8E93),
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  order.total,
                  style: theme.textTheme.textStyle.copyWith(
                    color: const Color(0xFF1A56E0),
                    fontSize: 17 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoOrderStatusBadge extends StatelessWidget {
  const _CupertinoOrderStatusBadge({required this.scale, required this.order});

  final double scale;
  final _CupertinoOrderItem order;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final textStyle = theme.textTheme.textStyle.copyWith(
      color: order.statusForeground,
      fontSize: 13 * scale,
      fontWeight: FontWeight.w500,
      height: 1,
    );

    if (order.statusBackground == null) {
      return Text(order.status, style: textStyle);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: order.statusBackground,
        borderRadius: BorderRadius.circular(6 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8 * scale, 5 * scale, 8 * scale, 5 * scale),
        child: Text(order.status, style: textStyle),
      ),
    );
  }
}

class _CupertinoOrderItem {
  const _CupertinoOrderItem({
    required this.id,
    required this.dateTime,
    required this.itemCount,
    required this.total,
    required this.status,
    required this.statusForeground,
    this.statusBackground,
  });

  final String id;
  final String dateTime;
  final String itemCount;
  final String total;
  final String status;
  final Color statusForeground;
  final Color? statusBackground;
}

class _OrderHistoryItem {
  const _OrderHistoryItem({
    required this.id,
    required this.dateLine,
    this.timeLine,
    required this.itemCount,
    required this.total,
    required this.status,
    required this.statusIcon,
    required this.statusForeground,
    required this.statusBackground,
  });

  final String id;
  final String dateLine;
  final String? timeLine;
  final String itemCount;
  final String total;
  final String status;
  final IconData statusIcon;
  final Color statusForeground;
  final Color statusBackground;
}
