import 'package:feyam_app/core/config/app_flavor.dart';

class AppConfig{
  AppConfig._({
    required this.flavor,
  });

  final String flavor;

  static AppConfig fromFlavor(AppFlavor flavor) {
    return AppConfig._(flavor: flavor.name);
  }
}