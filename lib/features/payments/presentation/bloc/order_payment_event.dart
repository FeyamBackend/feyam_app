import 'package:equatable/equatable.dart';

sealed class OrderPaymentEvent extends Equatable {
  const OrderPaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Inicia el cobro del monto confirmado por un price_confirmator para
/// [orderId]: crea el PaymentIntent, presenta el PaymentSheet de Stripe, y
/// confirma el resultado releyendo el detalle de la orden hasta que su
/// status pase a "Paid".
final class OrderPaymentRequested extends OrderPaymentEvent {
  const OrderPaymentRequested(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
