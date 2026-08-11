import 'package:feyam/core/payments/payment_method_gateway.dart';
import 'package:feyam/core/payments/stripe_payment_method_gateway.dart';

/// Lanzada cuando el backend devuelve un `provider` para el que no hay
/// [PaymentMethodGateway] registrado en el cliente.
class UnsupportedPaymentProviderException implements Exception {
  const UnsupportedPaymentProviderException(this.provider);

  final String provider;
}

/// Resuelve qué [PaymentMethodGateway] usar según el `provider` que devuelve
/// el backend. Para sumar una pasarela nueva: implementar [PaymentMethodGateway]
/// y agregarla al mapa acá — el bloc y la pantalla de métodos de pago no cambian.
class PaymentMethodGatewayRegistry {
  PaymentMethodGatewayRegistry({Map<String, PaymentMethodGateway>? gateways})
    : _gateways = gateways ?? {'stripe': StripePaymentMethodGateway()};

  final Map<String, PaymentMethodGateway> _gateways;

  PaymentMethodGateway resolve(String provider) {
    final gateway = _gateways[provider];
    if (gateway == null) {
      throw UnsupportedPaymentProviderException(provider);
    }
    return gateway;
  }
}
