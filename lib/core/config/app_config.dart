import 'package:feyam/core/config/app_flavor.dart';

class AppConfig {
  AppConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.keycloakBaseUrl,
    required this.keycloakRealm,
    required this.keycloakClientId,
    required this.keycloakRedirectUri,
  });

  final String flavor;
  final String apiBaseUrl;
  final String keycloakBaseUrl;
  final String keycloakRealm;
  final String keycloakClientId;
  final String keycloakRedirectUri;

  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _keycloakBaseUrl = String.fromEnvironment(
    'KEYCLOAK_BASE_URL',
  );
  static const String _keycloakRealm = String.fromEnvironment('KEYCLOAK_REALM');
  static const String _keycloakClientId = String.fromEnvironment(
    'KEYCLOAK_CLIENT_ID',
  );
  static const String _keycloakRedirectUri = String.fromEnvironment(
    'KEYCLOAK_REDIRECT_URI',
  );

  static AppConfig fromFlavor(AppFlavor flavor) {
    return AppConfig._(
      flavor: flavor.name,
      apiBaseUrl: _apiBaseUrl,
      keycloakBaseUrl: _keycloakBaseUrl,
      keycloakRealm: _keycloakRealm,
      keycloakClientId: _keycloakClientId,
      keycloakRedirectUri: _keycloakRedirectUri,
    );
  }
}
