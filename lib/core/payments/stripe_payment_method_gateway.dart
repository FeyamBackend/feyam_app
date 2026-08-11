import 'package:feyam/core/payments/payment_method_gateway.dart';
import 'package:feyam/features/payments/domain/entities/payment_method_setup_entity.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Implementación de [PaymentMethodGateway] con el PaymentSheet de Stripe:
/// mismo widget nativo que ya usa el checkout ([StripePaymentService]), pero
/// inicializado con un SetupIntent en vez de un PaymentIntent — captura y
/// guarda la tarjeta sin cobrar nada.
class StripePaymentMethodGateway implements PaymentMethodGateway {
  @override
  Future<void> collectAndSave(PaymentMethodSetupEntity setup) async {
    Stripe.publishableKey = setup.publishableKey;
    await Stripe.instance.applySettings();

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Feyam',
          setupIntentClientSecret: setup.setupIntentClientSecret,
          customerId: setup.stripeCustomerId,
          customerEphemeralKeySecret: setup.ephemeralKeySecret,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw const PaymentMethodCollectionCancelled();
      }
      throw PaymentMethodCollectionException(
        e.error.localizedMessage ?? e.error.message ?? 'Stripe error',
      );
    }
  }
}
