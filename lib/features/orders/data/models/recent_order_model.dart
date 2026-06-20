import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';

class RecentOrderModel extends RecentOrderEntity {
  const RecentOrderModel({
    required super.orderId,
    required super.title,
    required super.itemCount,
    required super.chargedAmount,
    required super.currencyCode,
    required super.financialStatus,
    required super.createdDate,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) {
    return RecentOrderModel(
      orderId: json['orderId'] as String,
      title: json['title'] as String,
      itemCount: json['itemCount'] as int,
      chargedAmount: (json['chargedAmount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      financialStatus: json['financialStatus'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }
}
