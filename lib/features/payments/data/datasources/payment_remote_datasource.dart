import 'dart:convert';

import 'package:feyam/features/payments/data/models/checkout_session_model.dart';
import 'package:feyam/features/payments/data/models/payment_status_model.dart';
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
    required String apiBaseUrl,
  })  : _client = client,
        _apiBaseUrl = apiBaseUrl;

  final http.Client _client;
  final String _apiBaseUrl;

  /// POST /api/payments/checkout — sin body; el carrito activo y el usuario
  /// se resuelven server-side desde el token.
  Future<CheckoutSessionModel> createCheckout() async {
    final uri = Uri.parse('$_apiBaseUrl/api/payments/checkout');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
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
    final uri = Uri.parse('$_apiBaseUrl/api/payments/$paymentId');

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const PaymentUnauthorizedException();
    if (response.statusCode != 200) {
      throw PaymentServerException(response.statusCode);
    }

    return PaymentStatusModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
