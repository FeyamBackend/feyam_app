import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';

class RecentOrderModel extends RecentOrderEntity {
  const RecentOrderModel({
    required super.orderId,
    required super.title,
    required super.itemCount,
    required super.status,
    required super.estimatedTotal,
    super.confirmedTotal,
    required super.currencyCode,
    required super.createdDate,
    super.chargedAmount,
    super.financialStatus,
    super.imageUrl,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) {
    return RecentOrderModel(
      orderId: json['orderId'] as String,
      title: json['title'] as String,
      itemCount: json['itemCount'] as int,
      status: json['status'] as String,
      estimatedTotal: (json['estimatedTotal'] as num).toDouble(),
      confirmedTotal: (json['confirmedTotal'] as num?)?.toDouble(),
      currencyCode: json['currencyCode'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      chargedAmount: (json['chargedAmount'] as num?)?.toDouble(),
      financialStatus: json['financialStatus'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
