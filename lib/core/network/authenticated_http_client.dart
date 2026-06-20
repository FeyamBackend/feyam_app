import 'dart:io';

import 'package:feyam/core/network/session_expired_notifier.dart';
import 'package:feyam/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// `http.Client` que centraliza la autenticación:
///
/// - Inyecta `Authorization: Bearer <access_token>` en cada request.
/// - Ante un 401, refresca el token (single-flight en [AuthRepository] /
///   `KeycloakDataSource`) y reintenta el request **una** sola vez.
/// - Si el refresh falla de forma **definitiva** (`invalid_grant`), notifica vía
///   [SessionExpiredNotifier] para que la app desloguee una única vez.
/// - Si el refresh falla de forma **transitoria** (red/timeout), devuelve el 401
///   sin deslogear: el usuario no pierde la sesión por un blip de red.
///
/// Reemplaza la lógica de token + refresh + retry que antes estaba duplicada en
/// cada repositorio y datasource.
class AuthenticatedHttpClient extends http.BaseClient {
  AuthenticatedHttpClient({
    required http.Client inner,
    required FlutterSecureStorage secureStorage,
    required AuthRepository authRepository,
    required SessionExpiredNotifier sessionExpiredNotifier,
  })  : _inner = inner,
        _secureStorage = secureStorage,
        _authRepository = authRepository,
        _sessionExpiredNotifier = sessionExpiredNotifier;

  static const String _accessTokenKey = 'access_token';

  final http.Client _inner;
  final FlutterSecureStorage _secureStorage;
  final AuthRepository _authRepository;
  final SessionExpiredNotifier _sessionExpiredNotifier;

  // Single-flight: como este cliente es singleton, varias requests concurrentes
  // que reciban 401 comparten un único refresh en vez de disparar uno cada una
  // (lo que con rotación de refresh tokens invalidaría el token de las demás).
  Future<void>? _refreshInFlight;

  Future<void> _refreshOnce() {
    return _refreshInFlight ??=
        _authRepository.refreshAccessToken().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Bufferizamos el body: un BaseRequest finalizado no se puede reenviar, y
    // necesitamos poder reintentar tras el refresh.
    final bodyBytes = await request.finalize().toBytes();

    final response = await _sendOnce(request, bodyBytes);
    if (response.statusCode != 401) {
      return response;
    }

    try {
      await _refreshOnce();
    } on AuthTokenExpiredException {
      // Refresh token inválido/expirado: sesión terminada de verdad.
      _sessionExpiredNotifier.notify();
      return response;
    } on AuthTokenRefreshTransientException {
      // Error de red durante el refresh: lo tratamos como error de red (no como
      // sesión expirada) para no deslogear al usuario por un blip.
      await response.stream.drain<void>();
      throw const SocketException(
        'Token refresh failed: transient network error',
      );
    }

    // Refresh OK: descartamos la respuesta 401 y reintentamos con el token nuevo.
    await response.stream.drain<void>();
    return _sendOnce(request, bodyBytes);
  }

  Future<http.StreamedResponse> _sendOnce(
    http.BaseRequest original,
    List<int> bodyBytes,
  ) async {
    final token = await _secureStorage.read(key: _accessTokenKey);

    final request = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection
      ..bodyBytes = bodyBytes;

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    } else {
      request.headers.remove('Authorization');
    }

    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
