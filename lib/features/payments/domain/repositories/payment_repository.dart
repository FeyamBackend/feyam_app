import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/entities/payment_status_entity.dart';

abstract class PaymentRepository {
  /// Crea el pago/PaymentIntent del carrito activo del usuario, con envío a
  /// [addressId] (dirección de envío elegida).
  Future<CheckoutSessionEntity> createCheckout(String addressId);

  /// Consulta el estado de un pago para confirmar el procesamiento del webhook.
  Future<PaymentStatusEntity> getPaymentStatus(String paymentId);
}
