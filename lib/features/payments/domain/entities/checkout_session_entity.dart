import 'package:equatable/equatable.dart';

/// Datos que devuelve `POST /api/payments/checkout` y que necesita
/// flutter_stripe PaymentSheet para cobrar el carrito activo.
class CheckoutSessionEntity extends Equatable {
  const CheckoutSessionEntity({
    required this.paymentId,
    required this.paymentIntentClientSecret,
    required this.ephemeralKeySecret,
    required this.stripeCustomerId,
    required this.publishableKey,
    required this.chargedAmount,
    required this.currencyCode,
  });

  final String paymentId;
  final String paymentIntentClientSecret;
  final String ephemeralKeySecret;
  final String stripeCustomerId;
  final String publishableKey;
  final double chargedAmount;
  final String currencyCode;

  @override
  List<Object> get props => [
        paymentId,
        paymentIntentClientSecret,
        ephemeralKeySecret,
        stripeCustomerId,
        publishableKey,
        chargedAmount,
        currencyCode,
      ];
}
