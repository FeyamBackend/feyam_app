import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoOrdersContent();
    }

    return Center(child: Text(l10n.navOrders));
  }
}

class _CupertinoOrdersContent extends StatelessWidget {
  const _CupertinoOrdersContent();

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
        statusIcon: CupertinoIcons.clock,
        statusForeground: CupertinoColors.black,
        statusBackground: const Color(0xFFE1E2E7),
      ),
      _OrderHistoryItem(
        id: '#FY-90211',
        dateLine: l10n.ordersOrder2Date,
        timeLine: l10n.ordersOrder2Time,
        itemCount: l10n.ordersOrder2Items,
        total: r'$450.00',
        status: l10n.ordersStatusPendingVerification,
        statusIcon: CupertinoIcons.shield,
        statusForeground: const Color(0xFF4E6168),
        statusBackground: const Color(0xFFCBEAF3),
      ),
      _OrderHistoryItem(
        id: '#FY-89942',
        dateLine: l10n.ordersOrder3Date,
        itemCount: l10n.ordersOrder3Items,
        total: r'$3,120.75',
        status: l10n.ordersStatusCompleted,
        statusIcon: CupertinoIcons.checkmark_alt_circle,
        statusForeground: const Color(0xFFBAC2DD),
        statusBackground: const Color(0xFF3D496E),
      ),
      _OrderHistoryItem(
        id: '#FY-89710',
        dateLine: l10n.ordersOrder4Date,
        itemCount: l10n.ordersOrder4Items,
        total: r'$890.00',
        status: l10n.ordersStatusCompleted,
        statusIcon: CupertinoIcons.checkmark_alt_circle,
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
              _CupertinoOrdersHeader(scale: scale),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    28 * scale,
                    56 * scale,
                    28 * scale,
                    28 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _CupertinoOrdersTitle(scale: scale),
                      SizedBox(height: 56 * scale),
                      for (final order in orders) ...[
                        _CupertinoOrderCard(scale: scale, order: order),
                        SizedBox(height: 30 * scale),
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
        color: Color(0xFFFAF9FE),
        border: Border(bottom: BorderSide(color: Color(0xFFE8E8EE))),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 106 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 36 * scale),
            child: Row(
              children: <Widget>[
                CupertinoButton(
                  minimumSize: Size.square(42 * scale),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: Semantics(
                    label: l10n.profileMenuSemanticLabel,
                    child: Icon(
                      CupertinoIcons.line_horizontal_3,
                      color: const Color(0xFF002B45),
                      size: 31 * scale,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Feyam',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.textStyle.copyWith(
                      color: const Color(0xFF002B45),
                      fontSize: 38 * scale,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
                CupertinoButton(
                  minimumSize: Size.square(42 * scale),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: Semantics(
                    label: l10n.cartSearchSemanticLabel,
                    child: Icon(
                      CupertinoIcons.search,
                      color: const Color(0xFF002B45),
                      size: 36 * scale,
                    ),
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

class _CupertinoOrdersTitle extends StatelessWidget {
  const _CupertinoOrdersTitle({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = CupertinoTheme.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            l10n.ordersHistoryTitle,
            style: theme.textTheme.textStyle.copyWith(
              color: CupertinoColors.black,
              fontSize: 48 * scale,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
        ),
        CupertinoButton(
          minimumSize: Size.square(48 * scale),
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: Semantics(
            label: l10n.ordersFilterSemanticLabel,
            child: Icon(
              CupertinoIcons.slider_horizontal_3,
              color: const Color(0xFF263238),
              size: 32 * scale,
            ),
          ),
        ),
      ],
    );
  }
}

class _CupertinoOrderCard extends StatelessWidget {
  const _CupertinoOrderCard({required this.scale, required this.order});

  final double scale;
  final _OrderHistoryItem order;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(38 * scale),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          40 * scale,
          40 * scale,
          40 * scale,
          40 * scale,
        ),
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
                        style: theme.textTheme.textStyle.copyWith(
                          color: CupertinoColors.black,
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        order.timeLine == null
                            ? order.dateLine
                            : '${order.dateLine}\n${order.timeLine}',
                        style: theme.textTheme.textStyle.copyWith(
                          color: const Color(0xFF6F7880),
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 18 * scale),
                _CupertinoOrderStatusBadge(scale: scale, order: order),
              ],
            ),
            SizedBox(height: 30 * scale),
            Divider(
              height: 1,
              thickness: scale,
              color: const Color(0xFFE4E6EC),
            ),
            SizedBox(height: 30 * scale),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    order.itemCount,
                    style: theme.textTheme.textStyle.copyWith(
                      color: const Color(0xFF1E252B),
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  order.total,
                  style: theme.textTheme.textStyle.copyWith(
                    color: const Color(0xFF002B45),
                    fontSize: 27 * scale,
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

class _CupertinoOrderStatusBadge extends StatelessWidget {
  const _CupertinoOrderStatusBadge({required this.scale, required this.order});

  final double scale;
  final _OrderHistoryItem order;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: order.statusBackground,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          14 * scale,
          8 * scale,
          14 * scale,
          8 * scale,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              order.statusIcon,
              color: order.statusForeground,
              size: 20 * scale,
            ),
            SizedBox(width: 8 * scale),
            Text(
              order.status,
              style: theme.textTheme.textStyle.copyWith(
                color: order.statusForeground,
                fontSize: 23 * scale,
                fontWeight: FontWeight.w400,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
