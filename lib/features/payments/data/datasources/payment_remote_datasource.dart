import 'dart:convert';

import 'package:feyam/features/payments/data/models/checkout_pricing_model.dart';
import 'package:feyam/features/payments/data/models/checkout_session_model.dart';
import 'package:feyam/features/payments/data/models/payment_status_model.dart';
import 'package:feyam/features/payments/data/models/price_adjustment_status_model.dart';
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
  }) : _client = client,
       _apiBaseUrl = apiBaseUrl;

  final http.Client _client;
  final String _apiBaseUrl;

  /// GET /api/payments/checkout/pricing — desglose autoritativo (productos + fee Feyam +
  /// logística estimada = total) del carrito activo, sin crear ningún cobro. Es el mismo
  /// cálculo que usa createCheckout, así que el total mostrado antes de pagar nunca difiere
  /// del monto real cobrado.
  Future<CheckoutPricingModel> getCheckoutPricing() async {
    final uri = Uri.parse('$_apiBaseUrl/api/payments/checkout/pricing');

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const PaymentUnauthorizedException();
    if (response.statusCode != 200) {
      throw PaymentServerException(response.statusCode);
    }

    return CheckoutPricingModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// POST /api/payments/checkout — el carrito activo y el usuario se resuelven
  /// server-side desde el token; el body lleva la dirección de envío elegida.
  Future<CheckoutSessionModel> createCheckout(String addressId) async {
    final uri = Uri.parse('$_apiBaseUrl/api/payments/checkout');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'addressId': addressId}),
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

  /// POST /api/payments/price-adjustments — starts the top-up charge for a purchase whose
  /// verified price exceeded the original estimate. Returns the same shape as checkout.
  Future<CheckoutSessionModel> createPriceAdjustmentPayment(
    String purchaseId,
  ) async {
    final uri = Uri.parse('$_apiBaseUrl/api/payments/price-adjustments');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'purchaseId': purchaseId}),
    );

    if (response.statusCode == 401) throw const PaymentUnauthorizedException();
    if (response.statusCode != 200) {
      throw PaymentServerException(response.statusCode);
    }

    return CheckoutSessionModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// GET /api/payments/price-adjustments/{id} — polled after the PaymentSheet closes.
  Future<PriceAdjustmentStatusModel> getPriceAdjustmentPaymentStatus(
    String chargeId,
  ) async {
    final uri = Uri.parse(
      '$_apiBaseUrl/api/payments/price-adjustments/$chargeId',
    );

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const PaymentUnauthorizedException();
    if (response.statusCode != 200) {
      throw PaymentServerException(response.statusCode);
    }

    return PriceAdjustmentStatusModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
