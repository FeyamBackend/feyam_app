import 'package:equatable/equatable.dart';

sealed class QuotePaymentEvent extends Equatable {
  const QuotePaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Inicia el cobro (si hace falta) de la diferencia entre lo pagado al
/// checkout y el `finalCustomerTotal` verificado de la cotización de
/// [orderId]: consulta al backend, presenta el PaymentSheet de Stripe sólo si
/// corresponde, y confirma el resultado.
final class QuotePaymentRequested extends QuotePaymentEvent {
  const QuotePaymentRequested(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
