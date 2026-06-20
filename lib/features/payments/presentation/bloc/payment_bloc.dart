import 'package:feyam/core/payments/stripe_payment_service.dart';
import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/domain/usecases/create_checkout.dart';
import 'package:feyam/features/payments/domain/usecases/get_payment_status.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_event.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({
    required CreateCheckoutUseCase createCheckoutUseCase,
    required GetPaymentStatusUseCase getPaymentStatusUseCase,
    required StripePaymentService stripeService,
  })  : _createCheckout = createCheckoutUseCase,
        _getPaymentStatus = getPaymentStatusUseCase,
        _stripeService = stripeService,
        super(const PaymentState()) {
    on<PaymentCheckoutRequested>(_onCheckoutRequested);
  }

  final CreateCheckoutUseCase _createCheckout;
  final GetPaymentStatusUseCase _getPaymentStatus;
  final StripePaymentService _stripeService;

  /// Tiempo máximo de espera a que el webhook marque el pago como confirmado.
  static const _pollInterval = Duration(seconds: 2);
  static const _pollMaxAttempts = 15; // ~30s

  Future<void> _onCheckoutRequested(
    PaymentCheckoutRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.processing));

    // 1. Crear el pago + PaymentIntent en el backend (total autoritativo).
    final CheckoutSessionEntity session;
    try {
      session = await _createCheckout();
    } on PaymentFailure catch (failure) {
      emit(state.copyWith(status: PaymentStatus.failure, failure: failure));
      return;
    }

    // 2. Cobrar con el PaymentSheet de Stripe.
    try {
      await _stripeService.presentPaymentSheet(session);
    } on StripePaymentCancelled {
      emit(state.copyWith(status: PaymentStatus.cancelled));
      return;
    } on StripePaymentException {
      emit(state.copyWith(
        status: PaymentStatus.failure,
        failure: const PaymentFailure(PaymentFailureCode.unknown),
      ));
      return;
    }

    // 3. El cobro ya se realizó. Confirmamos contra el backend que el webhook
    //    procesó el pago. La fuente de verdad es el webhook: si no logramos
    //    confirmar (demora o error de red), NO es un error para el usuario:
    //    quedará pendiente y se le informará luego.
    emit(state.copyWith(status: PaymentStatus.verifying));

    try {
      for (var attempt = 0; attempt < _pollMaxAttempts; attempt++) {
        final payment = await _getPaymentStatus(session.paymentId);
        if (payment.isSucceeded) {
          emit(state.copyWith(status: PaymentStatus.success));
          return;
        }
        if (payment.isFailed) {
          emit(state.copyWith(
            status: PaymentStatus.failure,
            failure: const PaymentFailure(PaymentFailureCode.serverError),
          ));
          return;
        }
        await Future<void>.delayed(_pollInterval);
      }
    } on PaymentFailure {
      // No pudimos consultar el estado, pero el pago ya fue cobrado.
      emit(state.copyWith(status: PaymentStatus.pendingConfirmation));
      return;
    }

    // Timeout: el cobro se realizó pero el webhook aún no llegó.
    emit(state.copyWith(status: PaymentStatus.pendingConfirmation));
  }
}
