import 'package:equatable/equatable.dart';
import 'package:feyam/features/orders/domain/entities/shipment_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';

enum ShipmentsStatus { initial, loading, loaded, failure }

class ShipmentsState extends Equatable {
  const ShipmentsState({
    this.status = ShipmentsStatus.initial,
    this.shipments = const <ShipmentEntity>[],
    this.failure,
  });

  final ShipmentsStatus status;

  /// The fetched shipments once `status` is [ShipmentsStatus.loaded]. An
  /// empty list while loaded means "no shipments exist yet for this order"
  /// — the normal case for most orders, until their purchase group has been
  /// executed — and is distinct from [ShipmentsStatus.failure], which is a
  /// real error.
  final List<ShipmentEntity> shipments;
  final OrdersFailure? failure;

  ShipmentsState copyWith({
    ShipmentsStatus? status,
    List<ShipmentEntity>? shipments,
    OrdersFailure? failure,
  }) {
    return ShipmentsState(
      status: status ?? this.status,
      shipments: shipments ?? this.shipments,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, shipments, failure];
}
