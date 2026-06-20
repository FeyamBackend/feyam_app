import 'package:equatable/equatable.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';

enum PaymentStatus {
  /// Estado inicial, antes de iniciar el checkout.
  initial,

  /// Creando el pago en el backend y abriendo el PaymentSheet.
  processing,

  /// PaymentSheet completado; confirmando el resultado contra el backend.
  verifying,

  /// Pago confirmado por el backend (webhook procesado).
  success,

  /// El cobro se realizó pero el backend aún no lo confirmó (webhook demorado
  /// o no pudimos consultar el estado). No es un error: se informará luego.
  pendingConfirmation,

  /// El usuario cerró el PaymentSheet sin pagar.
  cancelled,

  /// Falló la creación, el cobro o la confirmación.
  failure,
}

class PaymentState extends Equatable {
  const PaymentState({
    this.status = PaymentStatus.initial,
    this.failure,
  });

  final PaymentStatus status;
  final PaymentFailure? failure;

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentFailure? failure,
  }) {
    return PaymentState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, failure];
}
