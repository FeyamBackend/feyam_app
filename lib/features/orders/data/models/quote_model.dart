import 'package:feyam/features/orders/domain/entities/quote_entity.dart';

class QuoteModel extends QuoteEntity {
  const QuoteModel({
    required super.orderId,
    required super.allocatedRetailerCost,
    required super.feeByQuantity,
    required super.valueSurcharge,
    required super.storeSurcharge,
    required super.feyamFee,
    required super.nationalLogistics,
    required super.internationalLogistics,
    required super.feyamTaxes,
    required super.otherExplicitCharges,
    required super.finalCustomerTotal,
    required super.currencyCode,
    required super.status,
    required super.createdAt,
    required super.expiresAt,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      orderId: json['orderId'] as String,
      allocatedRetailerCost: (json['allocatedRetailerCost'] as num)
          .toDouble(),
      feeByQuantity: (json['feeByQuantity'] as num).toDouble(),
      valueSurcharge: (json['valueSurcharge'] as num).toDouble(),
      storeSurcharge: (json['storeSurcharge'] as num).toDouble(),
      feyamFee: (json['feyamFee'] as num).toDouble(),
      nationalLogistics: (json['nationalLogistics'] as num).toDouble(),
      internationalLogistics: (json['internationalLogistics'] as num)
          .toDouble(),
      feyamTaxes: (json['feyamTaxes'] as num).toDouble(),
      otherExplicitCharges: (json['otherExplicitCharges'] as num).toDouble(),
      finalCustomerTotal: (json['finalCustomerTotal'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
