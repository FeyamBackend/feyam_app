import 'dart:convert';

import 'package:feyam/features/cart/data/models/add_to_cart_request_model.dart';
import 'package:feyam/features/cart/data/models/cart_model.dart';
import 'package:feyam/features/cart/data/models/cart_summary_model.dart';
import 'package:http/http.dart' as http;

class CartUnauthorizedException implements Exception {
  const CartUnauthorizedException();
}

class CartServerException implements Exception {
  const CartServerException(this.statusCode);

  final int statusCode;
}

class CartRemoteDataSource {
  CartRemoteDataSource({
    required http.Client client,
    required String apiBaseUrl,
  })  : _client = client,
        _apiBaseUrl = apiBaseUrl;

  final http.Client _client;
  final String _apiBaseUrl;

  Future<CartSummaryModel> addItem(AddToCartRequestModel request) async {
    final uri = Uri.parse('$_apiBaseUrl/api/cart/items');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 401) {
      throw const CartUnauthorizedException();
    }

    if (response.statusCode != 200) {
      throw CartServerException(response.statusCode);
    }

    return CartSummaryModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<CartModel?> getCart() async {
    final uri = Uri.parse('$_apiBaseUrl/api/cart');

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const CartUnauthorizedException();
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) throw CartServerException(response.statusCode);

    return CartModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<CartModel> removeCartItem(String itemId) async {
    final uri = Uri.parse('$_apiBaseUrl/api/cart/items/$itemId');

    final response = await _client.delete(uri);

    if (response.statusCode == 401) throw const CartUnauthorizedException();
    if (response.statusCode != 200) throw CartServerException(response.statusCode);

    return CartModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<CartModel> updateCartItemQuantity(String itemId, int newQuantity) async {
    final uri = Uri.parse('$_apiBaseUrl/api/cart/items/$itemId/quantity');

    final response = await _client.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newQuantity': newQuantity}),
    );

    if (response.statusCode == 401) throw const CartUnauthorizedException();
    if (response.statusCode != 200) throw CartServerException(response.statusCode);

    return CartModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
