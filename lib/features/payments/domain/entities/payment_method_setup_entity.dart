import 'package:equatable/equatable.dart';

/// Datos que devuelve `POST /api/payment-methods/setup-intent` para que el
/// cliente capture y guarde una tarjeta nueva sin cobrar nada. [provider] es
/// el discriminador de pasarela ("stripe" hoy) que el registry de gateways
/// usa para resolver qué SDK invocar — el seam para sumar otra pasarela sin
/// tocar el bloc ni la pantalla.
class PaymentMethodSetupEntity extends Equatable {
  const PaymentMethodSetupEntity({
    required this.provider,
    required this.setupIntentClientSecret,
    required this.ephemeralKeySecret,
    required this.stripeCustomerId,
    required this.publishableKey,
  });

  final String provider;
  final String setupIntentClientSecret;
  final String ephemeralKeySecret;
  final String stripeCustomerId;
  final String publishableKey;

  @override
  List<Object?> get props => [
    provider,
    setupIntentClientSecret,
    ephemeralKeySecret,
    stripeCustomerId,
    publishableKey,
  ];
}
