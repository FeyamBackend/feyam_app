import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/core/widgets/feyam_hero_header.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Friendly short order code derived from the backend's GUID `orderId`
/// (e.g. `08f97b3b-e8a9-...` → `08F97B3B`) — the full GUID is too long to
/// show inline in an app bar, card, or info row.
String _shortOrderId(String orderId) {
  final compact = orderId.replaceAll('-', '');
  return (compact.length > 8 ? compact.substring(0, 8) : compact).toUpperCase();
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.title,
    required this.price,
    required this.status,
    required this.date,
    this.delivery,
    this.imageUrl,
  });

  final String orderId;
  final String title;
  final String price;
  final String status;
  final String date;
  final String? delivery;
  final String? imageUrl;

  static const _statusKeys = <String>[
    'review',
    'payment',
    'shipping',
    'delivered',
  ];

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return _CupertinoOrderDetailContent(
        orderId: orderId,
        title: title,
        price: price,
        status: status,
        imageUrl: imageUrl,
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final cur = _statusKeys.indexOf(status).clamp(0, 3);

    final stepLabels = <String>[
      l10n.ordersStatusEnRevision,
      l10n.ordersStatusPorPagar,
      l10n.ordersStatusEnCamino,
      l10n.ordersStatusEntregado,
    ];

    final (statusLabel, statusBg, statusFg) = switch (status) {
      'payment' => (
        l10n.ordersStatusPorPagar,
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      'shipping' => (
        l10n.ordersStatusEnCamino,
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      'delivered' => (
        l10n.ordersStatusEntregado,
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
      _ => (
        l10n.ordersStatusEnRevision,
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return Scaffold(
          backgroundColor: colors.surface,
          body: Column(
            children: <Widget>[
              FeyamHeroHeader(
                scale: scale,
                showBackButton: true,
                title: l10n.ordDetailTitle,
              ),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(decoration: TextDecoration.none),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Product summary card
                        DecoratedBox(
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
                          child: Padding(
                            padding: EdgeInsets.all(14 * scale),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    12 * scale,
                                  ),
                                  child: Container(
                                    width: 64 * scale,
                                    height: 64 * scale,
                                    color: colors.surfaceContainerHighest,
                                    child: Builder(
                                      builder: (context) {
                                        final placeholder = Icon(
                                          Icons.inventory_2_rounded,
                                          size: 30 * scale,
                                          color: colors.onSurfaceVariant,
                                        );
                                        if (imageUrl == null) {
                                          return placeholder;
                                        }
                                        return Image.network(
                                          imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              placeholder,
                                          loadingBuilder:
                                              (context, child, progress) =>
                                                  progress == null
                                                  ? child
                                                  : placeholder,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16 * scale),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        title,
                                        style: textTheme.titleMedium?.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 17 * scale,
                                        ),
                                      ),
                                      SizedBox(height: 4 * scale),
                                      Text(
                                        '#FY-${_shortOrderId(orderId)} · $price',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 13 * scale,
                                        ),
                                      ),
                                      SizedBox(height: 8 * scale),
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BorderRadius.circular(
                                            6 * scale,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10 * scale,
                                            vertical: 4 * scale,
                                          ),
                                          child: Text(
                                            statusLabel,
                                            style: textTheme.labelSmall
                                                ?.copyWith(
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
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        // Info rows
                        _InfoRow(
                          scale: scale,
                          label: l10n.ordDetailId,
                          value: '#FY-${_shortOrderId(orderId)}',
                        ),
                        _InfoRow(
                          scale: scale,
                          label: l10n.ordDetailDate,
                          value: date,
                        ),
                        if (delivery != null)
                          _InfoRow(
                            scale: scale,
                            label: l10n.ordDetailEstDelivery,
                            value: delivery!,
                            valueColor: colors.primary,
                          ),
                        SizedBox(height: 8 * scale),
                        Divider(color: colors.outlineVariant),
                        SizedBox(height: 16 * scale),
                        // Tracking
                        Text(
                          l10n.ordDetailTracking,
                          style: textTheme.titleMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16 * scale,
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        Padding(
                          padding: EdgeInsets.only(left: 8 * scale),
                          child: Column(
                            children: <Widget>[
                              for (var i = 0; i < _statusKeys.length; i++)
                                _TrackingStep(
                                  scale: scale,
                                  label: stepLabels[i],
                                  done: i <= cur,
                                  current: i == cur,
                                  last: i == _statusKeys.length - 1,
                                  currentStatusLabel:
                                      l10n.ordDetailCurrentStatus,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.scale,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final double scale;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5 * scale),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 13 * scale,
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                color: valueColor ?? colors.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 13 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  const _TrackingStep({
    required this.scale,
    required this.label,
    required this.done,
    required this.current,
    required this.last,
    required this.currentStatusLabel,
  });

  final double scale;
  final String label;
  final bool done;
  final bool current;
  final bool last;
  final String currentStatusLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24 * scale,
              height: 24 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? colors.primary : colors.surfaceContainerHighest,
              ),
              child: done
                  ? Icon(
                      Icons.check_rounded,
                      size: 15 * scale,
                      color: colors.onPrimary,
                    )
                  : null,
            ),
            if (!last)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 2 * scale,
                height: 44 * scale,
                color: done && !current
                    ? colors.primary
                    : colors.outlineVariant,
              ),
          ],
        ),
        SizedBox(width: 16 * scale),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: 2 * scale,
              bottom: last ? 0 : 20 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: done ? colors.onSurface : colors.onSurfaceVariant,
                    fontWeight: current ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 15 * scale,
                  ),
                ),
                if (current) ...[
                  SizedBox(height: 2 * scale),
                  Text(
                    currentStatusLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 12 * scale,
                    ),
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

// ── Cupertino Order Detail ────────────────────────────────────────────────────

class _CupertinoOrderDetailContent extends StatelessWidget {
  const _CupertinoOrderDetailContent({
    required this.orderId,
    required this.title,
    required this.price,
    required this.status,
    this.imageUrl,
  });

  final String orderId;
  final String title;
  final String price;
  final String status;
  final String? imageUrl;

  static const _steps = <String>[
    'En revisión',
    'Por pagar',
    'En camino',
    'Entregado',
  ];
  static const _stepKeys = <String>[
    'review',
    'payment',
    'shipping',
    'delivered',
  ];

  static const _stepColors = <String, Color>{
    'En revisión': kFeyamOrange,
    'Por pagar': kFeyamTint,
    'En camino': kFeyamTeal,
    'Entregado': kFeyamGreen,
  };

  static const _stepIcons = <String, IconData>{
    'En revisión': CupertinoIcons.clock_fill,
    'Por pagar': CupertinoIcons.creditcard_fill,
    'En camino': CupertinoIcons.airplane,
    'Entregado': CupertinoIcons.checkmark_circle_fill,
  };

  FeyamOrderStatus get _feyamStatus => feyamStatusFromString(status);

  int get _cur => _stepKeys.indexOf(status).clamp(0, 3);

  @override
  Widget build(BuildContext context) {
    final cur = _cur;
    final currentStepLabel = _steps[cur];
    final stepColor = _stepColors[currentStepLabel] ?? kFeyamTint;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return ColoredBox(
          color: kFeyamBg,
          child: Column(
            children: <Widget>[
              CupertinoNavigationBar(
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(CupertinoIcons.chevron_back, size: 18),
                      SizedBox(width: 2),
                      Text('Pedidos', style: TextStyle(fontSize: 17)),
                    ],
                  ),
                ),
                middle: const Text('Pedido'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 32 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Header card
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16 * scale,
                          16 * scale,
                          16 * scale,
                          0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: kFeyamCard,
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          padding: EdgeInsets.all(16 * scale),
                          child: Row(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12 * scale),
                                child: Container(
                                  width: 56 * scale,
                                  height: 56 * scale,
                                  color: kFeyamBg,
                                  child: Builder(
                                    builder: (context) {
                                      const placeholder = Icon(
                                        CupertinoIcons.cube_box_fill,
                                        size: 28,
                                        color: kFeyamLabelSec,
                                      );
                                      if (imageUrl == null) return placeholder;
                                      return Image.network(
                                        imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => placeholder,
                                        loadingBuilder:
                                            (context, child, progress) =>
                                                progress == null
                                                ? child
                                                : placeholder,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 14 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w600,
                                        color: kFeyamLabel,
                                        letterSpacing: -0.41,
                                      ),
                                    ),
                                    SizedBox(height: 2 * scale),
                                    Text(
                                      'Pedido #FY-${_shortOrderId(orderId)}',
                                      style: TextStyle(
                                        fontSize: 13 * scale,
                                        color: kFeyamLabelSec,
                                      ),
                                    ),
                                    SizedBox(height: 4 * scale),
                                    Text(
                                      price,
                                      style: TextStyle(
                                        fontSize: 17 * scale,
                                        fontWeight: FontWeight.w700,
                                        color: kFeyamTint,
                                        letterSpacing: -0.41,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              FeyamStatusBadge(status: _feyamStatus),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      // Timeline
                      FeyamListSection(
                        header: 'Seguimiento',
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              20 * scale,
                              16 * scale,
                              20 * scale,
                              8 * scale,
                            ),
                            child: Column(
                              children: <Widget>[
                                for (var i = 0; i < _steps.length; i++)
                                  _TimelineStep(
                                    label: _steps[i],
                                    done: i <= cur,
                                    active: i == cur,
                                    last: i == _steps.length - 1,
                                    stepColor: stepColor,
                                    icon: _stepIcons[_steps[i]]!,
                                    activeIcon: _stepIcons[currentStepLabel]!,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Info
                      FeyamListSection(
                        header: 'Información del pedido',
                        children: <Widget>[
                          FeyamListTile(
                            title: const Text('Número de pedido'),
                            detail: Text('#FY-${_shortOrderId(orderId)}'),
                            chevron: false,
                          ),
                          FeyamListTile(
                            title: const Text('Total estimado'),
                            detail: Text(price),
                            chevron: false,
                            isLast: true,
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

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.done,
    required this.active,
    required this.last,
    required this.stepColor,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final bool done;
  final bool active;
  final bool last;
  final Color stepColor;
  final IconData icon;
  final IconData activeIcon;

  @override
  Widget build(BuildContext context) {
    final dotColor = done ? (active ? stepColor : kFeyamGreen) : kFeyamFillTer;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Dot + line
        Column(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: stepColor.withValues(alpha: 0.13),
                          blurRadius: 0,
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: done
                  ? Icon(
                      active ? activeIcon : CupertinoIcons.checkmark,
                      size: 15,
                      color: CupertinoColors.white,
                    )
                  : Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kFeyamLabelTer,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
            if (!last)
              Container(
                width: 2,
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: done && !active ? stepColor : kFeyamFillTer,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        // Label
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 8 : 24, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: active
                        ? FontWeight.w700
                        : (done ? FontWeight.w500 : FontWeight.w400),
                    color: done ? kFeyamLabel : kFeyamLabelTer,
                    letterSpacing: -0.41,
                  ),
                ),
                if (active) ...[
                  const SizedBox(height: 2),
                  const Text(
                    'Estado actual de tu pedido',
                    style: TextStyle(fontSize: 13, color: kFeyamLabelSec),
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
