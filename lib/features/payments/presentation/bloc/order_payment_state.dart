import 'package:equatable/equatable.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';

enum OrderPaymentStatus {
  /// Estado inicial, antes de iniciar el cobro.
  initial,

  /// Creando el PaymentIntent y presentando el PaymentSheet.
  processing,

  /// PaymentSheet completado; confirmando el resultado contra el backend
  /// (releyendo la orden hasta que su status pase a "Paid").
  verifying,

  /// La orden ya está pagada.
  success,

  /// El cobro se realizó pero el backend aún no confirmó que la orden pasó a
  /// "Paid" (webhook demorado o no pudimos consultarla). No es un error: se
  /// informará luego.
  pendingConfirmation,

  /// El usuario cerró el PaymentSheet sin pagar.
  cancelled,

  /// Falló la creación del cobro o la confirmación.
  failure,
}

class OrderPaymentState extends Equatable {
  const OrderPaymentState({
    this.status = OrderPaymentStatus.initial,
    this.amount,
    this.currencyCode,
    this.failure,
  });

  final OrderPaymentStatus status;
  final double? amount;
  final String? currencyCode;
  final PaymentFailure? failure;

  OrderPaymentState copyWith({
    OrderPaymentStatus? status,
    double? amount,
    String? currencyCode,
    PaymentFailure? failure,
  }) {
    return OrderPaymentState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, amount, currencyCode, failure];
}
