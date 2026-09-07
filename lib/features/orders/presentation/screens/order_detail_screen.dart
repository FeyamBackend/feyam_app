import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/core/widgets/feyam_hero_header.dart';
import 'package:feyam/features/orders/domain/entities/final_package_entity.dart';
import 'package:feyam/features/orders/domain/entities/order_detail_entity.dart';
import 'package:feyam/features/orders/domain/entities/quote_entity.dart';
import 'package:feyam/features/orders/domain/entities/shipment_entity.dart';
import 'package:feyam/features/orders/presentation/bloc/final_package_bloc.dart';
import 'package:feyam/features/orders/presentation/bloc/final_package_event.dart';
import 'package:feyam/features/orders/presentation/bloc/final_package_state.dart';
import 'package:feyam/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:feyam/features/orders/presentation/bloc/order_detail_event.dart';
import 'package:feyam/features/orders/presentation/bloc/order_detail_state.dart';
import 'package:feyam/features/orders/presentation/bloc/quote_bloc.dart';
import 'package:feyam/features/orders/presentation/bloc/quote_event.dart';
import 'package:feyam/features/orders/presentation/bloc/quote_state.dart';
import 'package:feyam/features/orders/presentation/bloc/shipments_bloc.dart';
import 'package:feyam/features/orders/presentation/bloc/shipments_event.dart';
import 'package:feyam/features/orders/presentation/bloc/shipments_state.dart';
import 'package:feyam/features/payments/presentation/screens/quote_payment_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Friendly short order code derived from the backend's GUID `orderId`
/// (e.g. `08f97b3b-e8a9-...` → `08F97B3B`) — the full GUID is too long to
/// show inline in an app bar, card, or info row.
String _shortOrderId(String orderId) {
  final compact = orderId.replaceAll('-', '');
  return (compact.length > 8 ? compact.substring(0, 8) : compact).toUpperCase();
}

const _submittedAtMonths = <String>[
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

/// Formats `OrderDetailEntity.submittedAt` for display (e.g. `15 ago 2026`),
/// mirroring `order_screen.dart`'s `_formatDate` convention.
String _formatSubmittedAt(DateTime d) {
  final local = d.toLocal();
  return '${local.day} ${_submittedAtMonths[local.month - 1]} ${local.year}';
}

/// Formats `QuoteEntity.expiresAt` for display (e.g. `16 ago 2026, 19:00`),
/// extending `_formatSubmittedAt`'s convention with a time component (the
/// `padLeft(2, '0')` style already used by `payment_methods_screen.dart`
/// for its expiry-date formatting) since a quote's validity window matters
/// down to the hour.
String _formatExpiresAt(DateTime d) {
  final local = d.toLocal();
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${_submittedAtMonths[local.month - 1]} ${local.year}, $hh:$mm';
}

/// A quote's validity window is worth calling out visually — rather than as a
/// plain data row — once it's this close to lapsing (or has already lapsed),
/// since a client needs to notice and pay before then.
const _quoteExpiringSoonThreshold = Duration(hours: 2);

bool _isQuoteExpiringSoon(DateTime expiresAt) {
  return expiresAt.difference(DateTime.now()) <= _quoteExpiringSoonThreshold;
}

/// Localized label for a [ShipmentEntity.status] raw backend value
/// (`AwaitingTracking`, `InTransit`, `Delivered`, `Exception`). Falls back to
/// the raw value itself for any status this client doesn't recognize yet,
/// mirroring how the rest of this screen treats unrecognized backend status
/// strings (e.g. `ordDetailBackendStatus` shows `detail.status` verbatim).
String _shipmentStatusLabel(String status, AppLocalizations l10n) {
  switch (status) {
    case 'AwaitingTracking':
      return l10n.ordShipmentsStatusAwaitingTracking;
    case 'InTransit':
      return l10n.ordShipmentsStatusInTransit;
    case 'Delivered':
      return l10n.ordShipmentsStatusDelivered;
    case 'Exception':
      return l10n.ordShipmentsStatusException;
    default:
      return status;
  }
}

/// Background/foreground colors for a shipment status pill, following the
/// same container/on-container pairing this screen's header status pill
/// already uses (see `_Md3OrderDetailContent`'s `statusBg`/`statusFg`
/// switch).
(Color, Color) _shipmentStatusColors(ColorScheme colors, String status) {
  return switch (status) {
    'InTransit' => (colors.primaryContainer, colors.onPrimaryContainer),
    'Delivered' => (colors.secondaryContainer, colors.onSecondaryContainer),
    'Exception' => (colors.errorContainer, colors.onErrorContainer),
    _ => (colors.surfaceContainerHighest, colors.onSurfaceVariant),
  };
}

/// Explainer shown while the backend has this order queued to be bundled
/// with other clients' orders for the same store (`OrderStatus.WaitingGroup`)
/// before it can move on to checkout. Appends the store name(s) involved,
/// built directly in Dart (not through l10n interpolation, which has no
/// existing precedent in this project's .arb files yet) the same way
/// `_formatSubmittedAt` already builds its own formatted string.
String? _waitingGroupMessage(OrderDetailEntity detail, AppLocalizations l10n) {
  if (detail.status != 'WaitingGroup') return null;

  final storeNames = detail.lines
      .map((line) => line.storeName)
      .whereType<String>()
      .where((name) => name.isNotEmpty)
      .toSet();

  return storeNames.isEmpty
      ? l10n.ordDetailWaitingGroup
      : '${l10n.ordDetailWaitingGroup} (${storeNames.join(', ')})';
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

  @override
  Widget build(BuildContext context) {
    // Fetches GET /api/orders/{id} for the new line-items/submittedAt/status
    // content added below. The header/stepper above keep rendering from the
    // constructor params regardless of how this fetch resolves. QuoteBloc
    // fetches GET /api/orders/{id}/quote, ShipmentsBloc fetches GET
    // /api/orders/{id}/shipments, and FinalPackageBloc fetches GET
    // /api/orders/{id}/final-package independently and in parallel — there's
    // no ordering dependency between any of the four.
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderDetailBloc>(
          create: (_) => sl<OrderDetailBloc>()
            ..add(OrderDetailRequested(orderId: orderId)),
        ),
        BlocProvider<QuoteBloc>(
          create: (_) =>
              sl<QuoteBloc>()..add(QuoteRequested(orderId: orderId)),
        ),
        BlocProvider<ShipmentsBloc>(
          create: (_) => sl<ShipmentsBloc>()
            ..add(ShipmentsRequested(orderId: orderId)),
        ),
        BlocProvider<FinalPackageBloc>(
          create: (_) => sl<FinalPackageBloc>()
            ..add(FinalPackageRequested(orderId: orderId)),
        ),
      ],
      child: AdaptivePlatform.isCupertino(context)
          ? _CupertinoOrderDetailContent(
              orderId: orderId,
              title: title,
              price: price,
              status: status,
              imageUrl: imageUrl,
            )
          : _Md3OrderDetailContent(
              orderId: orderId,
              title: title,
              price: price,
              status: status,
              date: date,
              delivery: delivery,
              imageUrl: imageUrl,
            ),
    );
  }
}

class _Md3OrderDetailContent extends StatelessWidget {
  const _Md3OrderDetailContent({
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
                        SizedBox(height: 8 * scale),
                        Divider(color: colors.outlineVariant),
                        SizedBox(height: 16 * scale),
                        // Line items fetched from GET /api/orders/{id}.
                        Text(
                          l10n.ordDetailItems,
                          style: textTheme.titleMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16 * scale,
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        BlocBuilder<OrderDetailBloc, OrderDetailState>(
                          builder: (context, state) => _Md3OrderItemsSection(
                            scale: scale,
                            l10n: l10n,
                            state: state,
                          ),
                        ),
                        // Final quote fetched from GET /api/orders/{id}/quote,
                        // once an operator has verified the group checkout.
                        // Renders nothing until then — a missing quote is the
                        // normal state for most orders, not an error.
                        BlocBuilder<QuoteBloc, QuoteState>(
                          builder: (context, state) => _Md3QuoteSection(
                            scale: scale,
                            l10n: l10n,
                            state: state,
                          ),
                        ),
                        // Shipments fetched from GET /api/orders/{id}/shipments,
                        // once the order's purchase group has been executed.
                        // Renders nothing until then (and renders nothing on an
                        // empty list) — no shipments yet is the normal state
                        // for most orders, not an error.
                        BlocBuilder<ShipmentsBloc, ShipmentsState>(
                          builder: (context, state) => _Md3ShipmentsSection(
                            scale: scale,
                            l10n: l10n,
                            state: state,
                          ),
                        ),
                        // Final package fetched from
                        // GET /api/orders/{id}/final-package, once Venezuela
                        // warehouse staff have physically received the
                        // order's items. Renders nothing until then — no
                        // final package yet is the normal state for most
                        // orders, not an error.
                        BlocBuilder<FinalPackageBloc, FinalPackageState>(
                          builder: (context, state) => _Md3FinalPackageSection(
                            scale: scale,
                            l10n: l10n,
                            state: state,
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

class _Md3OrderItemsSection extends StatelessWidget {
  const _Md3OrderItemsSection({
    required this.scale,
    required this.l10n,
    required this.state,
  });

  final double scale;
  final AppLocalizations l10n;
  final OrderDetailState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    switch (state.status) {
      case OrderDetailStatus.initial:
      case OrderDetailStatus.loading:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          child: Center(
            child: SizedBox(
              width: 20 * scale,
              height: 20 * scale,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            ),
          ),
        );
      case OrderDetailStatus.failure:
        return Text(
          l10n.ordDetailItemsError,
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 12 * scale,
          ),
        );
      case OrderDetailStatus.loaded:
        final detail = state.detail;
        if (detail == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _InfoRow(
              scale: scale,
              label: l10n.ordDetailSubmittedAt,
              value: _formatSubmittedAt(detail.submittedAt),
            ),
            _InfoRow(
              scale: scale,
              label: l10n.ordDetailBackendStatus,
              value: detail.status,
            ),
            if (_waitingGroupMessage(detail, l10n) case final String message) ...<Widget>[
              SizedBox(height: 8 * scale),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 13 * scale,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: 5 * scale),
                  Expanded(
                    child: Text(
                      message,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11 * scale,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 8 * scale),
            if (detail.lines.isEmpty)
              Text(
                l10n.ordDetailItemsEmpty,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12 * scale,
                ),
              )
            else
              for (final line in detail.lines)
                _Md3OrderLineTile(scale: scale, line: line),
          ],
        );
    }
  }
}

class _Md3OrderLineTile extends StatelessWidget {
  const _Md3OrderLineTile({required this.scale, required this.line});

  final double scale;
  final OrderLineEntity line;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final subtitleParts = <String>[
      if (line.variant != null && line.variant!.isNotEmpty) line.variant!,
      if (line.storeName != null && line.storeName!.isNotEmpty)
        line.storeName!,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  line.productTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 13 * scale,
                  ),
                ),
                if (subtitleParts.isNotEmpty) ...[
                  SizedBox(height: 2 * scale),
                  Text(
                    subtitleParts.join(' · '),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 11 * scale,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12 * scale),
          Text(
            '×${line.quantity}  ${line.currencyCode} ${line.unitPrice.toStringAsFixed(2)}',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 12 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Cotización final" section built from the GET /api/orders/{id}/quote
/// fetch state. Renders nothing while loading, on failure, or when no quote
/// exists yet (the normal case for most orders) — only a real, loaded quote
/// is shown.
class _Md3QuoteSection extends StatelessWidget {
  const _Md3QuoteSection({
    required this.scale,
    required this.l10n,
    required this.state,
  });

  final double scale;
  final AppLocalizations l10n;
  final QuoteState state;

  @override
  Widget build(BuildContext context) {
    if (state.status != QuoteStatus.loaded) return const SizedBox.shrink();
    final quote = state.quote;
    if (quote == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String money(double amount) =>
        '${quote.currencyCode} ${amount.toStringAsFixed(2)}';

    final expiringSoon = _isQuoteExpiringSoon(quote.expiresAt);
    final payable = quote.status != 'Paid';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 8 * scale),
        Divider(color: colors.outlineVariant),
        SizedBox(height: 16 * scale),
        Text(
          l10n.ordQuoteTitle,
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16 * scale,
          ),
        ),
        SizedBox(height: 12 * scale),
        _InfoRow(
          scale: scale,
          label: l10n.ordQuoteAllocatedCost,
          value: money(quote.allocatedRetailerCost),
        ),
        _InfoRow(
          scale: scale,
          label: l10n.ordQuoteFee,
          value: money(quote.feyamFee),
        ),
        _InfoRow(
          scale: scale,
          label: l10n.ordQuoteNationalLogistics,
          value: money(quote.nationalLogistics),
        ),
        _InfoRow(
          scale: scale,
          label: l10n.ordQuoteInternationalLogistics,
          value: money(quote.internationalLogistics),
        ),
        _InfoRow(
          scale: scale,
          label: l10n.ordQuoteTaxes,
          value: money(quote.feyamTaxes),
        ),
        _InfoRow(
          scale: scale,
          label: l10n.ordQuoteOther,
          value: money(quote.otherExplicitCharges),
        ),
        SizedBox(height: 4 * scale),
        _InfoRow(
          scale: scale,
          label: l10n.ordQuoteTotal,
          value: money(quote.finalCustomerTotal),
          valueColor: colors.primary,
        ),
        SizedBox(height: 4 * scale),
        if (expiringSoon)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5 * scale),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.warning_amber_rounded,
                  size: 15 * scale,
                  color: colors.error,
                ),
                SizedBox(width: 6 * scale),
                Expanded(
                  child: Text(
                    l10n.ordQuoteExpiresAt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13 * scale,
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Flexible(
                  child: Text(
                    _formatExpiresAt(quote.expiresAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 13 * scale,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          _InfoRow(
            scale: scale,
            label: l10n.ordQuoteExpiresAt,
            value: _formatExpiresAt(quote.expiresAt),
          ),
        if (payable) ...[
          SizedBox(height: 16 * scale),
          SizedBox(
            width: double.infinity,
            height: 48 * scale,
            child: FilledButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  AdaptivePlatform.pageRoute<void>(
                    context: context,
                    builder: (_) => QuotePaymentScreen(orderId: quote.orderId),
                  ),
                );
                // Whether the user paid, saw there was nothing to pay, or just
                // backed out, re-fetch so the section reflects the current
                // status rather than requiring a manual pull-to-refresh.
                if (context.mounted) {
                  context.read<QuoteBloc>().add(
                    QuoteRequested(orderId: quote.orderId),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.secondary,
                foregroundColor: colors.onSecondary,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.payment_rounded),
              label: Text(l10n.ordQuotePayButton),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Envíos" section built from the GET /api/orders/{id}/shipments fetch
/// state. Renders nothing while loading, on failure, or when the loaded
/// list is empty (the normal case for most orders, until their purchase
/// group has been executed) — only real, loaded shipments are shown.
class _Md3ShipmentsSection extends StatelessWidget {
  const _Md3ShipmentsSection({
    required this.scale,
    required this.l10n,
    required this.state,
  });

  final double scale;
  final AppLocalizations l10n;
  final ShipmentsState state;

  @override
  Widget build(BuildContext context) {
    if (state.status != ShipmentsStatus.loaded) return const SizedBox.shrink();
    if (state.shipments.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 8 * scale),
        Divider(color: colors.outlineVariant),
        SizedBox(height: 16 * scale),
        Text(
          l10n.ordShipmentsTitle,
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16 * scale,
          ),
        ),
        SizedBox(height: 12 * scale),
        for (final shipment in state.shipments)
          _Md3ShipmentTile(scale: scale, l10n: l10n, shipment: shipment),
      ],
    );
  }
}

class _Md3ShipmentTile extends StatelessWidget {
  const _Md3ShipmentTile({
    required this.scale,
    required this.l10n,
    required this.shipment,
  });

  final double scale;
  final AppLocalizations l10n;
  final ShipmentEntity shipment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (statusBg, statusFg) = _shipmentStatusColors(colors, shipment.status);

    return Container(
      margin: EdgeInsets.only(bottom: 10 * scale),
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (shipment.carrier != null && shipment.carrier!.isNotEmpty)
                Expanded(
                  child: Text(
                    shipment.carrier!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13 * scale,
                    ),
                  ),
                )
              else
                const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6 * scale),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 4 * scale,
                  ),
                  child: Text(
                    _shipmentStatusLabel(shipment.status, l10n),
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
          if (shipment.trackingNumbers.isNotEmpty) ...[
            SizedBox(height: 8 * scale),
            Text(
              l10n.ordShipmentsTracking,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 11 * scale,
              ),
            ),
            SizedBox(height: 2 * scale),
            for (final tracking in shipment.trackingNumbers)
              Text(
                tracking,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontSize: 13 * scale,
                ),
              ),
          ],
          if (shipment.status == 'Exception' &&
              shipment.exceptionReason != null &&
              shipment.exceptionReason!.isNotEmpty) ...[
            SizedBox(height: 8 * scale),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14 * scale,
                  color: colors.error,
                ),
                SizedBox(width: 6 * scale),
                Expanded(
                  child: Text(
                    shipment.exceptionReason!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w500,
                      fontSize: 12 * scale,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Formats a weight in lb for display, or an em dash when not yet recorded.
String _formatWeightLb(double? lb) => lb == null ? '—' : '${lb.toStringAsFixed(2)} lb';

/// A signed percentage suffix appended to the actual-weight row (e.g.
/// ` (+2.3%)`), or empty when no variance can be computed yet (no actual
/// weight recorded, or nothing to compare it against).
String _varianceSuffix(double? variancePct) {
  if (variancePct == null) return '';
  final sign = variancePct >= 0 ? '+' : '';
  return ' ($sign${variancePct.toStringAsFixed(1)}%)';
}

/// "Recibido en Venezuela" section built from the
/// GET /api/orders/{id}/final-package fetch state. Renders nothing while
/// loading, on failure, or when no final package exists yet (the normal
/// case for most orders, until Venezuela warehouse staff have physically
/// received its items) — only a real, loaded final package is shown.
class _Md3FinalPackageSection extends StatelessWidget {
  const _Md3FinalPackageSection({
    required this.scale,
    required this.l10n,
    required this.state,
  });

  final double scale;
  final AppLocalizations l10n;
  final FinalPackageState state;

  @override
  Widget build(BuildContext context) {
    if (state.status != FinalPackageStatus.loaded) return const SizedBox.shrink();
    final package = state.package;
    if (package == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: 8 * scale),
        Divider(color: colors.outlineVariant),
        SizedBox(height: 16 * scale),
        Text(
          l10n.ordFinalPackageTitle,
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16 * scale,
          ),
        ),
        SizedBox(height: 12 * scale),
        _InfoRow(
          scale: scale,
          label: l10n.ordFinalPackageWeight,
          value:
              '${_formatWeightLb(package.actualWeightLb)}${_varianceSuffix(package.variancePct)}',
        ),
        _InfoRow(
          scale: scale,
          label: l10n.ordFinalPackageEstimated,
          value: _formatWeightLb(package.estimatedWeightLb),
        ),
        if (package.discrepancies.isNotEmpty) ...[
          SizedBox(height: 8 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.warning_amber_rounded,
                size: 15 * scale,
                color: colors.error,
              ),
              SizedBox(width: 6 * scale),
              Text(
                l10n.ordFinalPackageDiscrepancyTitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13 * scale,
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          for (final d in package.discrepancies)
            Padding(
              padding: EdgeInsets.only(left: 21 * scale, bottom: 6 * scale),
              child: Text(
                '${d.productTitle}: ${d.expectedQuantity} → ${d.receivedQuantity} — ${d.reason}',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.error,
                  fontSize: 12 * scale,
                ),
              ),
            ),
        ],
      ],
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
                      // Line items fetched from GET /api/orders/{id}.
                      BlocBuilder<OrderDetailBloc, OrderDetailState>(
                        builder: (context, state) => FeyamListSection(
                          header: 'Artículos',
                          children: _cupertinoOrderItemsChildren(state),
                        ),
                      ),
                      // Final quote fetched from GET /api/orders/{id}/quote,
                      // once an operator has verified the group checkout.
                      // Renders nothing until then — a missing quote is the
                      // normal state for most orders, not an error.
                      BlocBuilder<QuoteBloc, QuoteState>(
                        builder: (context, state) {
                          final quote = state.quote;
                          if (state.status != QuoteStatus.loaded ||
                              quote == null) {
                            return const SizedBox.shrink();
                          }
                          return FeyamListSection(
                            header: 'Cotización final',
                            children: _cupertinoQuoteChildren(context, quote),
                          );
                        },
                      ),
                      // Shipments fetched from GET /api/orders/{id}/shipments,
                      // once the order's purchase group has been executed.
                      // Renders nothing until then (and renders nothing on an
                      // empty list) — no shipments yet is the normal state
                      // for most orders, not an error.
                      BlocBuilder<ShipmentsBloc, ShipmentsState>(
                        builder: (context, state) {
                          if (state.status != ShipmentsStatus.loaded ||
                              state.shipments.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return FeyamListSection(
                            header: 'Envíos',
                            children: _cupertinoShipmentsChildren(
                              state.shipments,
                            ),
                          );
                        },
                      ),
                      // Final package fetched from
                      // GET /api/orders/{id}/final-package, once Venezuela
                      // warehouse staff have physically received the
                      // order's items. Renders nothing until then — no
                      // final package yet is the normal state for most
                      // orders, not an error.
                      BlocBuilder<FinalPackageBloc, FinalPackageState>(
                        builder: (context, state) {
                          final package = state.package;
                          if (state.status != FinalPackageStatus.loaded ||
                              package == null) {
                            return const SizedBox.shrink();
                          }
                          return FeyamListSection(
                            header: 'Recibido en Venezuela',
                            children: _cupertinoFinalPackageChildren(package),
                          );
                        },
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

/// Builds the tiles for the Cupertino "Artículos" section from the
/// GET /api/orders/{id} fetch state.
List<Widget> _cupertinoOrderItemsChildren(OrderDetailState state) {
  switch (state.status) {
    case OrderDetailStatus.initial:
    case OrderDetailStatus.loading:
      return const <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CupertinoActivityIndicator()),
        ),
      ];
    case OrderDetailStatus.failure:
      return const <Widget>[
        FeyamListTile(
          title: Text(
            'No pudimos cargar los artículos del pedido.',
            style: TextStyle(fontSize: 14, color: kFeyamLabelSec),
          ),
          chevron: false,
          isLast: true,
        ),
      ];
    case OrderDetailStatus.loaded:
      final detail = state.detail;
      if (detail == null) {
        return const <Widget>[SizedBox.shrink()];
      }

      final tiles = <Widget>[
        FeyamListTile(
          title: const Text('Enviado'),
          detail: Text(_formatSubmittedAt(detail.submittedAt)),
          chevron: false,
        ),
        FeyamListTile(
          title: const Text('Estado del pedido'),
          detail: Text(detail.status),
          chevron: false,
        ),
      ];

      // Hardcoded Spanish, matching this Cupertino section's existing
      // convention (it doesn't thread AppLocalizations through, unlike the
      // Material variant's _waitingGroupMessage).
      if (detail.status == 'WaitingGroup') {
        final storeNames = detail.lines
            .map((line) => line.storeName)
            .whereType<String>()
            .where((name) => name.isNotEmpty)
            .toSet();
        final suffix = storeNames.isEmpty ? '' : ' (${storeNames.join(', ')})';
        tiles.add(
          FeyamListTile(
            title: Text(
              'Tu pedido está esperando agruparse con otros pedidos de la misma tienda para ahorrar en el envío.$suffix',
              style: const TextStyle(fontSize: 13, color: kFeyamLabelSec),
            ),
            chevron: false,
            isLast: detail.lines.isEmpty,
          ),
        );
      }

      if (detail.lines.isEmpty) {
        if (detail.status != 'WaitingGroup') {
          tiles.add(
            const FeyamListTile(
              title: Text(
                'No hay artículos para mostrar.',
                style: TextStyle(fontSize: 14, color: kFeyamLabelSec),
              ),
              chevron: false,
              isLast: true,
            ),
          );
        }
        return tiles;
      }

      for (var i = 0; i < detail.lines.length; i++) {
        final line = detail.lines[i];
        final subtitleParts = <String>[
          if (line.variant != null && line.variant!.isNotEmpty)
            line.variant!,
          if (line.storeName != null && line.storeName!.isNotEmpty)
            line.storeName!,
        ];
        tiles.add(
          FeyamListTile(
            title: Text(line.productTitle),
            subtitle: subtitleParts.isEmpty
                ? null
                : Text(subtitleParts.join(' · ')),
            detail: Text(
              '×${line.quantity}  ${line.currencyCode} ${line.unitPrice.toStringAsFixed(2)}',
            ),
            chevron: false,
            isLast: i == detail.lines.length - 1,
          ),
        );
      }
      return tiles;
  }
}

/// Builds the tiles for the Cupertino "Cotización final" section from an
/// already-loaded [QuoteEntity]. Hardcoded Spanish, matching this
/// screen's existing Cupertino convention (it doesn't thread
/// AppLocalizations through, unlike the Material variant).
List<Widget> _cupertinoQuoteChildren(BuildContext context, QuoteEntity quote) {
  String money(double amount) =>
      '${quote.currencyCode} ${amount.toStringAsFixed(2)}';

  final expiringSoon = _isQuoteExpiringSoon(quote.expiresAt);
  final payable = quote.status != 'Paid';

  return <Widget>[
    FeyamListTile(
      title: const Text('Costo en tienda'),
      detail: Text(money(quote.allocatedRetailerCost)),
      chevron: false,
    ),
    FeyamListTile(
      title: const Text('Comisión Feyam'),
      detail: Text(money(quote.feyamFee)),
      chevron: false,
    ),
    FeyamListTile(
      title: const Text('Envío nacional'),
      detail: Text(money(quote.nationalLogistics)),
      chevron: false,
    ),
    FeyamListTile(
      title: const Text('Envío internacional'),
      detail: Text(money(quote.internationalLogistics)),
      chevron: false,
    ),
    FeyamListTile(
      title: const Text('Impuestos'),
      detail: Text(money(quote.feyamTaxes)),
      chevron: false,
    ),
    FeyamListTile(
      title: const Text('Otros cargos'),
      detail: Text(money(quote.otherExplicitCharges)),
      chevron: false,
    ),
    FeyamListTile(
      title: const Text(
        'Total final',
        style: TextStyle(fontWeight: FontWeight.w700, color: kFeyamTint),
      ),
      detail: Text(
        money(quote.finalCustomerTotal),
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: kFeyamTint,
        ),
      ),
      chevron: false,
    ),
    FeyamListTile(
      title: Text(
        'Válida hasta',
        style: expiringSoon
            ? const TextStyle(fontWeight: FontWeight.w600, color: kFeyamRed)
            : null,
      ),
      leading: expiringSoon
          ? const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 18,
              color: kFeyamRed,
            )
          : null,
      detail: Text(
        _formatExpiresAt(quote.expiresAt),
        style: expiringSoon
            ? const TextStyle(fontWeight: FontWeight.w700, color: kFeyamRed)
            : null,
      ),
      chevron: false,
      isLast: !payable,
    ),
    if (payable)
      FeyamListTile(
        title: const Text(
          'Pagar cotización',
          style: TextStyle(fontWeight: FontWeight.w600, color: kFeyamTint),
        ),
        onTap: () async {
          await Navigator.of(context).push(
            AdaptivePlatform.pageRoute<void>(
              context: context,
              builder: (_) => QuotePaymentScreen(orderId: quote.orderId),
            ),
          );
          // Whether the user paid, saw there was nothing to pay, or just
          // backed out, re-fetch so the section reflects the current status
          // rather than requiring a manual pull-to-refresh.
          if (context.mounted) {
            context.read<QuoteBloc>().add(
              QuoteRequested(orderId: quote.orderId),
            );
          }
        },
        isLast: true,
      ),
  ];
}

/// Localized (hardcoded Spanish, matching this Cupertino section's existing
/// convention) label for a [ShipmentEntity.status] raw backend value.
String _cupertinoShipmentStatusLabel(String status) {
  switch (status) {
    case 'AwaitingTracking':
      return 'Esperando número de guía';
    case 'InTransit':
      return 'En tránsito';
    case 'Delivered':
      return 'Entregado';
    case 'Exception':
      return 'Incidencia';
    default:
      return status;
  }
}

/// Color for a shipment status, following this Cupertino section's existing
/// plain-colored-text convention (e.g. the quote's "Válida hasta" row)
/// rather than a badge widget.
Color _cupertinoShipmentStatusColor(String status) {
  switch (status) {
    case 'InTransit':
      return kFeyamTeal;
    case 'Delivered':
      return kFeyamGreen;
    case 'Exception':
      return kFeyamRed;
    default:
      return kFeyamLabelSec;
  }
}

/// Builds the tiles for the Cupertino "Envíos" section from an already-loaded
/// list of [ShipmentEntity]. Hardcoded Spanish, matching this screen's
/// existing Cupertino convention.
List<Widget> _cupertinoShipmentsChildren(List<ShipmentEntity> shipments) {
  final tiles = <Widget>[];

  for (var i = 0; i < shipments.length; i++) {
    final shipment = shipments[i];
    final statusColor = _cupertinoShipmentStatusColor(shipment.status);
    final hasCarrier = shipment.carrier != null && shipment.carrier!.isNotEmpty;

    final subtitleLines = <Widget>[
      if (shipment.trackingNumbers.isNotEmpty)
        Text(shipment.trackingNumbers.join(' · '))
      else
        const Text('Esperando número de guía'),
      if (shipment.status == 'Exception' &&
          shipment.exceptionReason != null &&
          shipment.exceptionReason!.isNotEmpty)
        Text(
          shipment.exceptionReason!,
          style: const TextStyle(color: kFeyamRed, fontWeight: FontWeight.w500),
        ),
    ];

    tiles.add(
      FeyamListTile(
        title: Text(hasCarrier ? shipment.carrier! : 'Envío'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: subtitleLines,
        ),
        detail: Text(
          _cupertinoShipmentStatusLabel(shipment.status),
          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
        ),
        chevron: false,
        isLast: i == shipments.length - 1,
      ),
    );
  }

  return tiles;
}

/// Builds the tiles for the Cupertino "Recibido en Venezuela" section from an
/// already-loaded [FinalPackageEntity]. Hardcoded Spanish, matching this
/// screen's existing Cupertino convention.
List<Widget> _cupertinoFinalPackageChildren(FinalPackageEntity package) {
  final hasDiscrepancies = package.discrepancies.isNotEmpty;

  final tiles = <Widget>[
    FeyamListTile(
      title: const Text('Peso real'),
      detail: Text(
        '${_formatWeightLb(package.actualWeightLb)}${_varianceSuffix(package.variancePct)}',
      ),
      chevron: false,
    ),
    FeyamListTile(
      title: const Text('Peso estimado'),
      detail: Text(_formatWeightLb(package.estimatedWeightLb)),
      chevron: false,
      isLast: !hasDiscrepancies,
    ),
  ];

  if (hasDiscrepancies) {
    tiles.add(
      const FeyamListTile(
        title: Text(
          'Discrepancias',
          style: TextStyle(fontWeight: FontWeight.w600, color: kFeyamRed),
        ),
        leading: Icon(
          CupertinoIcons.exclamationmark_triangle_fill,
          size: 18,
          color: kFeyamRed,
        ),
        chevron: false,
      ),
    );
    for (var i = 0; i < package.discrepancies.length; i++) {
      final d = package.discrepancies[i];
      tiles.add(
        FeyamListTile(
          title: Text(
            '${d.productTitle}: ${d.expectedQuantity} → ${d.receivedQuantity}',
            style: const TextStyle(fontSize: 13),
          ),
          subtitle: Text(
            d.reason,
            style: const TextStyle(color: kFeyamRed),
          ),
          chevron: false,
          isLast: i == package.discrepancies.length - 1,
        ),
      );
    }
  }

  return tiles;
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
