import 'package:feyam/core/utils/jwt_decoder.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserCancelledAuthException implements Exception {
  const UserCancelledAuthException();
}

/// Falla al refrescar el token. [isTransient] distingue un error de red/timeout
/// (la sesión sigue vigente, conviene reintentar) de un `invalid_grant`
/// definitivo (el refresh token ya no sirve y hay que reloguear).
class TokenRefreshException implements Exception {
  const TokenRefreshException({this.isTransient = false, this.cause});
  final bool isTransient;
  final Object? cause;
}

class KeycloakDataSource {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';

  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _secureStorage;
  final String _baseUrl;
  final String _realm;
  final String _clientId;
  final String _redirectUri;

  KeycloakDataSource({
    required FlutterAppAuth appAuth,
    required FlutterSecureStorage secureStorage,
    required String baseUrl,
    required String realm,
    required String clientId,
    required String redirectUri,
  }) : _appAuth = appAuth,
       _secureStorage = secureStorage,
       _baseUrl = baseUrl,
       _realm = realm,
       _clientId = clientId,
       _redirectUri = redirectUri;

  Future<void> redirectToLogin() async {
    try {
      final AuthorizationTokenResponse result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              _clientId,
              _redirectUri,
              issuer: '$_baseUrl/realms/$_realm',
              serviceConfiguration: AuthorizationServiceConfiguration(
                authorizationEndpoint:
                    '$_baseUrl/realms/$_realm/protocol/openid-connect/auth',
                tokenEndpoint:
                    '$_baseUrl/realms/$_realm/protocol/openid-connect/token',
              ),
              scopes: ['openid', 'profile', 'email'],
            ),
          );

      if (result.accessToken != null) {
        await _secureStorage.write(
          key: _accessTokenKey,
          value: result.accessToken,
        );
        await _secureStorage.write(
          key: _refreshTokenKey,
          value: result.refreshToken,
        );
        await _secureStorage.write(key: _idTokenKey, value: result.idToken);
      }
    } on PlatformException catch (e) {
      final isCancelled =
          e.code == 'authorize_and_exchange_code_failed' &&
          (e.message?.contains('User cancelled flow') ?? false);

      if (isCancelled) {
        throw const UserCancelledAuthException();
      }
      throw Exception('Failed to login via Keycloak AppAuth: $e');
    } catch (e) {
      throw Exception('Failed to login via Keycloak AppAuth: $e');
    }
  }

  Future<bool> logout() async {
    Object? endSessionError;

    try {
      final idToken = await _secureStorage.read(key: _idTokenKey);

      if (idToken != null && idToken.isNotEmpty) {
        await _appAuth.endSession(
          EndSessionRequest(
            idTokenHint: idToken,
            postLogoutRedirectUrl: _redirectUri,
            issuer: '$_baseUrl/realms/$_realm',
            serviceConfiguration: AuthorizationServiceConfiguration(
              authorizationEndpoint:
                  '$_baseUrl/realms/$_realm/protocol/openid-connect/auth',
              tokenEndpoint:
                  '$_baseUrl/realms/$_realm/protocol/openid-connect/token',
              endSessionEndpoint:
                  '$_baseUrl/realms/$_realm/protocol/openid-connect/logout',
            ),
          ),
        );
      }
    } catch (e) {
      endSessionError = e;
    } finally {
      await _clearSession();
    }

    if (endSessionError != null) {
      throw Exception(
        'Failed to logout via Keycloak AppAuth: $endSessionError',
      );
    }

    return true;
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Claims del `id_token` (emitido con scopes `openid profile email`), que ya
  /// trae `name`/`email` validados por Keycloak: evita pegarle a un endpoint
  /// de perfil aparte solo para mostrar esos datos.
  Future<Map<String, dynamic>?> getIdTokenClaims() async {
    final idToken = await _secureStorage.read(key: _idTokenKey);
    if (idToken == null || idToken.isEmpty) {
      return null;
    }
    try {
      return decodeJwtPayload(idToken);
    } catch (_) {
      return null;
    }
  }

  Future<void>? _refreshInFlight;

  /// Refresca el access token. Single-flight: si ya hay un refresh en curso, los
  /// llamantes concurrentes esperan el mismo future en vez de disparar otra
  /// renovación (evita la race con la rotación de refresh tokens de Keycloak,
  /// que invalidaría el refresh token usado por la segunda llamada).
  Future<void> refreshToken() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<void> _doRefresh() async {
    final storedRefresh = await _secureStorage.read(key: _refreshTokenKey);
    if (storedRefresh == null || storedRefresh.isEmpty) {
      // Sin refresh token no hay forma de recuperar la sesión: definitivo.
      await _clearSession();
      throw const TokenRefreshException(cause: 'no refresh token stored');
    }
    try {
      final result = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUri,
          refreshToken: storedRefresh,
          grantType: GrantType.refreshToken,
          issuer: '$_baseUrl/realms/$_realm',
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint:
                '$_baseUrl/realms/$_realm/protocol/openid-connect/auth',
            tokenEndpoint:
                '$_baseUrl/realms/$_realm/protocol/openid-connect/token',
          ),
          scopes: ['openid', 'profile', 'email'],
        ),
      );
      if (result.accessToken == null) {
        await _clearSession();
        throw const TokenRefreshException(
          cause: 'refresh returned null access token',
        );
      }
      await _secureStorage.write(key: _accessTokenKey, value: result.accessToken);
      if (result.refreshToken != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: result.refreshToken);
      }
      if (result.idToken != null) {
        await _secureStorage.write(key: _idTokenKey, value: result.idToken);
      }
    } on TokenRefreshException {
      rethrow;
    } catch (e) {
      if (_isTransientRefreshError(e)) {
        // Error de red/timeout: la sesión sigue vigente, no la limpiamos.
        throw TokenRefreshException(isTransient: true, cause: e);
      }
      // invalid_grant u otro error definitivo: el refresh token ya no sirve.
      await _clearSession();
      throw TokenRefreshException(cause: e);
    }
  }

  /// Heurística para separar fallos de red (reintentables, no deslogear) de un
  /// `invalid_grant` definitivo. flutter_appauth envuelve los errores OAuth en
  /// [PlatformException]: un grant inválido trae `invalid_grant` en el mensaje;
  /// el resto (sin conectividad, timeout, host inalcanzable) se trata como
  /// transitorio.
  bool _isTransientRefreshError(Object error) {
    if (error is PlatformException) {
      final details = '${error.message ?? ''} ${error.details ?? ''}'
          .toLowerCase();
      const definitiveMarkers = [
        'invalid_grant',
        'invalid_token',
        'invalid grant',
      ];
      return !definitiveMarkers.any(details.contains);
    }
    // Errores de socket/IO u otros no-OAuth: transitorios.
    return true;
  }

  Future<void> _clearSession() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _idTokenKey),
    ]);
  }
}
