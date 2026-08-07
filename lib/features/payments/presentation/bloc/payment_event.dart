import 'package:equatable/equatable.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Pide el desglose autoritativo del total (productos + fee Feyam + logística
/// estimada) del carrito activo, para mostrarlo antes de pagar.
final class PaymentPricingRequested extends PaymentEvent {
  const PaymentPricingRequested();
}

/// Inicia el flujo completo de checkout: crea el pago en el backend,
/// presenta el PaymentSheet de Stripe y confirma el resultado.
/// [addressId] es la dirección de envío elegida por el usuario.
final class PaymentCheckoutRequested extends PaymentEvent {
  const PaymentCheckoutRequested(this.addressId);

  final String addressId;

  @override
  List<Object?> get props => [addressId];
}
