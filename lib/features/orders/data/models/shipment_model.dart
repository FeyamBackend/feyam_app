import 'package:feyam/features/orders/domain/entities/shipment_entity.dart';

class ShipmentModel extends ShipmentEntity {
  const ShipmentModel({
    required super.id,
    required super.purchaseGroupId,
    required super.trackingNumbers,
    required super.status,
    super.carrier,
    required super.createdAt,
    super.exceptionReason,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] as String,
      purchaseGroupId: json['purchaseGroupId'] as String,
      trackingNumbers: (json['trackingNumbers'] as List<dynamic>)
          .cast<String>(),
      status: json['status'] as String,
      carrier: json['carrier'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      exceptionReason: json['exceptionReason'] as String?,
    );
  }
}
