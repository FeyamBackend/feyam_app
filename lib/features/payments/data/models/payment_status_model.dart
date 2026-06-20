import 'package:feyam/features/payments/domain/entities/payment_status_entity.dart';

class PaymentStatusModel extends PaymentStatusEntity {
  const PaymentStatusModel({
    required super.id,
    required super.cartId,
    required super.status,
    required super.chargedAmount,
    required super.currencyCode,
    required super.productsAmount,
    required super.feyamFee,
    required super.estimatedLogistics,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      id: json['id'] as String,
      cartId: json['cartId'] as String,
      status: json['status'] as String,
      chargedAmount: (json['chargedAmount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      productsAmount: (json['productsAmount'] as num).toDouble(),
      feyamFee: (json['feyamFee'] as num).toDouble(),
      estimatedLogistics: (json['estimatedLogistics'] as num).toDouble(),
    );
  }
}
