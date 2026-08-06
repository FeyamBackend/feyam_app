import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/entities/payment_status_entity.dart';
import 'package:feyam/features/payments/domain/entities/price_adjustment_status_entity.dart';

abstract class PaymentRepository {
  /// Crea el pago/PaymentIntent del carrito activo del usuario, con envío a
  /// [addressId] (dirección de envío elegida).
  Future<CheckoutSessionEntity> createCheckout(String addressId);

  /// Consulta el estado de un pago para confirmar el procesamiento del webhook.
  Future<PaymentStatusEntity> getPaymentStatus(String paymentId);

  /// Inicia el cobro de la diferencia de precio para una compra ajustada por
  /// encima de lo estimado originalmente.
  Future<CheckoutSessionEntity> createPriceAdjustmentPayment(String purchaseId);

  /// Consulta el estado de un cobro de diferencia de precio.
  Future<PriceAdjustmentStatusEntity> getPriceAdjustmentPaymentStatus(
    String chargeId,
  );
}
