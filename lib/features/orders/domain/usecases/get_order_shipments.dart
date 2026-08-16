import 'package:feyam/features/orders/domain/entities/shipment_entity.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';

class GetOrderShipmentsUseCase {
  const GetOrderShipmentsUseCase(this.repository);

  final OrdersRepository repository;

  /// Always returns a list — empty when this order has no shipments yet.
  Future<List<ShipmentEntity>> call({required String orderId}) =>
      repository.getOrderShipments(orderId: orderId);
}
