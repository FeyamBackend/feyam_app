import 'package:equatable/equatable.dart';

/// A single shipment for an order, fetched from `GET
/// /api/orders/{id}/shipments` once the order's purchase group has been
/// executed — a late-stage status most orders won't have reached, so most
/// orders have no shipments yet (an empty list, not an error).
class ShipmentEntity extends Equatable {
  const ShipmentEntity({
    required this.id,
    required this.purchaseGroupId,
    required this.trackingNumbers,
    required this.status,
    this.carrier,
    required this.createdAt,
    this.exceptionReason,
  });

  final String id;
  final String purchaseGroupId;

  /// A shipment can accumulate more than one tracking number over time, or
  /// have none yet (the normal case while `status` is `AwaitingTracking`).
  final List<String> trackingNumbers;

  /// Raw shipment status from the backend (`AwaitingTracking`, `InTransit`,
  /// `Delivered`, `Exception`). A plain string, not an enum, mirroring
  /// `QuoteEntity.status`/`OrderDetailEntity.status`'s existing convention.
  final String status;
  final String? carrier;
  final DateTime createdAt;

  /// Set when `status` is `Exception`; otherwise `null`.
  final String? exceptionReason;

  @override
  List<Object?> get props => [
        id,
        purchaseGroupId,
        trackingNumbers,
        status,
        carrier,
        createdAt,
        exceptionReason,
      ];
}
