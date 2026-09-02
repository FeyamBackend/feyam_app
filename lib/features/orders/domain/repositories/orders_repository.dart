import 'package:feyam/features/orders/domain/entities/final_package_entity.dart';
import 'package:feyam/features/orders/domain/entities/order_detail_entity.dart';
import 'package:feyam/features/orders/domain/entities/quote_entity.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/domain/entities/shipment_entity.dart';

abstract class OrdersRepository {
  Future<List<RecentOrderEntity>> getRecentOrders({int take});

  Future<OrderDetailEntity> getOrderDetail({required String orderId});

  /// Returns `null` when no quote exists yet for this order — the normal
  /// case for any order that hasn't reached the `CheckoutVerified` stage.
  Future<QuoteEntity?> getOrderQuote({required String orderId});

  /// Always returns a list — empty when this order has no shipments yet
  /// (the normal case for most orders, until its purchase group has been
  /// executed).
  Future<List<ShipmentEntity>> getOrderShipments({required String orderId});

  /// Returns `null` when no final package has been recorded yet for this
  /// order — the normal case for most orders, until Venezuela warehouse
  /// staff have physically received its items.
  Future<FinalPackageEntity?> getOrderFinalPackage({required String orderId});
}
