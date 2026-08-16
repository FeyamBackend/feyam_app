import 'dart:convert';

import 'package:feyam/features/orders/data/models/final_package_model.dart';
import 'package:feyam/features/orders/data/models/order_detail_model.dart';
import 'package:feyam/features/orders/data/models/quote_model.dart';
import 'package:feyam/features/orders/data/models/recent_order_model.dart';
import 'package:feyam/features/orders/data/models/shipment_model.dart';
import 'package:http/http.dart' as http;

class OrdersUnauthorizedException implements Exception {
  const OrdersUnauthorizedException();
}

class OrdersServerException implements Exception {
  const OrdersServerException(this.statusCode);

  final int statusCode;
}

/// Thrown when `GET /api/orders/{id}` returns 404 — the order doesn't exist
/// or doesn't belong to the caller.
class OrdersOrderNotFoundException implements Exception {
  const OrdersOrderNotFoundException();
}

class OrdersRemoteDataSource {
  OrdersRemoteDataSource({
    required http.Client client,
    required String apiBaseUrl,
  })  : _client = client,
        _apiBaseUrl = apiBaseUrl;

  final http.Client _client;
  final String _apiBaseUrl;

  Future<List<RecentOrderModel>> getRecentOrders({required int take}) async {
    final uri = Uri.parse('$_apiBaseUrl/api/orders/recent?take=$take');

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const OrdersUnauthorizedException();
    if (response.statusCode != 200) throw OrdersServerException(response.statusCode);

    final raw = jsonDecode(response.body) as List<dynamic>;
    return raw
        .map((e) => RecentOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderDetailModel> getOrderDetail({required String orderId}) async {
    final uri = Uri.parse('$_apiBaseUrl/api/orders/$orderId');

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const OrdersUnauthorizedException();
    if (response.statusCode == 404) {
      throw const OrdersOrderNotFoundException();
    }
    if (response.statusCode != 200) throw OrdersServerException(response.statusCode);

    return OrderDetailModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Fetches `GET /api/orders/{id}/quote`. A 404 means no quote has been
  /// produced yet for this order (the normal case for any order that hasn't
  /// reached the `CheckoutVerified` stage) — not an error, so it returns
  /// `null` instead of throwing.
  Future<QuoteModel?> getOrderQuote({required String orderId}) async {
    final uri = Uri.parse('$_apiBaseUrl/api/orders/$orderId/quote');

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const OrdersUnauthorizedException();
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) throw OrdersServerException(response.statusCode);

    return QuoteModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Fetches `GET /api/orders/{id}/shipments`. Unlike `getOrderQuote`, a 404
  /// here means the order itself doesn't exist or isn't the caller's — the
  /// same semantics as `getOrderDetail`'s 404 — not "no shipments yet". A
  /// order with no shipments yet (the normal case for most orders, until
  /// its purchase group has been executed) is represented by a 200 with an
  /// empty array, not a 404.
  Future<List<ShipmentModel>> getOrderShipments({
    required String orderId,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/api/orders/$orderId/shipments');

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const OrdersUnauthorizedException();
    if (response.statusCode == 404) {
      throw const OrdersOrderNotFoundException();
    }
    if (response.statusCode != 200) throw OrdersServerException(response.statusCode);

    final raw = jsonDecode(response.body) as List<dynamic>;
    return raw
        .map((e) => ShipmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches `GET /api/orders/{id}/final-package`. A 404 means either the
  /// order doesn't exist/isn't the caller's, or no final package has been
  /// recorded yet for it (the normal case for most orders, until Venezuela
  /// warehouse staff have physically received its items) — the backend
  /// collapses both into the same 404, mirroring `getOrderQuote`'s "single
  /// resource that may not exist yet" convention, not `getOrderShipments`'s
  /// (a plural resource, where "none yet" is instead an empty 200 list). So,
  /// like `getOrderQuote`, this returns `null` on a 404 rather than throwing.
  Future<FinalPackageModel?> getOrderFinalPackage({
    required String orderId,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/api/orders/$orderId/final-package');

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const OrdersUnauthorizedException();
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) throw OrdersServerException(response.statusCode);

    return FinalPackageModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
