import 'dart:convert';

import 'package:feyam/features/profile/data/models/address_model.dart';
import 'package:feyam/features/profile/data/models/address_request_model.dart';
import 'package:feyam/features/profile/data/models/country_model.dart';
import 'package:http/http.dart' as http;

class AddressUnauthorizedException implements Exception {
  const AddressUnauthorizedException();
}

class AddressNotFoundException implements Exception {
  const AddressNotFoundException();
}

class AddressServerException implements Exception {
  const AddressServerException(this.statusCode);

  final int statusCode;
}

class AddressRemoteDataSource {
  AddressRemoteDataSource({
    required http.Client client,
    required String apiBaseUrl,
  })  : _client = client,
        _apiBaseUrl = apiBaseUrl;

  final http.Client _client;
  final String _apiBaseUrl;

  Future<List<AddressModel>> list() async {
    final uri = Uri.parse('$_apiBaseUrl/api/addresses');

    final response = await _client.get(uri);

    if (response.statusCode == 401) throw const AddressUnauthorizedException();
    if (response.statusCode != 200) {
      throw AddressServerException(response.statusCode);
    }

    final raw = jsonDecode(response.body) as List<dynamic>;
    return raw
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Países disponibles para direcciones. Reference data público; los nombres
  /// llegan localizados según [languageCode] (Accept-Language).
  Future<List<CountryModel>> listCountries(String languageCode) async {
    final uri = Uri.parse('$_apiBaseUrl/api/countries');

    final response = await _client.get(
      uri,
      headers: {'Accept-Language': languageCode},
    );

    if (response.statusCode == 401) throw const AddressUnauthorizedException();
    if (response.statusCode != 200) {
      throw AddressServerException(response.statusCode);
    }

    final raw = jsonDecode(response.body) as List<dynamic>;
    return raw
        .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AddressModel> create(AddressRequestModel request) async {
    final uri = Uri.parse('$_apiBaseUrl/api/addresses');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 401) throw const AddressUnauthorizedException();
    if (response.statusCode != 200) {
      throw AddressServerException(response.statusCode);
    }

    return AddressModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AddressModel> update(String id, AddressRequestModel request) async {
    final uri = Uri.parse('$_apiBaseUrl/api/addresses/$id');

    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 401) throw const AddressUnauthorizedException();
    if (response.statusCode == 404) throw const AddressNotFoundException();
    if (response.statusCode != 200) {
      throw AddressServerException(response.statusCode);
    }

    return AddressModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> delete(String id) async {
    final uri = Uri.parse('$_apiBaseUrl/api/addresses/$id');

    final response = await _client.delete(uri);

    if (response.statusCode == 401) throw const AddressUnauthorizedException();
    if (response.statusCode == 404) throw const AddressNotFoundException();
    // El backend responde 200 (Result.Success) ante borrado correcto.
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw AddressServerException(response.statusCode);
    }
  }
}
