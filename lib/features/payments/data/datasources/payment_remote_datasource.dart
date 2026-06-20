import 'dart:convert';

import 'package:feyam/features/payments/data/models/checkout_session_model.dart';
import 'package:feyam/features/payments/data/models/payment_status_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PaymentUnauthorizedException implements Exception {
  const PaymentUnauthorizedException();
}

class PaymentServerException implements Exception {
  const PaymentServerException(this.statusCode);

  final int statusCode;
}

class PaymentRemoteDataSource {
  PaymentRemoteDataSource({
    required http.Client client,
    required FlutterSecureStorage secureStorage,
    required String apiBaseUrl,
  })  : _client = client,
        _secureStorage = secureStorage,
        _apiBaseUrl = apiBaseUrl;

  static const String _accessTokenKey = 'access_token';

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;
  final String _apiBaseUrl;

  /// POST /api/payments/checkout — sin body; el carrito activo y el usuario
  /// se resuelven server-side desde el token.
  Future<CheckoutSessionModel> createCheckout() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    final uri = Uri.parse('$_apiBaseUrl/api/payments/checkout');

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) throw const PaymentUnauthorizedException();
    if (response.statusCode != 200) {
      throw PaymentServerException(response.statusCode);
    }

    return CheckoutSessionModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// GET /api/payments/{id} — estado del pago para confirmar el webhook.
  Future<PaymentStatusModel> getPaymentStatus(String paymentId) async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    final uri = Uri.parse('$_apiBaseUrl/api/payments/$paymentId');

    final response = await _client.get(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) throw const PaymentUnauthorizedException();
    if (response.statusCode != 200) {
      throw PaymentServerException(response.statusCode);
    }

    return PaymentStatusModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
