import 'package:equatable/equatable.dart';
import 'package:feyam/features/payments/domain/entities/checkout_pricing_entity.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';

enum CheckoutPricingStatus {
  /// Aún no se pidió el desglose de precio.
  initial,

  /// Consultando GET /api/payments/checkout/pricing.
  loading,

  /// Desglose disponible en [PaymentState.pricing].
  loaded,

  /// Falló la consulta; ver [PaymentState.pricingFailure].
  failure,
}

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
    this.pricingStatus = CheckoutPricingStatus.initial,
    this.pricing,
    this.pricingFailure,
  });

  final PaymentStatus status;
  final PaymentFailure? failure;

  final CheckoutPricingStatus pricingStatus;
  final CheckoutPricingEntity? pricing;
  final PaymentFailure? pricingFailure;

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentFailure? failure,
    CheckoutPricingStatus? pricingStatus,
    CheckoutPricingEntity? pricing,
    PaymentFailure? pricingFailure,
  }) {
    return PaymentState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
      pricingStatus: pricingStatus ?? this.pricingStatus,
      pricing: pricing ?? this.pricing,
      pricingFailure: pricingFailure ?? this.pricingFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    failure,
    pricingStatus,
    pricing,
    pricingFailure,
  ];
}
