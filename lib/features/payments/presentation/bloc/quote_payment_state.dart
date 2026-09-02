import 'package:equatable/equatable.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';

enum QuotePaymentStatus {
  /// Estado inicial, antes de iniciar el cobro.
  initial,

  /// Consultando al backend si hace falta cobrar, y abriendo el PaymentSheet
  /// si corresponde.
  processing,

  /// PaymentSheet completado; confirmando el resultado contra el backend
  /// (releyendo la cotización hasta que su status pase a "Paid").
  verifying,

  /// La cotización ya está saldada: o el backend confirmó el cobro recién
  /// hecho, o directamente no hacía falta pagar nada (el pago del checkout ya
  /// cubría el total verificado). [paymentRequired] distingue ambos casos
  /// para el mensaje que se le muestra al usuario.
  success,

  /// El cobro se realizó pero el backend aún no confirmó que la cotización
  /// pasó a "Paid" (webhook demorado o no pudimos consultarla). No es un
  /// error: se informará luego.
  pendingConfirmation,

  /// El usuario cerró el PaymentSheet sin pagar.
  cancelled,

  /// Falló la consulta, el cobro o la confirmación.
  failure,
}

class QuotePaymentState extends Equatable {
  const QuotePaymentState({
    this.status = QuotePaymentStatus.initial,
    this.amount,
    this.currencyCode,
    this.paymentRequired,
    this.failure,
  });

  final QuotePaymentStatus status;
  final double? amount;
  final String? currencyCode;

  /// Si hizo falta pasar por Stripe para llegar a `success`/`cancelled`/
  /// `pendingConfirmation`. `null` mientras no se sabe todavía; `false`
  /// cuando el backend respondió `requiresPayment: false` (el pago del
  /// checkout ya cubre la cotización) y se llegó a `success` sin tocar
  /// Stripe.
  final bool? paymentRequired;
  final PaymentFailure? failure;

  QuotePaymentState copyWith({
    QuotePaymentStatus? status,
    double? amount,
    String? currencyCode,
    bool? paymentRequired,
    PaymentFailure? failure,
  }) {
    return QuotePaymentState(
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      paymentRequired: paymentRequired ?? this.paymentRequired,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    amount,
    currencyCode,
    paymentRequired,
    failure,
  ];
}
