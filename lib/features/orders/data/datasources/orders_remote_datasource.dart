import 'dart:convert';

import 'package:feyam/features/orders/data/models/recent_order_model.dart';
import 'package:http/http.dart' as http;

class OrdersUnauthorizedException implements Exception {
  const OrdersUnauthorizedException();
}

class OrdersServerException implements Exception {
  const OrdersServerException(this.statusCode);

  final int statusCode;
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
}
