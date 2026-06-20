import 'dart:io';

import 'package:feyam/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl({required OrdersRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  Future<List<RecentOrderEntity>> getRecentOrders({int take = 5}) async {
    // El refresh y el retry de 401 los maneja AuthenticatedHttpClient. Un 401
    // que llegue acá significa que la sesión ya expiró (el logout global lo
    // dispara el cliente vía SessionExpiredNotifier).
    try {
      return await _remoteDataSource.getRecentOrders(take: take);
    } on OrdersUnauthorizedException {
      throw const OrdersFailure(OrdersFailureCode.sessionExpired);
    } on OrdersServerException {
      throw const OrdersFailure(OrdersFailureCode.serverError);
    } on SocketException {
      throw const OrdersFailure(OrdersFailureCode.networkError);
    } catch (_) {
      throw const OrdersFailure(OrdersFailureCode.unknown);
    }
  }
}
