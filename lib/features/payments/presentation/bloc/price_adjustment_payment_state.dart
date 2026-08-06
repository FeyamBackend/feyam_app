import 'package:equatable/equatable.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';

enum PriceAdjustmentPaymentStatus {
  /// Estado inicial, antes de iniciar el cobro.
  initial,

  /// Creando el cobro en el backend y abriendo el PaymentSheet.
  processing,

  /// PaymentSheet completado; confirmando el resultado contra el backend.
  verifying,

  /// Cobro confirmado por el backend (webhook procesado).
  success,

  /// El cobro se realizó pero el backend aún no lo confirmó (webhook demorado
  /// o no pudimos consultar el estado). No es un error: se informará luego.
  pendingConfirmation,

  /// El usuario cerró el PaymentSheet sin pagar.
  cancelled,

  /// Falló la creación, el cobro o la confirmación.
  failure,
}

class PriceAdjustmentPaymentState extends Equatable {
  const PriceAdjustmentPaymentState({
    this.status = PriceAdjustmentPaymentStatus.initial,
    this.amount,
    this.currencyCode,
    this.failure,
  });

  final PriceAdjustmentPaymentStatus status;
  final double? amount;
  final String? currencyCode;
  final PaymentFailure? failure;

  PriceAdjustmentPaymentState copyWith({
    PriceAdjustmentPaymentStatus? status,
    double? amount,
    String? currencyCode,
    PaymentFailure? failure,
  }) {
    return PriceAdjustmentPaymentState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, amount, currencyCode, failure];
}
