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

  static AppConfig fromFlavor(AppFlavor flavor) {
    const envApiUrl = String.fromEnvironment('API_BASE_URL');
    const envKeycloakUrl = String.fromEnvironment('KEYCLOAK_BASE_URL');
    const envKeycloakRealm = String.fromEnvironment('KEYCLOAK_REALM');
    const envKeycloakClientId = String.fromEnvironment('KEYCLOAK_CLIENT_ID');
    const envKeycloakRedirectUri = String.fromEnvironment('KEYCLOAK_REDIRECT_URI');

    return AppConfig._(
      flavor: flavor.name,
      apiBaseUrl: envApiUrl.isNotEmpty ? envApiUrl : _defaultApiUrl(flavor),
      keycloakBaseUrl: envKeycloakUrl.isNotEmpty ? envKeycloakUrl : _defaultKeycloakUrl(flavor),
      keycloakRealm: envKeycloakRealm.isNotEmpty ? envKeycloakRealm : _defaultKeycloakRealm(flavor),
      keycloakClientId: envKeycloakClientId.isNotEmpty ? envKeycloakClientId : _defaultKeycloakClientId(flavor),
      keycloakRedirectUri: envKeycloakRedirectUri.isNotEmpty ? envKeycloakRedirectUri : _defaultKeycloakRedirectUri(flavor),
    );
  }

  static String _defaultApiUrl(AppFlavor flavor) => switch (flavor) {
    AppFlavor.prod => 'https://api.feyam.com',
    AppFlavor.stg  => 'https://api-stg.feyam.com',
    AppFlavor.dev  => 'https://api-dev.feyam.com',
    AppFlavor.local => 'http://10.0.2.2:8080',
  };

  static String _defaultKeycloakUrl(AppFlavor flavor) => switch (flavor) {
    AppFlavor.prod => 'https://auth.feyam.com',
    AppFlavor.stg  => 'https://auth-stg.feyam.com',
    AppFlavor.dev  => 'https://auth-dev.feyam.com',
    AppFlavor.local => 'http://10.0.2.2:8180',
  };

  static String _defaultKeycloakRealm(AppFlavor flavor) => switch (flavor) {
    AppFlavor.prod => 'feyam',
    AppFlavor.stg  => 'feyam-stg',
    AppFlavor.dev  => 'feyam-dev',
    AppFlavor.local => 'feyam-local',
  };

  static String _defaultKeycloakClientId(AppFlavor flavor) => switch (flavor) {
    AppFlavor.prod => 'feyam-mobile',
    AppFlavor.stg  => 'feyam-mobile-stg',
    AppFlavor.dev  => 'feyam-mobile-dev',
    AppFlavor.local => 'feyam-mobile-local',
  };

  static String _defaultKeycloakRedirectUri(AppFlavor flavor) => switch (flavor) {
    AppFlavor.prod => 'com.feyamuniversellc.feyam:/oauthredirect',
    AppFlavor.stg  => 'com.feyamuniversellc.feyam.stg:/oauthredirect',
    AppFlavor.dev  => 'com.feyamuniversellc.feyam.dev:/oauthredirect',
    AppFlavor.local => 'com.feyamuniversellc.feyam.local:/oauthredirect',
  };
}
