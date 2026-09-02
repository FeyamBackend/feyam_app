import 'package:feyam/features/orders/domain/entities/order_detail_entity.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';

class GetOrderDetailUseCase {
  const GetOrderDetailUseCase(this.repository);

  final OrdersRepository repository;

  Future<OrderDetailEntity> call({required String orderId}) =>
      repository.getOrderDetail(orderId: orderId);
}
