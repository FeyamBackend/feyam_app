import 'package:feyam/core/payments/stripe_payment_service.dart';
import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/domain/usecases/create_price_adjustment_payment.dart';
import 'package:feyam/features/payments/domain/usecases/get_price_adjustment_payment_status.dart';
import 'package:feyam/features/payments/presentation/bloc/price_adjustment_payment_event.dart';
import 'package:feyam/features/payments/presentation/bloc/price_adjustment_payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PriceAdjustmentPaymentBloc
    extends Bloc<PriceAdjustmentPaymentEvent, PriceAdjustmentPaymentState> {
  PriceAdjustmentPaymentBloc({
    required CreatePriceAdjustmentPaymentUseCase
    createPriceAdjustmentPaymentUseCase,
    required GetPriceAdjustmentPaymentStatusUseCase
    getPriceAdjustmentPaymentStatusUseCase,
    required StripePaymentService stripeService,
  }) : _createPayment = createPriceAdjustmentPaymentUseCase,
       _getStatus = getPriceAdjustmentPaymentStatusUseCase,
       _stripeService = stripeService,
       super(const PriceAdjustmentPaymentState()) {
    on<PriceAdjustmentPaymentRequested>(_onRequested);
  }

  final CreatePriceAdjustmentPaymentUseCase _createPayment;
  final GetPriceAdjustmentPaymentStatusUseCase _getStatus;
  final StripePaymentService _stripeService;

  static const _pollInterval = Duration(seconds: 2);
  static const _pollMaxAttempts = 15; // ~30s

  Future<void> _onRequested(
    PriceAdjustmentPaymentRequested event,
    Emitter<PriceAdjustmentPaymentState> emit,
  ) async {
    emit(state.copyWith(status: PriceAdjustmentPaymentStatus.processing));

    final CheckoutSessionEntity session;
    try {
      session = await _createPayment(event.purchaseId);
    } on PaymentFailure catch (failure) {
      emit(
        state.copyWith(
          status: PriceAdjustmentPaymentStatus.failure,
          failure: failure,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        amount: session.chargedAmount,
        currencyCode: session.currencyCode,
      ),
    );

    try {
      await _stripeService.presentPaymentSheet(session);
    } on StripePaymentCancelled {
      emit(state.copyWith(status: PriceAdjustmentPaymentStatus.cancelled));
      return;
    } on StripePaymentException {
      emit(
        state.copyWith(
          status: PriceAdjustmentPaymentStatus.failure,
          failure: const PaymentFailure(PaymentFailureCode.unknown),
        ),
      );
      return;
    }

    emit(state.copyWith(status: PriceAdjustmentPaymentStatus.verifying));

    try {
      for (var attempt = 0; attempt < _pollMaxAttempts; attempt++) {
        final charge = await _getStatus(session.paymentId);
        if (charge.isSucceeded) {
          emit(state.copyWith(status: PriceAdjustmentPaymentStatus.success));
          return;
        }
        if (charge.isFailed) {
          emit(
            state.copyWith(
              status: PriceAdjustmentPaymentStatus.failure,
              failure: const PaymentFailure(PaymentFailureCode.serverError),
            ),
          );
          return;
        }
        await Future<void>.delayed(_pollInterval);
      }
    } on PaymentFailure {
      emit(
        state.copyWith(
          status: PriceAdjustmentPaymentStatus.pendingConfirmation,
        ),
      );
      return;
    }

    emit(
      state.copyWith(status: PriceAdjustmentPaymentStatus.pendingConfirmation),
    );
  }
}
