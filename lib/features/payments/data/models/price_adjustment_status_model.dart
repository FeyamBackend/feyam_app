import 'package:feyam/features/payments/domain/entities/price_adjustment_status_entity.dart';

class PriceAdjustmentStatusModel extends PriceAdjustmentStatusEntity {
  const PriceAdjustmentStatusModel({
    required super.id,
    required super.purchaseId,
    required super.status,
    required super.amount,
    required super.currencyCode,
  });

  factory PriceAdjustmentStatusModel.fromJson(Map<String, dynamic> json) {
    return PriceAdjustmentStatusModel(
      id: json['id'] as String,
      purchaseId: json['purchaseId'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
    );
  }
}
