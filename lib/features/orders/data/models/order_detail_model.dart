import 'package:feyam/features/orders/domain/entities/order_detail_entity.dart';

class OrderLineModel extends OrderLineEntity {
  const OrderLineModel({
    required super.productTitle,
    super.variant,
    required super.quantity,
    required super.unitPrice,
    required super.currencyCode,
    super.storeName,
  });

  factory OrderLineModel.fromJson(Map<String, dynamic> json) {
    return OrderLineModel(
      productTitle: json['productTitle'] as String,
      variant: json['variant'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      storeName: json['storeName'] as String?,
    );
  }
}

class OrderDetailModel extends OrderDetailEntity {
  const OrderDetailModel({
    required super.id,
    required super.status,
    required super.submittedAt,
    required super.lines,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? const <dynamic>[];
    return OrderDetailModel(
      id: json['id'] as String,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      lines: rawLines
          .map((e) => OrderLineModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
