import 'package:feyam/features/payments/domain/entities/checkout_pricing_entity.dart';
import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:feyam/features/payments/domain/entities/payment_status_entity.dart';
import 'package:feyam/features/payments/domain/entities/price_adjustment_status_entity.dart';

abstract class PaymentRepository {
  /// Desglose autoritativo del total del carrito activo (productos + fee +
  /// logística estimada), previo a iniciar el checkout.
  Future<CheckoutPricingEntity> getCheckoutPricing();

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

  /// Inicia (o determina que no hace falta) el cobro de la diferencia entre lo
  /// pagado al momento del checkout del carrito y el `finalCustomerTotal`
  /// verificado de la cotización del pedido. Devuelve `null` cuando el backend
  /// reporta `requiresPayment: false` — el pago del checkout ya cubre la
  /// cotización, no es un error.
  Future<CheckoutSessionEntity?> payOrderQuote(String orderId);
}
