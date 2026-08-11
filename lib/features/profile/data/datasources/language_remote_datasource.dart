import 'dart:convert';

import 'package:http/http.dart' as http;

class LanguageUnauthorizedException implements Exception {
  const LanguageUnauthorizedException();
}

class LanguageServerException implements Exception {
  const LanguageServerException(this.statusCode);

  final int statusCode;
}

class LanguageRemoteDataSource {
  LanguageRemoteDataSource({required http.Client client, required String apiBaseUrl})
    : _client = client,
      _apiBaseUrl = apiBaseUrl;

  final http.Client _client;
  final String _apiBaseUrl;

  Future<void> updateLanguage(String languageCode) async {
    final uri = Uri.parse('$_apiBaseUrl/api/me/language');

    final response = await _client.put(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'language': languageCode}),
    );

    if (response.statusCode == 401) {
      throw const LanguageUnauthorizedException();
    }
    if (response.statusCode >= 300) {
      throw LanguageServerException(response.statusCode);
    }
  }
}
