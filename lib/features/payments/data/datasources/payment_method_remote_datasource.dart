import 'dart:convert';

import 'package:feyam/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:feyam/features/payments/data/models/payment_method_model.dart';
import 'package:feyam/features/payments/data/models/payment_method_setup_model.dart';
import 'package:http/http.dart' as http;

class PaymentMethodNotFoundException implements Exception {
  const PaymentMethodNotFoundException();
}

class PaymentMethodRemoteDataSource {
  PaymentMethodRemoteDataSource({
    required http.Client client,
    required String apiBaseUrl,
  }) : _client = client,
       _apiBaseUrl = apiBaseUrl;

  final http.Client _client;
  final String _apiBaseUrl;

  /// GET /api/payment-methods — tarjetas guardadas del usuario.
  Future<List<PaymentMethodModel>> list() async {
    final uri = Uri.parse('$_apiBaseUrl/api/payment-methods');

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const PaymentUnauthorizedException();
    if (response.statusCode != 200) {
      throw PaymentServerException(response.statusCode);
    }

    final raw = jsonDecode(response.body) as List<dynamic>;
    return raw
        .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/payment-methods/setup-intent — inicia el alta de una tarjeta nueva.
  Future<PaymentMethodSetupModel> createSetupIntent() async {
    final uri = Uri.parse('$_apiBaseUrl/api/payment-methods/setup-intent');

    final response = await _client.post(uri);

    if (response.statusCode == 401) throw const PaymentUnauthorizedException();
    if (response.statusCode != 200) {
      throw PaymentServerException(response.statusCode);
    }

    return PaymentMethodSetupModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// DELETE /api/payment-methods/{id}
  Future<void> delete(String id) async {
    final uri = Uri.parse('$_apiBaseUrl/api/payment-methods/$id');

    final response = await _client.delete(uri);

    if (response.statusCode == 401) throw const PaymentUnauthorizedException();
    if (response.statusCode == 404) throw const PaymentMethodNotFoundException();
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw PaymentServerException(response.statusCode);
    }
  }

  /// POST /api/payment-methods/{id}/default
  Future<void> setDefault(String id) async {
    final uri = Uri.parse('$_apiBaseUrl/api/payment-methods/$id/default');

    final response = await _client.post(uri);

    if (response.statusCode == 401) throw const PaymentUnauthorizedException();
    if (response.statusCode == 404) throw const PaymentMethodNotFoundException();
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw PaymentServerException(response.statusCode);
    }
  }
}
