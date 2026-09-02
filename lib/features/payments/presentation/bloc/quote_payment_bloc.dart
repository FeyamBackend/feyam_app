import 'package:feyam/core/payments/stripe_payment_service.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/usecases/get_order_quote.dart';
import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/domain/usecases/pay_order_quote.dart';
import 'package:feyam/features/payments/presentation/bloc/quote_payment_event.dart';
import 'package:feyam/features/payments/presentation/bloc/quote_payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuotePaymentBloc extends Bloc<QuotePaymentEvent, QuotePaymentState> {
  QuotePaymentBloc({
    required PayOrderQuoteUseCase payOrderQuoteUseCase,
    required GetOrderQuoteUseCase getOrderQuoteUseCase,
    required StripePaymentService stripeService,
    Duration pollInterval = _defaultPollInterval,
    int pollMaxAttempts = _defaultPollMaxAttempts,
  }) : _payOrderQuote = payOrderQuoteUseCase,
       _getOrderQuote = getOrderQuoteUseCase,
       _stripeService = stripeService,
       _pollInterval = pollInterval,
       _pollMaxAttempts = pollMaxAttempts,
       super(const QuotePaymentState()) {
    on<QuotePaymentRequested>(_onRequested);
  }

  final PayOrderQuoteUseCase _payOrderQuote;
  final GetOrderQuoteUseCase _getOrderQuote;
  final StripePaymentService _stripeService;
  final Duration _pollInterval;
  final int _pollMaxAttempts;

  // No hay un endpoint dedicado de "estado del pago de cotización" (a
  // diferencia de price-adjustments): se relee GET /api/orders/{id}/quote a
  // través del mismo GetOrderQuoteUseCase que usa QuoteBloc, con el mismo
  // intervalo/intentos que PriceAdjustmentPaymentBloc. Exposed as
  // overridable constructor params (defaulting to those same values) purely
  // so tests can exercise the poll-timeout path without a real ~30s wait.
  static const _defaultPollInterval = Duration(seconds: 2);
  static const _defaultPollMaxAttempts = 15; // ~30s

  Future<void> _onRequested(
    QuotePaymentRequested event,
    Emitter<QuotePaymentState> emit,
  ) async {
    emit(state.copyWith(status: QuotePaymentStatus.processing));

    final CheckoutSessionEntity? payment;
    try {
      payment = await _payOrderQuote(event.orderId);
    } on PaymentFailure catch (failure) {
      emit(
        state.copyWith(status: QuotePaymentStatus.failure, failure: failure),
      );
      return;
    }

    if (payment == null) {
      // requiresPayment: false — el pago del checkout ya cubre el total
      // verificado. Es un resultado normal y esperado, no un caso límite:
      // se llega directo a success sin tocar Stripe.
      emit(
        state.copyWith(
          status: QuotePaymentStatus.success,
          paymentRequired: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        amount: payment.chargedAmount,
        currencyCode: payment.currencyCode,
        paymentRequired: true,
      ),
    );

    try {
      await _stripeService.presentPaymentSheet(payment);
    } on StripePaymentCancelled {
      emit(state.copyWith(status: QuotePaymentStatus.cancelled));
      return;
    } on StripePaymentException {
      emit(
        state.copyWith(
          status: QuotePaymentStatus.failure,
          failure: const PaymentFailure(PaymentFailureCode.unknown),
        ),
      );
      return;
    }

    emit(state.copyWith(status: QuotePaymentStatus.verifying));

    try {
      for (var attempt = 0; attempt < _pollMaxAttempts; attempt++) {
        final quote = await _getOrderQuote(orderId: event.orderId);
        if (quote?.status == 'Paid') {
          emit(state.copyWith(status: QuotePaymentStatus.success));
          return;
        }
        await Future<void>.delayed(_pollInterval);
      }
    } on OrdersFailure {
      emit(state.copyWith(status: QuotePaymentStatus.pendingConfirmation));
      return;
    }

    emit(state.copyWith(status: QuotePaymentStatus.pendingConfirmation));
  }
}
