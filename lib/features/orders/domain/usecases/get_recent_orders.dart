import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';

class GetRecentOrdersUseCase {
  const GetRecentOrdersUseCase(this.repository);

  final OrdersRepository repository;

  Future<List<RecentOrderEntity>> call({int take = 5}) =>
      repository.getRecentOrders(take: take);
}
