import 'package:equatable/equatable.dart';

/// A single product line within a [FinalPackageEntity], as actually found by
/// Venezuela warehouse staff — as opposed to an order line, which reflects
/// what the client ordered.
class FinalPackageItemEntity extends Equatable {
  const FinalPackageItemEntity({
    required this.productTitle,
    this.variant,
    required this.expectedQuantity,
    required this.receivedQuantity,
  });

  final String productTitle;
  final String? variant;
  final int expectedQuantity;
  final int receivedQuantity;

  @override
  List<Object?> get props => [
        productTitle,
        variant,
        expectedQuantity,
        receivedQuantity,
      ];
}

/// A single explicitly-recorded quantity mismatch within a
/// [FinalPackageEntity]. Unlike [FinalPackageItemEntity] (which can itself
/// carry a differing expected/received quantity without this ever being
/// created), this only exists when a warehouse worker has deliberately
/// flagged the mismatch with a reason — see `FinalPackage.RecordDiscrepancy`
/// on the backend.
class PackageDiscrepancyEntity extends Equatable {
  const PackageDiscrepancyEntity({
    required this.productTitle,
    required this.expectedQuantity,
    required this.receivedQuantity,
    required this.reason,
    required this.recordedAt,
  });

  final String productTitle;
  final int expectedQuantity;
  final int receivedQuantity;
  final String reason;
  final DateTime recordedAt;

  @override
  List<Object?> get props => [
        productTitle,
        expectedQuantity,
        receivedQuantity,
        reason,
        recordedAt,
      ];
}

/// The final, sorted package built from warehouse receiving in Venezuela for
/// a single order, fetched from `GET /api/orders/{id}/final-package` once the
/// order's items have physically arrived and been received — a late-stage
/// status most orders won't have reached, so most orders have no final
/// package yet (represented as `null`, not this entity).
class FinalPackageEntity extends Equatable {
  const FinalPackageEntity({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.purchaseGroupId,
    this.shipmentId,
    required this.contents,
    required this.discrepancies,
    this.actualWeightLb,
    this.actualLengthIn,
    this.actualWidthIn,
    this.actualHeightIn,
    required this.weightLocked,
    this.weightOverrideReason,
    this.weightOverriddenByUserId,
    this.weightOverriddenAt,
    required this.receivedByUserId,
    this.receivedByName,
    required this.receivedAt,
    required this.status,
    this.estimatedWeightLb,
    this.varianceLb,
    this.variancePct,
  });

  final String id;
  final String orderId;
  final String customerId;
  final String purchaseGroupId;

  /// Best-effort record of which shipment this package was primarily sorted
  /// from — never a hard structural link (a shipment can mix items belonging
  /// to several different clients). `null` when unrecorded.
  final String? shipmentId;

  final List<FinalPackageItemEntity> contents;

  /// Explicitly-flagged quantity mismatches. Empty is the normal case — a
  /// mismatched [FinalPackageItemEntity] quantity alone doesn't populate
  /// this; only a deliberate discrepancy record does.
  final List<PackageDiscrepancyEntity> discrepancies;

  final double? actualWeightLb;
  final double? actualLengthIn;
  final double? actualWidthIn;
  final double? actualHeightIn;

  /// `true` once a weight has been recorded — from then on, only an explicit
  /// override (never a silent re-entry) can change it.
  final bool weightLocked;
  final String? weightOverrideReason;
  final String? weightOverriddenByUserId;
  final DateTime? weightOverriddenAt;

  final String receivedByUserId;
  final String? receivedByName;
  final DateTime receivedAt;

  /// Raw final-package status from the backend (`Received` |
  /// `RequiresReview`). A plain string, not an enum, mirroring
  /// `ShipmentEntity.status`/`QuoteEntity.status`'s existing convention.
  final String status;

  /// Computed at read time by the backend from the order's own per-line
  /// weight estimate — never a value stored on the package itself.
  final double? estimatedWeightLb;

  /// `actualWeightLb - estimatedWeightLb`. `null` whenever `actualWeightLb`
  /// hasn't been recorded yet.
  final double? varianceLb;

  /// `varianceLb / estimatedWeightLb * 100`. `null` whenever `varianceLb` is
  /// `null` or `estimatedWeightLb` is `0` (nothing to express a percentage
  /// against).
  final double? variancePct;

  @override
  List<Object?> get props => [
        id,
        orderId,
        customerId,
        purchaseGroupId,
        shipmentId,
        contents,
        discrepancies,
        actualWeightLb,
        actualLengthIn,
        actualWidthIn,
        actualHeightIn,
        weightLocked,
        weightOverrideReason,
        weightOverriddenByUserId,
        weightOverriddenAt,
        receivedByUserId,
        receivedByName,
        receivedAt,
        status,
        estimatedWeightLb,
        varianceLb,
        variancePct,
      ];
}
