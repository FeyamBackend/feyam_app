import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/widgets/feyam_hero_header.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/presentation/bloc/order_payment_bloc.dart';
import 'package:feyam/features/payments/presentation/bloc/order_payment_event.dart';
import 'package:feyam/features/payments/presentation/bloc/order_payment_state.dart';
import 'package:feyam/features/payments/presentation/widgets/payment_result_card.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Charges the customer the exact amount confirmed for [orderId] — a single,
/// full, immediate-capture charge. Reached from a "Pay now" CTA on the order
/// detail screen (retrying a checkout payment that was abandoned or failed),
/// from a "your order's price is confirmed" push notification for legacy
/// orders that still went through manual price review, or as a deep link
/// from either.
class OrderPaymentScreen extends StatelessWidget {
  const OrderPaymentScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderPaymentBloc>(),
      child: _OrderPaymentView(orderId: orderId),
    );
  }
}

class _OrderPaymentView extends StatelessWidget {
  const _OrderPaymentView({required this.orderId});

  final String orderId;

  String _failureMessage(AppLocalizations l10n, PaymentFailure? failure) {
    switch (failure?.code) {
      case PaymentFailureCode.networkError:
        return l10n.paymentErrorNetwork;
      case PaymentFailureCode.sessionExpired:
      case PaymentFailureCode.unauthorized:
        return l10n.paymentErrorSession;
      case PaymentFailureCode.cancelled:
        return l10n.paymentCancelled;
      case PaymentFailureCode.serverError:
      case PaymentFailureCode.notFound:
      case PaymentFailureCode.unknown:
      case null:
        return l10n.paymentErrorGeneric;
    }
  }

  String _formatCurrency(double amount, String currencyCode) =>
      '$currencyCode ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: <Widget>[
          FeyamHeroHeader(showBackButton: true, title: l10n.orderPaymentTitle),
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(decoration: TextDecoration.none),
              child: BlocBuilder<OrderPaymentBloc, OrderPaymentState>(
                builder: (context, state) {
                  final busy =
                      state.status == OrderPaymentStatus.processing ||
                      state.status == OrderPaymentStatus.verifying;

                  Widget content;
                  switch (state.status) {
                    case OrderPaymentStatus.success:
                      content = PaymentResultCard(
                        icon: Icons.check_circle_rounded,
                        iconColor: colors.secondary,
                        iconBg: colors.secondaryContainer,
                        title: l10n.orderPaymentSuccessTitle,
                        body: l10n.orderPaymentSuccessBody,
                        actionLabel: l10n.orderPaymentDoneButton,
                        onAction: () => Navigator.of(context).pop(),
                      );
                    case OrderPaymentStatus.pendingConfirmation:
                      content = PaymentResultCard(
                        icon: Icons.hourglass_top_rounded,
                        iconColor: colors.primary,
                        iconBg: colors.primaryContainer,
                        title: l10n.orderPaymentPendingTitle,
                        body: l10n.orderPaymentPendingBody,
                        actionLabel: l10n.orderPaymentDoneButton,
                        onAction: () => Navigator.of(context).pop(),
                      );
                    case OrderPaymentStatus.failure:
                      content = PaymentResultCard(
                        icon: Icons.error_outline_rounded,
                        iconColor: colors.error,
                        iconBg: colors.errorContainer,
                        title: l10n.orderPaymentFailureTitle,
                        body: _failureMessage(l10n, state.failure),
                        actionLabel: l10n.orderPaymentRetryButton,
                        primaryAction: false,
                        onAction: () => context.read<OrderPaymentBloc>().add(
                          OrderPaymentRequested(orderId),
                        ),
                      );
                    case OrderPaymentStatus.initial:
                    case OrderPaymentStatus.processing:
                    case OrderPaymentStatus.verifying:
                    case OrderPaymentStatus.cancelled:
                      content = _PayPrompt(
                        busy: busy,
                        verifying: state.status == OrderPaymentStatus.verifying,
                        amountLabel:
                            state.amount != null && state.currencyCode != null
                            ? _formatCurrency(
                                state.amount!,
                                state.currencyCode!,
                              )
                            : null,
                        onPay: busy
                            ? null
                            : () => context.read<OrderPaymentBloc>().add(
                                OrderPaymentRequested(orderId),
                              ),
                      );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: content),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayPrompt extends StatelessWidget {
  const _PayPrompt({
    required this.busy,
    required this.verifying,
    required this.amountLabel,
    required this.onPay,
  });

  final bool busy;
  final bool verifying;
  final String? amountLabel;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primaryContainer,
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            size: 40,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.orderPaymentIntro,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        if (amountLabel != null) ...[
          const SizedBox(height: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: <Widget>[
                  Text(
                    l10n.orderPaymentAmountLabel,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    amountLabel!,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: onPay,
            style: FilledButton.styleFrom(
              backgroundColor: colors.secondary,
              foregroundColor: colors.onSecondary,
              shape: const StadiumBorder(),
            ),
            icon: busy
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onSecondary,
                    ),
                  )
                : const Icon(Icons.lock_rounded),
            label: Text(
              busy
                  ? (verifying
                        ? l10n.checkoutVerifying
                        : l10n.checkoutProcessing)
                  : l10n.orderPaymentPayButton,
            ),
          ),
        ),
      ],
    );
  }
}
