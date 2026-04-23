import 'package:feyam_app/core/config/app_config.dart';
import 'package:feyam_app/core/config/app_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.fromFlavor', () {
    test('builds config from dev flavor', () {
      final config = AppConfig.fromFlavor(AppFlavor.dev);

      expect(config.flavor, 'dev');
    });

    test('builds config from prod flavor', () {
      final config = AppConfig.fromFlavor(AppFlavor.prod);

      expect(config.flavor, 'prod');
    });
  });
}
