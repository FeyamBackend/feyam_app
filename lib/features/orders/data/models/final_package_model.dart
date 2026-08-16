import 'package:feyam/features/orders/domain/entities/final_package_entity.dart';

class FinalPackageItemModel extends FinalPackageItemEntity {
  const FinalPackageItemModel({
    required super.productTitle,
    super.variant,
    required super.expectedQuantity,
    required super.receivedQuantity,
  });

  factory FinalPackageItemModel.fromJson(Map<String, dynamic> json) {
    return FinalPackageItemModel(
      productTitle: json['productTitle'] as String,
      variant: json['variant'] as String?,
      expectedQuantity: json['expectedQuantity'] as int,
      receivedQuantity: json['receivedQuantity'] as int,
    );
  }
}

class PackageDiscrepancyModel extends PackageDiscrepancyEntity {
  const PackageDiscrepancyModel({
    required super.productTitle,
    required super.expectedQuantity,
    required super.receivedQuantity,
    required super.reason,
    required super.recordedAt,
  });

  factory PackageDiscrepancyModel.fromJson(Map<String, dynamic> json) {
    return PackageDiscrepancyModel(
      productTitle: json['productTitle'] as String,
      expectedQuantity: json['expectedQuantity'] as int,
      receivedQuantity: json['receivedQuantity'] as int,
      reason: json['reason'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }
}

class FinalPackageModel extends FinalPackageEntity {
  const FinalPackageModel({
    required super.id,
    required super.orderId,
    required super.customerId,
    required super.purchaseGroupId,
    super.shipmentId,
    required super.contents,
    required super.discrepancies,
    super.actualWeightLb,
    super.actualLengthIn,
    super.actualWidthIn,
    super.actualHeightIn,
    required super.weightLocked,
    super.weightOverrideReason,
    super.weightOverriddenByUserId,
    super.weightOverriddenAt,
    required super.receivedByUserId,
    super.receivedByName,
    required super.receivedAt,
    required super.status,
    super.estimatedWeightLb,
    super.varianceLb,
    super.variancePct,
  });

  factory FinalPackageModel.fromJson(Map<String, dynamic> json) {
    return FinalPackageModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      customerId: json['customerId'] as String,
      purchaseGroupId: json['purchaseGroupId'] as String,
      shipmentId: json['shipmentId'] as String?,
      contents: (json['contents'] as List<dynamic>)
          .map((e) => FinalPackageItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      discrepancies: (json['discrepancies'] as List<dynamic>)
          .map((e) => PackageDiscrepancyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      actualWeightLb: (json['actualWeightLb'] as num?)?.toDouble(),
      actualLengthIn: (json['actualLengthIn'] as num?)?.toDouble(),
      actualWidthIn: (json['actualWidthIn'] as num?)?.toDouble(),
      actualHeightIn: (json['actualHeightIn'] as num?)?.toDouble(),
      weightLocked: json['weightLocked'] as bool,
      weightOverrideReason: json['weightOverrideReason'] as String?,
      weightOverriddenByUserId: json['weightOverriddenByUserId'] as String?,
      weightOverriddenAt: json['weightOverriddenAt'] == null
          ? null
          : DateTime.parse(json['weightOverriddenAt'] as String),
      receivedByUserId: json['receivedByUserId'] as String,
      receivedByName: json['receivedByName'] as String?,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      status: json['status'] as String,
      estimatedWeightLb: (json['estimatedWeightLb'] as num?)?.toDouble(),
      varianceLb: (json['varianceLb'] as num?)?.toDouble(),
      variancePct: (json['variancePct'] as num?)?.toDouble(),
    );
  }
}
