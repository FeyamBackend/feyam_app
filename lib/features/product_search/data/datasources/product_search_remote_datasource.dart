import 'dart:convert';

import 'package:feyam/features/product_search/data/models/product_search_result_model.dart';
import 'package:http/http.dart' as http;

class ProductSearchUnauthorizedException implements Exception {
  const ProductSearchUnauthorizedException();
}

class ProductSearchServerException implements Exception {
  const ProductSearchServerException(this.statusCode);

  final int statusCode;
}

class ProductSearchRemoteDataSource {
  ProductSearchRemoteDataSource({
    required http.Client client,
    required String apiBaseUrl,
  })  : _client = client,
        _apiBaseUrl = apiBaseUrl;

  final http.Client _client;
  final String _apiBaseUrl;

  /// Calls Feyam's own backend, never Zinc directly — the Zinc API key must
  /// stay server-side (Zinc's own docs warn against exposing it client-side).
  Future<ProductSearchResultModel> search({
    required String query,
    String? retailer,
    int page = 1,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/api/products/search').replace(
      queryParameters: {
        'q': query,
        if (retailer != null && retailer.isNotEmpty) 'retailer': retailer,
        'page': '$page',
      },
    );

    final response = await _client.get(uri);

    if (response.statusCode == 401) {
      throw const ProductSearchUnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ProductSearchServerException(response.statusCode);
    }

    return ProductSearchResultModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Resolves a single product's data from a pasted product page URL, via
  /// Feyam's own backend (which in turn calls Zinc's structured per-product
  /// details endpoint) — never a text search against the raw URL string.
  Future<ProductSearchResultModel> lookupByUrl({required String url}) async {
    final uri = Uri.parse('$_apiBaseUrl/api/products/lookup').replace(
      queryParameters: {'url': url},
    );

    final response = await _client.get(uri);

    if (response.statusCode == 401) {
      throw const ProductSearchUnauthorizedException();
    }
    if (response.statusCode != 200) {
      throw ProductSearchServerException(response.statusCode);
    }

    return ProductSearchResultModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
