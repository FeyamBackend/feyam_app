import 'dart:io';

import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';
import 'package:feyam/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/domain/failures/orders_failure.dart';
import 'package:feyam/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl({
    required OrdersRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
  })  : _remoteDataSource = remoteDataSource,
        _authRepository = authRepository;

  final OrdersRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  @override
  Future<List<RecentOrderEntity>> getRecentOrders({int take = 5}) async {
    try {
      return await _remoteDataSource.getRecentOrders(take: take);
    } on OrdersUnauthorizedException {
      try {
        await _authRepository.refreshAccessToken();
      } on AuthTokenExpiredException {
        throw const OrdersFailure(OrdersFailureCode.sessionExpired);
      }
      // Retry: OrdersRemoteDataSource re-reads the access_token from SecureStorage.
      try {
        return await _remoteDataSource.getRecentOrders(take: take);
      } on OrdersUnauthorizedException {
        throw const OrdersFailure(OrdersFailureCode.sessionExpired);
      } on OrdersServerException {
        throw const OrdersFailure(OrdersFailureCode.serverError);
      } on SocketException {
        throw const OrdersFailure(OrdersFailureCode.networkError);
      }
    } on OrdersServerException {
      throw const OrdersFailure(OrdersFailureCode.serverError);
    } on SocketException {
      throw const OrdersFailure(OrdersFailureCode.networkError);
    } catch (_) {
      throw const OrdersFailure(OrdersFailureCode.unknown);
    }
  }
}
