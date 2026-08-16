import 'dart:io';

import 'package:feyam/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:feyam/features/orders/domain/entities/final_package_entity.dart';
import 'package:feyam/features/orders/domain/entities/order_detail_entity.dart';
import 'package:feyam/features/orders/domain/entities/quote_entity.dart';
import 'package:feyam/features/orders/domain/entities/recent_order_entity.dart';
import 'package:feyam/features/orders/domain/entities/shipment_entity.dart';
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

  @override
  Future<OrderDetailEntity> getOrderDetail({required String orderId}) async {
    // Mismo patrón que getRecentOrders: el refresh/retry de 401 lo maneja
    // AuthenticatedHttpClient, un 401 acá es sesión ya expirada.
    try {
      return await _remoteDataSource.getOrderDetail(orderId: orderId);
    } on OrdersUnauthorizedException {
      throw const OrdersFailure(OrdersFailureCode.sessionExpired);
    } on OrdersOrderNotFoundException {
      throw const OrdersFailure(OrdersFailureCode.notFound);
    } on OrdersServerException {
      throw const OrdersFailure(OrdersFailureCode.serverError);
    } on SocketException {
      throw const OrdersFailure(OrdersFailureCode.networkError);
    } catch (_) {
      throw const OrdersFailure(OrdersFailureCode.unknown);
    }
  }

  @override
  Future<QuoteEntity?> getOrderQuote({required String orderId}) async {
    // Mismo patrón que getOrderDetail. Un 404 acá no es una falla: significa
    // que el pedido todavía no tiene cotización final (el caso normal), así
    // que el datasource devuelve null en vez de lanzar.
    try {
      return await _remoteDataSource.getOrderQuote(orderId: orderId);
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

  @override
  Future<List<ShipmentEntity>> getOrderShipments({
    required String orderId,
  }) async {
    // Mismo patrón que getOrderDetail: acá un 404 sí es una falla real (el
    // pedido no existe o no es del cliente autenticado), a diferencia de
    // getOrderQuote. "Sin envíos todavía" llega como una lista vacía en un
    // 200, no como un 404.
    try {
      return await _remoteDataSource.getOrderShipments(orderId: orderId);
    } on OrdersUnauthorizedException {
      throw const OrdersFailure(OrdersFailureCode.sessionExpired);
    } on OrdersOrderNotFoundException {
      throw const OrdersFailure(OrdersFailureCode.notFound);
    } on OrdersServerException {
      throw const OrdersFailure(OrdersFailureCode.serverError);
    } on SocketException {
      throw const OrdersFailure(OrdersFailureCode.networkError);
    } catch (_) {
      throw const OrdersFailure(OrdersFailureCode.unknown);
    }
  }

  @override
  Future<FinalPackageEntity?> getOrderFinalPackage({
    required String orderId,
  }) async {
    // Mismo patrón que getOrderQuote: un 404 acá no es una falla, ya sea
    // porque el pedido todavía no tiene paquete final registrado (el caso
    // normal) o porque el pedido no existe/no es del cliente autenticado —
    // el backend colapsa ambos casos en el mismo 404, así que el datasource
    // devuelve null en vez de lanzar.
    try {
      return await _remoteDataSource.getOrderFinalPackage(orderId: orderId);
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
