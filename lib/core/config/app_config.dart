import 'package:feyam_app/core/config/app_flavor.dart';

class AppConfig{
  AppConfig._({
    required this.flavor,
    required this.apiBaseUrl,
  });

  final String flavor;
  final String apiBaseUrl;

  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static AppConfig fromFlavor(AppFlavor flavor) {
    return AppConfig._(flavor: flavor.name, apiBaseUrl: _apiBaseUrl);
  }
}