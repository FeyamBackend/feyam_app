import 'package:feyam/features/payments/domain/entities/payment_method_setup_entity.dart';

class PaymentMethodSetupModel extends PaymentMethodSetupEntity {
  const PaymentMethodSetupModel({
    required super.provider,
    required super.setupIntentClientSecret,
    required super.ephemeralKeySecret,
    required super.stripeCustomerId,
    required super.publishableKey,
  });

  factory PaymentMethodSetupModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSetupModel(
      provider: json['provider'] as String,
      setupIntentClientSecret: json['setupIntentClientSecret'] as String,
      ephemeralKeySecret: json['ephemeralKeySecret'] as String,
      stripeCustomerId: json['stripeCustomerId'] as String,
      publishableKey: json['publishableKey'] as String,
    );
  }
}
