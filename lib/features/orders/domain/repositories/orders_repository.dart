import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';

abstract class OrdersRepository {
  Future<List<RecentOrderEntity>> getRecentOrders({int take});
}
