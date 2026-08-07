import 'package:feyam/features/payments/domain/entities/checkout_pricing_entity.dart';

class CheckoutPricingModel extends CheckoutPricingEntity {
  const CheckoutPricingModel({
    required super.productsAmount,
    required super.feyamFee,
    required super.estimatedLogistics,
    required super.total,
    required super.currencyCode,
    required super.itemCount,
  });

  factory CheckoutPricingModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPricingModel(
      productsAmount: (json['productsAmount'] as num).toDouble(),
      feyamFee: (json['feyamFee'] as num).toDouble(),
      estimatedLogistics: (json['estimatedLogistics'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      itemCount: json['itemCount'] as int,
    );
  }
}
