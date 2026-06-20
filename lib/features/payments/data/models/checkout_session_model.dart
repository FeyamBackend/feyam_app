import 'package:feyam/features/payments/domain/entities/checkout_session_entity.dart';

class CheckoutSessionModel extends CheckoutSessionEntity {
  const CheckoutSessionModel({
    required super.paymentId,
    required super.paymentIntentClientSecret,
    required super.ephemeralKeySecret,
    required super.stripeCustomerId,
    required super.publishableKey,
    required super.chargedAmount,
    required super.currencyCode,
  });

  factory CheckoutSessionModel.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionModel(
      paymentId: json['paymentId'] as String,
      paymentIntentClientSecret: json['paymentIntentClientSecret'] as String,
      ephemeralKeySecret: json['ephemeralKeySecret'] as String,
      stripeCustomerId: json['stripeCustomerId'] as String,
      publishableKey: json['publishableKey'] as String,
      chargedAmount: (json['chargedAmount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
    );
  }
}
