import 'package:feyam/core/payments/stripe_payment_service.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/usecases/get_order_detail.dart';
import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/domain/usecases/pay_confirmed_order.dart';
import 'package:feyam/features/payments/presentation/bloc/order_payment_event.dart';
import 'package:feyam/features/payments/presentation/bloc/order_payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mirrors QuotePaymentBloc's shape, but simpler: there is no "requiresPayment:
/// false" short-circuit here — a confirmed order always needs the customer to
/// pay the full amount, once.
class OrderPaymentBloc extends Bloc<OrderPaymentEvent, OrderPaymentState> {
  OrderPaymentBloc({
    required PayConfirmedOrderUseCase payConfirmedOrderUseCase,
    required GetOrderDetailUseCase getOrderDetailUseCase,
    required StripePaymentService stripeService,
    Duration pollInterval = _defaultPollInterval,
    int pollMaxAttempts = _defaultPollMaxAttempts,
  }) : _payConfirmedOrder = payConfirmedOrderUseCase,
       _getOrderDetail = getOrderDetailUseCase,
       _stripeService = stripeService,
       _pollInterval = pollInterval,
       _pollMaxAttempts = pollMaxAttempts,
       super(const OrderPaymentState()) {
    on<OrderPaymentRequested>(_onRequested);
  }

  final PayConfirmedOrderUseCase _payConfirmedOrder;
  final GetOrderDetailUseCase _getOrderDetail;
  final StripePaymentService _stripeService;
  final Duration _pollInterval;
  final int _pollMaxAttempts;

  static const _defaultPollInterval = Duration(seconds: 2);
  static const _defaultPollMaxAttempts = 15; // ~30s

  Future<void> _onRequested(
    OrderPaymentRequested event,
    Emitter<OrderPaymentState> emit,
  ) async {
    emit(state.copyWith(status: OrderPaymentStatus.processing));

    final CheckoutSessionEntity payment;
    try {
      payment = await _payConfirmedOrder(event.orderId);
    } on PaymentFailure catch (failure) {
      emit(
        state.copyWith(status: OrderPaymentStatus.failure, failure: failure),
      );
      return;
    }

    emit(
      state.copyWith(
        amount: payment.chargedAmount,
        currencyCode: payment.currencyCode,
      ),
    );

    try {
      await _stripeService.presentPaymentSheet(payment);
    } on StripePaymentCancelled {
      emit(state.copyWith(status: OrderPaymentStatus.cancelled));
      return;
    } on StripePaymentException {
      emit(
        state.copyWith(
          status: OrderPaymentStatus.failure,
          failure: const PaymentFailure(PaymentFailureCode.unknown),
        ),
      );
      return;
    }

    emit(state.copyWith(status: OrderPaymentStatus.verifying));

    try {
      for (var attempt = 0; attempt < _pollMaxAttempts; attempt++) {
        final detail = await _getOrderDetail(orderId: event.orderId);
        if (detail.status == 'Paid') {
          emit(state.copyWith(status: OrderPaymentStatus.success));
          return;
        }
        await Future<void>.delayed(_pollInterval);
      }
    } on OrdersFailure {
      emit(state.copyWith(status: OrderPaymentStatus.pendingConfirmation));
      return;
    }

    emit(state.copyWith(status: OrderPaymentStatus.pendingConfirmation));
  }
}
