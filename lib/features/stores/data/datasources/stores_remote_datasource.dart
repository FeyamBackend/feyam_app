import 'dart:convert';

import 'package:feyam/features/stores/data/models/store_model.dart';
import 'package:http/http.dart' as http;

class StoresServerException implements Exception {
  const StoresServerException(this.statusCode);
  final int statusCode;
}

class StoresRemoteDataSource {
  StoresRemoteDataSource({
    required http.Client client,
    required String apiBaseUrl,
  })  : _client = client,
        _apiBaseUrl = apiBaseUrl;

  final http.Client _client;
  final String _apiBaseUrl;

  Future<List<StoreModel>> getStores(String? countryCode) async {
    final queryParams = countryCode != null ? '?countryCode=$countryCode' : '';
    final uri = Uri.parse('$_apiBaseUrl/api/stores$queryParams');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw StoresServerException(response.statusCode);
    }

    final raw = jsonDecode(response.body) as List<dynamic>;
    return raw
        .map((e) => StoreModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
