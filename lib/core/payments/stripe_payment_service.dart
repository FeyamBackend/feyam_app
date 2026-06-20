import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Lanzada cuando el usuario cierra el PaymentSheet sin completar el pago.
class StripePaymentCancelled implements Exception {
  const StripePaymentCancelled();
}

/// Lanzada ante cualquier otro error de Stripe al presentar el sheet.
class StripePaymentException implements Exception {
  const StripePaymentException(this.message);

  final String message;
}

/// Envuelve flutter_stripe para mantener el [PaymentBloc] testeable y
/// desacoplado del SDK nativo.
class StripePaymentService {
  /// Inicializa y presenta el PaymentSheet con los datos del backend.
  /// Retorna normalmente si el cobro fue confirmado por Stripe; lanza
  /// [StripePaymentCancelled] si el usuario cancela o [StripePaymentException]
  /// ante un error.
  Future<void> presentPaymentSheet(CheckoutSessionEntity session) async {
    // El publishable key viene en la respuesta de checkout.
    Stripe.publishableKey = session.publishableKey;
    await Stripe.instance.applySettings();

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Feyam',
          paymentIntentClientSecret: session.paymentIntentClientSecret,
          customerId: session.stripeCustomerId,
          customerEphemeralKeySecret: session.ephemeralKeySecret,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw const StripePaymentCancelled();
      }
      throw StripePaymentException(e.error.localizedMessage ?? e.error.message ?? 'Stripe error');
    }
  }
}
