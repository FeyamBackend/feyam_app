import 'package:feyam_app/core/config/app_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFlavorX', () {
    test('returns expected flavor names', () {
      expect(AppFlavor.dev.name, 'dev');
      expect(AppFlavor.stg.name, 'stg');
      expect(AppFlavor.prod.name, 'prod');
    });

    test('isProduction is only true for prod', () {
      expect(AppFlavor.dev.isProduction, isFalse);
      expect(AppFlavor.stg.isProduction, isFalse);
      expect(AppFlavor.prod.isProduction, isTrue);
    });
  });
}
