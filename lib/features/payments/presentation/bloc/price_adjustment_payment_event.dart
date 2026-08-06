import 'package:equatable/equatable.dart';

sealed class PriceAdjustmentPaymentEvent extends Equatable {
  const PriceAdjustmentPaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Inicia el cobro de la diferencia de precio para [purchaseId]: crea el pago
/// en el backend, presenta el PaymentSheet de Stripe y confirma el resultado.
final class PriceAdjustmentPaymentRequested
    extends PriceAdjustmentPaymentEvent {
  const PriceAdjustmentPaymentRequested(this.purchaseId);

  final String purchaseId;

  @override
  List<Object?> get props => [purchaseId];
}
