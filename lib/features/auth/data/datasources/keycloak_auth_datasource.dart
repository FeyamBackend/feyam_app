import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserCancelledAuthException implements Exception {
  const UserCancelledAuthException();
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

  Future<void> _clearSession() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _idTokenKey),
    ]);
  }
}
