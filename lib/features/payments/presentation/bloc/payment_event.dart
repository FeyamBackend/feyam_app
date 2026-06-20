import 'package:equatable/equatable.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Inicia el flujo completo de checkout: crea el pago en el backend,
/// presenta el PaymentSheet de Stripe y confirma el resultado.
final class PaymentCheckoutRequested extends PaymentEvent {
  const PaymentCheckoutRequested();
}
