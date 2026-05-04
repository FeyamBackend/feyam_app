import 'package:feyam/core/config/app_config.dart';
import 'package:feyam/core/config/app_flavor.dart';
import 'package:feyam/core/di/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await sl.reset();
  });

  test('registers default dev AppConfig when none is provided', () {
    configureDependencies();

    final appConfig = sl<AppConfig>();
    expect(appConfig.flavor, 'dev');
  });

  test('registers provided AppConfig', () {
    final providedConfig = AppConfig.fromFlavor(AppFlavor.prod);

    configureDependencies(appConfig: providedConfig);

    final appConfig = sl<AppConfig>();
    expect(appConfig.flavor, 'prod');
  });

  test('does not re-register AppConfig when already registered', () {
    final firstConfig = AppConfig.fromFlavor(AppFlavor.stg);
    final secondConfig = AppConfig.fromFlavor(AppFlavor.prod);

    configureDependencies(appConfig: firstConfig);
    configureDependencies(appConfig: secondConfig);

    final appConfig = sl<AppConfig>();
    expect(appConfig.flavor, 'stg');
  });
}
