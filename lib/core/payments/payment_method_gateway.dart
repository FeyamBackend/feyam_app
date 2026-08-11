import 'package:feyam/features/payments/domain/entities/payment_method_setup_entity.dart';

/// Lanzada cuando el usuario cierra el flujo de captura sin completar el alta.
class PaymentMethodCollectionCancelled implements Exception {
  const PaymentMethodCollectionCancelled();
}

/// Lanzada ante cualquier otro error de la pasarela al capturar el método.
class PaymentMethodCollectionException implements Exception {
  const PaymentMethodCollectionException(this.message);

  final String message;
}

/// Punto de extensión para sumar otra pasarela de pago sin tocar el bloc ni
/// la pantalla de métodos de pago: cada pasarela implementa esto con su
/// propio SDK y se registra en `PaymentMethodGatewayRegistry`.
abstract class PaymentMethodGateway {
  /// Captura los datos del método de pago con el SDK de la pasarela y lo deja
  /// guardado en el customer. No devuelve nada: el caller siempre recarga la
  /// lista desde el backend después (fuente de verdad).
  Future<void> collectAndSave(PaymentMethodSetupEntity setup);
}
